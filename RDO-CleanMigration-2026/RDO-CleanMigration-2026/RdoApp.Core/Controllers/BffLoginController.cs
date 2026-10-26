using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace RdoApp.Core.Controllers;

/// <summary>M4.8 — antiforgery para Login SPA (POST /Account/Login).</summary>
[AllowAnonymous]
[ApiController]
[Route("api/bff/login")]
public class BffLoginController : ControllerBase
{
    private readonly IAntiforgery _antiforgery;

    public BffLoginController(IAntiforgery antiforgery)
    {
        _antiforgery = antiforgery;
    }

    [HttpGet("context")]
    public IActionResult Context()
    {
        var tokens = _antiforgery.GetAndStoreTokens(HttpContext);
        return Ok(new
        {
            antiforgeryFieldName = tokens.FormFieldName,
            antiforgeryToken = tokens.RequestToken,
        });
    }
}
