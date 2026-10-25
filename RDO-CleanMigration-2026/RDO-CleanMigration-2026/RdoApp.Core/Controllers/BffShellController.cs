using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/shell")]
public class BffShellController : ControllerBase
{
    private readonly ShellContextService _shell;

    public BffShellController(ShellContextService shell)
    {
        _shell = shell;
    }

    /// <summary>M4.4c / M4.5 — header RBAC + menu (session LoginData).</summary>
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(_shell.Build(HttpContext));
    }
}
