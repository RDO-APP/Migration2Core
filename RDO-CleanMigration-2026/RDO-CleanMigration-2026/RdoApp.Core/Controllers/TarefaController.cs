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
    public IActionResult Cards() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Tarefas");

    [HttpGet]
    public IActionResult Index() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Lista de tarefas");

    [HttpGet]
    public IActionResult Cadastro(int? id, int? etapaId, string? modo, bool novaMedicao = false)
    {
        if (RequireObraOrRedirect() is { } redir)
        {
            return redir;
        }

        var spaTitle = id is > 0
            ? (novaMedicao
                ? "Nova medição"
                : modo == "visualizar"
                    ? "Visualizar tarefa"
                    : "Editar tarefa")
            : "Nova tarefa";
        return OperadorSpaEntry.ServeSpaIndex(this, _env, spaTitle);
    }

    [HttpGet]
    public IActionResult HistoricoMedicao(int id)
    {
        if (RequireObraOrRedirect() is { } redir)
        {
            return redir;
        }

        return Redirect($"/Tarefa/Cards?historico={id}");
    }

    [HttpGet]
    public IActionResult RelatorioHorasEquipamento(int id)
    {
        return RequireObraOrRedirect() ?? EmMigracaoPage.Render(
            this,
            "Relatório horas por equipamento",
            $"Modal `#relatorio-horas-equipamento` · tarefaId={id} · **M7+**.",
            prodRef: "cards.html · relatório equipamento");
    }

    [HttpGet]
    public IActionResult AlterarStatus(int id)
    {
        if (RequireObraOrRedirect() is { } redir)
        {
            return redir;
        }

        return Redirect("/Tarefa/Cards");
    }

    [HttpGet]
    public IActionResult Excluir(int id)
    {
        return RequireObraOrRedirect() ?? EmMigracaoPage.Render(
            this,
            "Excluir tarefa",
            $"`permission deletar` · tarefaId={id} · **M7+** API.",
            prodRef: "controller.deletar(tarefa)");
    }

    [HttpGet]
    public IActionResult AlterarStatusEmMassa()
    {
        return RequireObraOrRedirect() ?? EmMigracaoPage.Render(
            this,
            "Alterar status em massa",
            "Modal `#alterar-status` · checkboxes + `aterarStatusEmMassa` · **M7+**.",
            prodRef: "cards.html · SELECIONAR TUDO");
    }

    [HttpGet("/Tarefa/Paralizacoes/Index")]
    public IActionResult Paralizacoes() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Códigos de Paralizações");

    private IActionResult? RequireObraOrRedirect()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return RedirectToAction(nameof(ObraController.Escolher), "Obra");
        }

        return null;
    }
}
