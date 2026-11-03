using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class ChartController : Controller
{
    private readonly IWebHostEnvironment _env;

    public ChartController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpGet]
    public IActionResult Index() => Spa();

    [HttpGet]
    public IActionResult Rdos() => Spa();

    [HttpGet]
    public IActionResult DiaImprodutivo() => Spa();

    [HttpGet]
    public IActionResult Tarefa() => Spa();

    [HttpGet]
    public IActionResult Comentario() => Spa();

    private IActionResult Spa() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Dashboard geral", requireObra: false);
}
