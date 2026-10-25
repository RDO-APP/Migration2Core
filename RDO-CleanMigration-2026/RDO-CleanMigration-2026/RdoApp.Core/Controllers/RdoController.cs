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

        return View("EmMigracao", new EmMigracaoViewModel
        {
            Titulo = "RDO's",
            Descricao = "Listagem e cadastro de RDO em migração (M5+).",
            VoltarUrl = "/Tarefa/Cards",
            VoltarRotulo = "Voltar para tarefas",
        });
    }
}
