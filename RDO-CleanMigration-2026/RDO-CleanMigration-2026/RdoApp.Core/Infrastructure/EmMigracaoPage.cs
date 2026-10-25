using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Infrastructure;

/// <summary>Placeholder Razor até telas reais (M5/M7).</summary>
public static class EmMigracaoPage
{
    public static IActionResult Render(
        Controller controller,
        string titulo,
        string descricao,
        string voltarUrl = "/Tarefa/Cards",
        string voltarRotulo = "Voltar para tarefas",
        string? prodRef = null)
    {
        var desc = string.IsNullOrWhiteSpace(prodRef)
            ? descricao
            : $"{descricao} Referência prod: {prodRef}.";

        return controller.View("EmMigracao", new EmMigracaoViewModel
        {
            Titulo = titulo,
            Descricao = desc,
            VoltarUrl = voltarUrl,
            VoltarRotulo = voltarRotulo,
        });
    }
}
