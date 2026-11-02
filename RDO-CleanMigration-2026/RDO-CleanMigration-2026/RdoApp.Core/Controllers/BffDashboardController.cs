using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/dashboard")]
public class BffDashboardController : ControllerBase
{
    private readonly DashboardQueryService _dashboard;

    public BffDashboardController(DashboardQueryService dashboard)
    {
        _dashboard = dashboard;
    }

    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        try
        {
            var payload = await _dashboard.GetAsync(obraId, cancellationToken);
            return Ok(payload);
        }
        catch (Exception ex)
        {
            var inner = ex.InnerException?.Message;
            var detail = string.IsNullOrWhiteSpace(inner) ? ex.Message : $"{ex.Message} | {inner}";
            return StatusCode(500, new { message = $"Erro 500 no servidor (dashboard). {ex.GetType().Name}: {detail}" });
        }
    }
}
