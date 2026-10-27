using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

/// <summary>Homolog — diagnóstico legível no F12 (Fetch/XHR) e colando URL no navegador.</summary>
[ApiController]
[Route("api/bff/diag")]
public class BffDiagController : ControllerBase
{
    private readonly IWebHostEnvironment _env;

    public BffDiagController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [AllowAnonymous]
    [HttpGet]
    public IActionResult Get()
    {
        if (!_env.IsStaging())
        {
            return NotFound();
        }

        var snap = HomologDiagnostics.BuildSnapshot(HttpContext);
        return Ok(new
        {
            mensagem = "Diagnóstico homolog — copie este JSON para o chat Migração.",
            snapshot = snap,
            path = HttpContext.Request.Path.Value,
            autenticado = User.Identity?.IsAuthenticated == true,
            obraSelecionada = ObraSessionHelper.HasObraSelected(HttpContext),
            obraId = ObraSessionHelper.GetObraId(HttpContext),
            temLoginData = !string.IsNullOrEmpty(HttpContext.Session.GetString(SessionKeys.LoginData)),
            dicaF12 = "Página debug: /Homolog/F12 · Rede Fetch/XHR → api/bff/diag · Doc Rdo/Index → X-RdoApp-*",
        });
    }
}
