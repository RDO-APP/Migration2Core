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
    public IActionResult Index()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return RedirectToAction(nameof(ObraController.Escolher), "Obra");
        }

        var spaIndex = Path.Combine(_env.WebRootPath, "app", "index.html");
        if (System.IO.File.Exists(spaIndex))
        {
            return PhysicalFile(spaIndex, "text/html");
        }

        ViewData["Title"] = "RDO's";
        ViewData["ObraId"] = ObraSessionHelper.GetObraId(HttpContext);
        ViewData["ObraNome"] = ObraSessionHelper.GetObraNome(HttpContext);
        return View();
    }

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
