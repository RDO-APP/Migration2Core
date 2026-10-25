using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Controllers;

[Authorize]
public class ChartController : Controller
{
    [HttpGet]
    public IActionResult Index()
    {
        return View("EmMigracao", new EmMigracaoViewModel
        {
            Titulo = "Dashboard geral (gráficos)",
            Descricao = "Módulo de gráficos em migração para .NET Core (M5+).",
            VoltarUrl = "/Obra/Escolher",
        });
    }
}
