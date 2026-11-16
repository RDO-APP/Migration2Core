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

    public BffMedicaoController(MedicaoRelatorioService relatorio) => _relatorio = relatorio;

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
    }
}
