using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

/// <summary>M4.7h / M5-nav — menu drawer: paths legado Angular → EmMigracao até M5/M7.</summary>
[Authorize]
public class ModuloLegadoController : Controller
{
    [HttpGet("/colaborador/index")]
    public IActionResult Colaborador() =>
        Stub("Colaboradores", "#/colaborador/index", "Listagem e cadastro de colaboradores (M7+).");

    [HttpGet("/colaborador/cadastro")]
    public IActionResult ColaboradorCadastro() =>
        Stub("Cadastro colaborador", "#/colaborador/cadastro", "Formulário colaborador (M7+).");

    [HttpGet("/equipamento/index")]
    [HttpGet("/equipamentos/index")]
    public IActionResult Equipamentos() =>
        Stub("Equipamentos", "#/equipamento/index", "Marcas, modelos e equipamentos (M7+).");

    [HttpGet("/equipamentos/cadastro")]
    [HttpGet("/equipamento/cadastro")]
    public IActionResult EquipamentosCadastro() =>
        Stub("Cadastro equipamento", "#/equipamentos/cadastro", "CRUD equipamento (M7+).");

    [HttpGet("/empresa/index")]
    public IActionResult Empresa() =>
        Stub("Empresas", "#/empresa/index", "Cadastro de empresas (M7+).");

    [HttpGet("/empresa/cadastro")]
    public IActionResult EmpresaCadastro() =>
        Stub("Cadastro empresa", "#/empresa/cadastro", "Formulário empresa (M7+).");

    [HttpGet("/etapa/index")]
    public IActionResult Etapa() =>
        Stub("Etapas", "#/etapa/index", "CRUD de etapas (M7+).");

    [HttpGet("/obra/index")]
    public IActionResult ObraLista() =>
        EmMigracaoPage.Render(
            this,
            "Obras",
            "Listagem de obras (M5+).",
            voltarUrl: "/Obra/Escolher",
            voltarRotulo: "Escolher obra",
            prodRef: "#/obra/index");

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

    [HttpGet("/relatorioprodutividade/index")]
    public IActionResult RelatorioProdutividade() =>
        Stub("Relatório produtividade", "#/relatorioprodutividade/index", "Relatórios (M7+).");

    [HttpGet("/relatorioefetivodiario/index")]
    public IActionResult RelatorioEfetivoDiario() =>
        Stub("Relatório efetivo diário", "#/relatorioefetivodiario/index", "Relatórios (M7+).");

    [HttpGet("/relatoriomedicao")]
    public IActionResult RelatorioMedicao() =>
        Stub("Relatório medição", "#/relatoriomedicao", "Relatórios (M7+).");

    [HttpGet("/convidada")]
    public IActionResult Convidada() =>
        Stub("Convidada", "#/convidada", "Fluxo convidada (M7+).", voltarUrl: "/Account/Login");

    [HttpGet("/chart/rdos")]
    [HttpGet("/chart/diaimprodutivo")]
    [HttpGet("/chart/tarefa")]
    [HttpGet("/chart/comentario")]
    public IActionResult ChartSubmodule() =>
        EmMigracaoPage.Render(
            this,
            "Dashboard geral (detalhe)",
            "Sub-rota do módulo Chart em migração (M5+).",
            voltarUrl: "/Chart/Index",
            voltarRotulo: "Dashboard geral",
            prodRef: "#/chart/*");

    // Não mapear GET /rdo/index → Redirect /Rdo/Index: rotas case-insensitive repetem 302 (F12 Location=/Rdo/Index).
    // Listagem RDO: RdoController.Index · P5a homolog-p5-rdo-tentativas.md

    private IActionResult Stub(string titulo, string prodRef, string descricao, string voltarUrl = "/Tarefa/Cards") =>
        EmMigracaoPage.Render(this, titulo, descricao, voltarUrl: voltarUrl, prodRef: prodRef);
}
