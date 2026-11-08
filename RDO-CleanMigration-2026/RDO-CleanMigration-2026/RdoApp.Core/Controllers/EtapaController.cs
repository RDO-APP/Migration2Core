using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class EtapaController : Controller
{
    private readonly IWebHostEnvironment _env;

    public EtapaController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpGet]
    public IActionResult Index() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Etapas");

    [HttpGet]
    public IActionResult Cadastro() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Nova etapa");
}
