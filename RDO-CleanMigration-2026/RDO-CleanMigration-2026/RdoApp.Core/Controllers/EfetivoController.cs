using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class EfetivoController : Controller
{
    private readonly IWebHostEnvironment _env;

    public EfetivoController(IWebHostEnvironment env) => _env = env;

    [HttpGet]
    public IActionResult Index() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Efetivo diário");
}
