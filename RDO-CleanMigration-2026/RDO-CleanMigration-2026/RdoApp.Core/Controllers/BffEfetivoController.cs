using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/efetivo")]
public class BffEfetivoController : ControllerBase
{
    private readonly EfetivoQueryService _efetivo;
    private readonly EfetivoRelatorioService _relatorio;

    public BffEfetivoController(EfetivoQueryService efetivo, EfetivoRelatorioService relatorio)
    {
        _efetivo = efetivo;
        _relatorio = relatorio;
    }

    [HttpGet("bootstrap")]
    public async Task<IActionResult> Bootstrap(CancellationToken ct)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _efetivo.GetBootstrapAsync(obraId, obraNome, ct));
    }

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] string? data,
        [FromQuery] string? nome,
        [FromQuery] int cargoId = 0,
        [FromQuery] int statusId = 0,
        CancellationToken ct = default)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        try
        {
            var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
            return Ok(await _efetivo.ListAsync(obraId, data ?? "", nome, cargoId, statusId, ct));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("status")]
    public async Task<IActionResult> UpdateStatus([FromBody] EfetivoStatusUpdateRequestDto? body, CancellationToken ct)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        if (body == null)
            return BadRequest(new EfetivoStatusUpdateResultDto { Ok = false, ErrorMessage = "Corpo invalido." });
        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _efetivo.UpdateStatusAsync(obraId, body, ct);
        if (!result.Ok) return BadRequest(result);
        return Ok(result);
    }

    /// <summary>Paridade prod <c>POST api/efetivo/CopiarEfetivo</c>.</summary>
    [HttpPost("copiar")]
    public async Task<IActionResult> Copiar([FromBody] EfetivoCopiarRequestDto? body, CancellationToken ct)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        if (body == null)
            return BadRequest(new EfetivoCopiarResultDto { Ok = false, ErrorMessage = "Corpo invalido." });
        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _efetivo.CopiarAsync(obraId, body, ct);
        if (!result.Ok) return BadRequest(result);
        return Ok(result);
    }

    /// <summary>Paridade prod <c>POST api/efetivo/gerarrelatorio</c> — baixa PDF ou Excel.</summary>
    [HttpPost("relatorio")]
    public async Task<IActionResult> Relatorio([FromBody] EfetivoRelatorioRequestDto? body, CancellationToken ct)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        if (body == null)
            return BadRequest(new { message = "Corpo invalido." });
        try
        {
            var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
            var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
            var (bytes, contentType, fileName) = await _relatorio.GenerateAsync(obraId, obraNome, body, ct);
            return File(bytes, contentType, fileName);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
