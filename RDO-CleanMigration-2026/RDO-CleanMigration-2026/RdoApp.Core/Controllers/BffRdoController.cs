using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/rdos")]
public class BffRdoController : ControllerBase
{
    private readonly RdoListQueryService _rdos;
    private readonly RdoCadastroQueryService _cadastroQuery;
    private readonly RdoCadastroSaveService _cadastroSave;

    public BffRdoController(
        RdoListQueryService rdos,
        RdoCadastroQueryService cadastroQuery,
        RdoCadastroSaveService cadastroSave)
    {
        _rdos = rdos;
        _cadastroQuery = cadastroQuery;
        _cadastroSave = cadastroSave;
    }

    [HttpGet("status-options")]
    public async Task<IActionResult> StatusOptions(CancellationToken cancellationToken)
    {
        var list = await _rdos.GetStatusOptionsAsync(cancellationToken);
        return Ok(list);
    }

    [HttpGet]
    public async Task<IActionResult> List(
        [FromQuery] int page = 1,
        [FromQuery] int statusRdo = 0,
        [FromQuery] string? dataInicial = null,
        [FromQuery] string? dataFinal = null,
        CancellationToken cancellationToken = default)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);

        var payload = await _rdos.GetListAsync(
            obraId,
            obraNome,
            page,
            statusRdo,
            ParseDate(dataInicial),
            ParseDate(dataFinal),
            cancellationToken);

        return Ok(payload);
    }

    [HttpGet("cadastro/bootstrap")]
    public IActionResult CadastroBootstrap()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var payload = _cadastroQuery.GetBootstrap(obraId, ObraSessionHelper.GetObraNome(HttpContext));
        return Ok(payload);
    }

    [HttpGet("cadastro/etapas")]
    public async Task<IActionResult> CadastroEtapas(
        [FromQuery] string? dataRdo,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var parsed = ParseDate(dataRdo);
        if (!parsed.HasValue)
        {
            return BadRequest(new { message = "Informe dataRdo (dd/MM/yyyy)." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var payload = await _cadastroQuery.GetEtapasParaRdoAsync(obraId, parsed.Value, cancellationToken);
        return Ok(payload);
    }

    [HttpPost("cadastro")]
    public async Task<IActionResult> CadastroSave(
        [FromBody] RdoCadastroSaveRequestDto? body,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        if (body == null)
        {
            return BadRequest(new RdoCadastroSaveResultDto { Ok = false, ErrorMessage = "Corpo da requisição inválido." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var colaboradorId = HttpContext.Session.GetInt32(SessionKeys.ColaboradorId) ?? 0;
        RdoCadastroSaveResultDto result;
        try
        {
            result = await _cadastroSave.SaveAsync(obraId, colaboradorId, body, cancellationToken);
        }
        catch (Exception ex)
        {
            return BadRequest(new RdoCadastroSaveResultDto { Ok = false, ErrorMessage = ex.Message });
        }

        if (!result.Ok && result.NeedsConfirm != null)
        {
            return Ok(result);
        }

        if (!result.Ok)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }

    private static DateTime? ParseDate(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        if (DateTime.TryParseExact(value.Trim(), "dd/MM/yyyy", CultureInfo.GetCultureInfo("pt-BR"), DateTimeStyles.None, out var d))
        {
            return d;
        }

        if (DateTime.TryParse(value, CultureInfo.GetCultureInfo("pt-BR"), DateTimeStyles.None, out d))
        {
            return d;
        }

        return null;
    }
}
