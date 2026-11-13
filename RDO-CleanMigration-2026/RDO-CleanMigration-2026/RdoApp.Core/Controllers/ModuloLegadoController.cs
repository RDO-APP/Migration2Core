using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

/// <summary>M4.7h / M5-nav — menu drawer: paths legado Angular → EmMigracao até M5/M7.</summary>
[Authorize]
public class ModuloLegadoController : Controller
{
    private readonly IWebHostEnvironment _env;

    public ModuloLegadoController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpGet("/colaborador/index")]
    public IActionResult Colaborador() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Colaboradores");

    [HttpGet("/colaborador/cadastro")]
    public IActionResult ColaboradorCadastro() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Cadastro colaborador");

    [HttpGet("/equipamento/index")]
    [HttpGet("/equipamentos/index")]
    public IActionResult Equipamentos() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Equipamentos");

    [HttpGet("/equipamentos/cadastro")]
    [HttpGet("/equipamento/cadastro")]
    public IActionResult EquipamentosCadastro() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Cadastro equipamento");

    [HttpGet("/empresa/index")]
    public IActionResult Empresa() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Empresas");

    [HttpGet("/empresa/cadastro")]
    public IActionResult EmpresaCadastro() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Cadastro empresa");

    [HttpGet("/pagina/cadastro")]
    public IActionResult PaginaCadastro() =>
        Stub("Cadastro página/menu", "#/pagina/cadastro", "Admin páginas (M7+).", voltarUrl: "/Obra/Escolher");

    [HttpGet("/grupo/index")]
    public IActionResult Grupo() =>
        Stub("Grupos", "#/grupo/index", "Permissões e grupos (M7+).", voltarUrl: "/Obra/Escolher");

    [HttpGet("/grupo/cadastro")]
    public IActionResult GrupoCadastro() =>
        Stub("Cadastro grupo", "#/grupo/cadastro", "Formulário grupo (M7+).", voltarUrl: "/Obra/Escolher");

    [HttpGet("/menu/index")]
    public IActionResult Menu() =>
        Stub("Menus", "#/menu/index", "Configuração de menus (M7+).", voltarUrl: "/Obra/Escolher");

    [HttpGet("/menu/cadastro")]
    public IActionResult MenuCadastro() =>
        Stub("Cadastro menu", "#/menu/cadastro", "Formulário menu (M7+).", voltarUrl: "/Obra/Escolher");

    [HttpGet("/historicoacesso/index")]
    public IActionResult HistoricoAcesso() =>
        Stub("Histórico de acesso", "#/historicoacesso/index", "Auditoria de logins (M7+).", voltarUrl: "/Obra/Escolher");

    [HttpGet("/tarefa/paralizacoes/index")]
    public IActionResult TarefaParalizacoes() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Códigos de Paralizações");

    [HttpGet("/tarefa/paralizacoes/cadastro")]
    public IActionResult TarefaParalizacoesCadastro() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Cadastro código de paralização");

    [HttpGet("/relatorioprodutividade/index")]
    public IActionResult RelatorioProdutividade() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Relatório de Produtividade");

    [HttpGet("/relatorioefetivodiario/index")]
    public IActionResult RelatorioEfetivoDiario() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Relatório de Efetivo Diário");

    [HttpGet("/relatoriomedicao")]
    [HttpGet("/relatoriomedicao/index")]
    public IActionResult RelatorioMedicao() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Relatório de Medição");

    [HttpGet("/obra/lista")]
    public IActionResult ObraLista() =>
        Stub("Obra lista (legado)", "#/obra/lista", "Listagem legada `/obra/lista` — use Obras no drawer (`/Obra/Index`).", voltarUrl: "/Obra/Index");

    [HttpGet("/convidada")]
    public IActionResult Convidada() =>
        Stub("Convidada", "#/convidada", "Fluxo convidada (M7+).", voltarUrl: "/Account/Login");

    [HttpGet("/chart/rdos")]
    [HttpGet("/chart/atrasado")]
    [HttpGet("/chart/diaimprodutivo")]
    [HttpGet("/chart/tarefa")]
    [HttpGet("/chart/comentario")]
    public IActionResult ChartSubmodule() =>
        OperadorSpaEntry.ServeSpaIndex(this, _env, "Dashboard geral");

    // Não mapear GET /rdo/index → Redirect /Rdo/Index: rotas case-insensitive repetem 302 (F12 Location=/Rdo/Index).
    // Listagem RDO: RdoController.Index · P5a homolog-p5-rdo-tentativas.md

    private IActionResult Stub(string titulo, string prodRef, string descricao, string voltarUrl = "/Tarefa/Cards") =>
        EmMigracaoPage.Render(this, titulo, descricao, voltarUrl: voltarUrl, prodRef: prodRef);
}
