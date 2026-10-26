using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/rdos")]
public class BffRdoController : ControllerBase
{
    private readonly RdoListQueryService _rdos;

    public BffRdoController(RdoListQueryService rdos)
    {
        _rdos = rdos;
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
