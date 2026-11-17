using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/medicao")]
public class BffMedicaoController : ControllerBase
{
    private readonly MedicaoRelatorioService _relatorio;
    private readonly ILogger<BffMedicaoController> _logger;
    private readonly IWebHostEnvironment _env;

    public BffMedicaoController(
        MedicaoRelatorioService relatorio,
        ILogger<BffMedicaoController> logger,
        IWebHostEnvironment env)
    {
        _relatorio = relatorio;
        _logger = logger;
        _env = env;
    }

    /// <summary>Paridade prod POST api/medicao/gerarrelatorio.</summary>
    [HttpPost("relatorio")]
    public async Task<IActionResult> Relatorio([FromBody] MedicaoRelatorioRequestDto? body, CancellationToken ct)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        if (body == null)
            return BadRequest(new { message = "Corpo invalido." });
        try
        {
            var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
            var (bytes, contentType, fileName) = await _relatorio.GenerateAsync(obraId, body, ct);
            return File(bytes, contentType, fileName);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Medicao relatorio 500");
            try
            {
                var dir = Path.Combine(_env.ContentRootPath, "logs");
                Directory.CreateDirectory(dir);
                var dump = $"{DateTime.UtcNow:o}\n{ex.GetType().FullName}: {ex.Message}\n{ex.StackTrace}\nINNER: {ex.InnerException}";
                System.IO.File.WriteAllText(Path.Combine(dir, "medicao-last-error.txt"), dump);
            }
            catch { /* ignore disk */ }

            var msg = "Erro ao gerar relatório de medição: "
                      + ex.GetType().Name + " — " + ex.Message
                      + (ex.InnerException != null ? " | " + ex.InnerException.Message : "");
            return StatusCode(500, new { message = msg });
        }
    }
}
