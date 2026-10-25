using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;

namespace RdoApp.Core.Controllers;

/// <summary>M4.7h — menu drawer: paths legado Angular → EmMigracao até M5/M7.</summary>
[Authorize]
public class ModuloLegadoController : Controller
{
    [HttpGet("/colaborador/index")]
    public IActionResult Colaborador() =>
        EmMigracaoPage.Render(this, "Colaboradores", "Listagem e cadastro de colaboradores (M7+).", prodRef: "#/colaborador/index");

    [HttpGet("/equipamento/index")]
    [HttpGet("/equipamentos/index")]
    public IActionResult Equipamentos() =>
        EmMigracaoPage.Render(this, "Equipamentos", "Marcas, modelos e equipamentos (M7+).", prodRef: "#/equipamento/index");

    [HttpGet("/empresa/index")]
    public IActionResult Empresa() =>
        EmMigracaoPage.Render(this, "Empresas", "Cadastro de empresas (M7+).", prodRef: "#/empresa/index");

    [HttpGet("/etapa/index")]
    public IActionResult Etapa() =>
        EmMigracaoPage.Render(this, "Etapas", "CRUD de etapas (M7+).", prodRef: "#/etapa/index");

    [HttpGet("/obra/index")]
    public IActionResult ObraLista() =>
        EmMigracaoPage.Render(this, "Obras", "Listagem de obras (M5+).", voltarUrl: "/Obra/Escolher", voltarRotulo: "Escolher obra", prodRef: "#/obra/index");

    [HttpGet("/pagina/index")]
    public IActionResult Pagina() =>
        EmMigracaoPage.Render(this, "Card de Tarefas", "Visão alternativa de tarefas (M7+).", prodRef: "#/pagina/index");
}
