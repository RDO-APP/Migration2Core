using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Controllers;

[Authorize]
public class RdoController : Controller
{
    [HttpGet]
    public IActionResult Index()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return RedirectToAction(nameof(ObraController.Escolher), "Obra");
        }

        return EmMigracaoPage.Render(
            this,
            "RDO's",
            "Listagem de RDO em migração (M5+).",
            prodRef: "#/rdo/index");
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
