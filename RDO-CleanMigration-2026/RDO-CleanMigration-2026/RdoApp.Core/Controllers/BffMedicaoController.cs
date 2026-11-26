using System.Text.Json;
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
        WriteDiag("HIT " + (body?.TipoRelatorio ?? "?") + " " + (body?.DataInicial ?? "") + ".." + (body?.DataFinal ?? ""));

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return JsonStatus(401, "Nenhuma obra selecionada.");
        if (body == null)
            return JsonStatus(400, "Corpo invalido.");
        try
        {
            var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
            WriteDiag("obraId=" + obraId);
            var (bytes, contentType, fileName) = await _relatorio.GenerateAsync(obraId, body, ct);
            WriteDiag("OK bytes=" + bytes.Length + " type=" + contentType);
            return File(bytes, contentType, fileName);
        }
        catch (InvalidOperationException ex)
        {
            WriteDiag("400 " + ex.Message);
            return JsonStatus(400, ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Medicao relatorio 500");
            var msg = ex.GetType().Name + " — " + ex.Message
                      + (ex.InnerException != null ? " | " + ex.InnerException.Message : "");
            WriteDiag("500 " + msg + "\n" + ex.StackTrace);
            return JsonStatus(500, "Erro ao gerar relatório de medição: " + msg);
        }
    }

    private IActionResult JsonStatus(int status, string message)
    {
        // Content explícito — StatusCode(object) às vezes chega vazio atrás do ALB.
        Response.StatusCode = status;
        return Content(JsonSerializer.Serialize(new { message }), "application/json");
    }

    private void WriteDiag(string line)
    {
        try
        {
            var dir = Path.Combine(_env.ContentRootPath, "logs");
            Directory.CreateDirectory(dir);
            System.IO.File.AppendAllText(
                Path.Combine(dir, "medicao-diag.txt"),
                DateTime.UtcNow.ToString("o") + " " + line + Environment.NewLine);
        }
        catch { /* ignore */ }
    }
}
