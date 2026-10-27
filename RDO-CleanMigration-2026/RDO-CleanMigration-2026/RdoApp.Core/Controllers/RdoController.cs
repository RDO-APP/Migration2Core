using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class RdoController : Controller
{
    private readonly IWebHostEnvironment _env;

    public RdoController(IWebHostEnvironment env)
    {
        _env = env;
    }

    // Rota convencional /Rdo/Index — evita AmbiguousMatch com MapControllerRoute (ASP0023).
    [HttpGet]
    public IActionResult Index() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "RDO's");

    [HttpGet]
    public IActionResult Cadastro()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return RedirectToAction(nameof(ObraController.Escolher), "Obra");
        }

        return EmMigracaoPage.Render(
            this,
            "Gerar RDO",
            "Cadastro RDO (`cadastroRdo`) · **M7+** · permission gerarRdo.",
            prodRef: "#/rdo/cadastro");
    }
}
