using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class EfetivoController : Controller
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
            "Efetivo diário",
            "Tela efetivo · **M7+** (escopo Dimas).",
            prodRef: "#/efetivo/index");
    }
}
