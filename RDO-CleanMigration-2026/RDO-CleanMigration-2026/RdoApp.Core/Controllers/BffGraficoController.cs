using System.Globalization;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/grafico")]
public class BffGraficoController : ControllerBase
{
    private readonly GraficoQueryService _grafico;

    public BffGraficoController(GraficoQueryService grafico)
    {
        _grafico = grafico;
    }

    [HttpGet("resumo")]
    public async Task<IActionResult> Resumo(
        [FromQuery] string? periodoIni,
        [FromQuery] string? periodoFim,
        CancellationToken cancellationToken)
    {
        var colaboradorId = LoginSessionHelper.GetColaboradorId(HttpContext);
        if (colaboradorId <= 0)
        {
            return Unauthorized(new { message = "Sessão sem colaborador." });
        }

        if (!TryParseDate(periodoIni, out var ini) || !TryParseDate(periodoFim, out var fim))
        {
            return BadRequest(new { message = "O período não foi fornecido." });
        }

        try
        {
            var payload = await _grafico.GetResumoAsync(colaboradorId, ini, fim, cancellationToken);
            return Ok(payload);
        }
        catch (Exception ex)
        {
            var inner = ex.InnerException?.Message;
            var detail = string.IsNullOrWhiteSpace(inner) ? ex.Message : $"{ex.Message} | {inner}";
            return StatusCode(500, new { message = $"Erro 500 no servidor (gráfico). {ex.GetType().Name}: {detail}" });
        }
    }

    private static bool TryParseDate(string? value, out DateTime date)
    {
        date = default;
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        return DateTime.TryParseExact(value.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out date)
            || DateTime.TryParseExact(value.Trim(), "dd/MM/yyyy", CultureInfo.GetCultureInfo("pt-BR"), DateTimeStyles.None, out date)
            || DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.None, out date);
    }
}
