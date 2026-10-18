using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class TarefaController : Controller
{
    private readonly IWebHostEnvironment _env;

    public TarefaController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpGet]
    public IActionResult Cards()
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

        ViewData["Title"] = "Tarefas";
        ViewData["ObraId"] = ObraSessionHelper.GetObraId(HttpContext);
        ViewData["ObraNome"] = ObraSessionHelper.GetObraNome(HttpContext);
        return View();
    }
}
