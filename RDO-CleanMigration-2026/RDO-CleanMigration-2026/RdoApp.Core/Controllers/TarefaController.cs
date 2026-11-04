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
    public IActionResult Index()
    {
        return RequireObraOrRedirect() ?? EmMigracaoPage.Render(
            this,
            "Lista de tarefas",
            "Visualização em colunas (`#/tarefa/index`) em migração (M7+).",
            prodRef: "#/tarefa/index");
    }

    [HttpGet]
    public IActionResult Cadastro(int? id, int? etapaId, string? modo, bool novaMedicao = false)
    {
        if (RequireObraOrRedirect() is { } redir)
        {
            return redir;
        }

        if (id is > 0)
        {
            var spaTitle = novaMedicao
                ? "Nova medição"
                : modo == "visualizar"
                    ? "Visualizar tarefa"
                    : "Editar tarefa";
            return OperadorSpaEntry.ServeSpaIndex(this, _env, spaTitle);
        }

        var titulo = "Cadastro de tarefa";
        var desc =
            $"Prod: `#/tarefa/cadastro` · id=— · etapaId={etapaId?.ToString() ?? "—"} · **M7** nova tarefa (sem id) ainda em migração.";
        return EmMigracaoPage.Render(this, titulo, desc, prodRef: "#/tarefa/cadastro");
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
        return RequireObraOrRedirect() ?? EmMigracaoPage.Render(
            this,
            "Alterar status da tarefa",
            $"Painel ⋮ / `listaStatusPermitidos` · tarefaId={id} · **M7+**.",
            prodRef: "cards.html · .bt-status");
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
    public IActionResult Paralizacoes()
    {
        return RequireObraOrRedirect() ?? EmMigracaoPage.Render(
            this,
            "Códigos de paralizações",
            "Listagem `#/tarefa/paralizacoes/index` · **M7+**.",
            prodRef: "#/tarefa/paralizacoes/index");
    }

    private IActionResult? RequireObraOrRedirect()
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return RedirectToAction(nameof(ObraController.Escolher), "Obra");
        }

        return null;
    }
}
