using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Controllers;

[Authorize]
public class DashboardController : Controller
{
    [HttpGet("/Dashboard/Index")]
    public IActionResult Index()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return RedirectToAction(nameof(ObraController.Escolher), "Obra");
        }

        return EmMigracaoPage.Render(
            this,
            "Dashboard da obra",
            "Painel da obra em migração (M5+).",
            prodRef: "#/dashboard/index");
    }
}
