using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class TarefaController : Controller
{
    [HttpGet]
    public IActionResult Cards()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return RedirectToAction(nameof(ObraController.Escolher), "Obra");
        }

        ViewData["Title"] = "Tarefas";
        ViewData["ObraId"] = ObraSessionHelper.GetObraId(HttpContext);
        ViewData["ObraNome"] = ObraSessionHelper.GetObraNome(HttpContext);
        return View();
    }
}
