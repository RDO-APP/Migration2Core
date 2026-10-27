using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

[Authorize]
public class ChartController : Controller
{
    // Rota convencional /Chart/Index — uma endpoint por action (ASP0023).
    [HttpGet]
    public IActionResult Index()
    {
        return EmMigracaoPage.Render(
            this,
            "Dashboard geral (gráficos)",
            "Módulo de gráficos em migração (M5+).",
            voltarUrl: "/Tarefa/Cards",
            voltarRotulo: "Voltar para tarefas",
            prodRef: "#/chart");
    }
}
