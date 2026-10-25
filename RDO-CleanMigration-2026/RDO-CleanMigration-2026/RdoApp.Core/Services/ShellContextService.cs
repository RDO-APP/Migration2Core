using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Http;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

public class ShellContextService
{
    private readonly IAntiforgery _antiforgery;

    public ShellContextService(IAntiforgery antiforgery)
    {
        _antiforgery = antiforgery;
    }

    public ShellContextDto Build(HttpContext context)
    {
        var tokens = _antiforgery.GetAndStoreTokens(context);
        var login = TryReadLogin(context);

        var menu = FlattenMenuPages(login?.Menu?.ListaPagina)
            .Where(p => !string.IsNullOrWhiteSpace(p.Titulo))
            .Select(p => new ShellNavItemDto
            {
                Titulo = p.Titulo ?? "",
                CssClass = string.IsNullOrWhiteSpace(p.CssClass) ? "fa fa-circle" : p.CssClass.Trim(),
                Href = MapLegacyPath(p.Caminho),
            })
            .ToList();

        return new ShellContextDto
        {
            UsuarioNome = context.User.Identity?.Name ?? login?.Usuario?.NomeUsuario ?? "",
            ObraNome = ObraSessionHelper.GetObraNome(context),
            ObraCidadeEstado = ObraSessionHelper.GetObraCidadeEstado(context),
            ShowChart = PermissionHelper.HasPermission(context, "visualizar", "/chart"),
            ShowNovaObra = PermissionHelper.HasPermission(context, "visualizar", "/obra/cadastro"),
            ShowDashboardObra = PermissionHelper.HasPermission(context, "acessarDashboard", "/dashboard/index"),
            ShowGerarRdo = PermissionHelper.HasPermission(context, "gerarRdo", "/tarefa/cards"),
            ShowEditarObra = PermissionHelper.HasPermission(context, "editarObra", "/tarefa/cards"),
            MenuPaginas = menu,
            AntiforgeryFieldName = tokens.FormFieldName,
            AntiforgeryToken = tokens.RequestToken,
        };
    }

    private static LoginViewModel? TryReadLogin(HttpContext context)
    {
        var json = context.Session.GetString(SessionKeys.LoginData);
        return LoginSessionJson.TryDeserialize(json);
    }

    /// <summary>Prod Angular lista páginas folha; pais agrupadores só têm filhos em <see cref="PaginaViewModel.Paginas"/>.</summary>
    private static IEnumerable<PaginaViewModel> FlattenMenuPages(IEnumerable<PaginaViewModel>? tops)
    {
        if (tops == null)
        {
            yield break;
        }

        foreach (var top in tops)
        {
            if (top.Paginas is { Count: > 0 })
            {
                foreach (var child in top.Paginas.Where(c => !string.IsNullOrWhiteSpace(c.Titulo)))
                {
                    yield return child;
                }
            }
            else if (!string.IsNullOrWhiteSpace(top.Titulo))
            {
                yield return top;
            }
        }
    }

    /// <summary>Best-effort map Angular hash paths → Core MVC routes (homolog).</summary>
    private static string MapLegacyPath(string? caminho)
    {
        if (string.IsNullOrWhiteSpace(caminho))
        {
            return "#";
        }

        var path = caminho.Trim().ToLowerInvariant();
        return path switch
        {
            "/chart" or "/chart/index" => "/Chart",
            "/obra/cadastro" or "/obra/cadastro/index" => "/Obra/Cadastro",
            "/dashboard/index" => "/Dashboard",
            "/tarefa/cards" or "/tarefa/cards/index" => "/Tarefa/Cards",
            "/rdo/index" or "/rdo/listagem" => "/Rdo",
            "/efetivo/index" or "/efetivo" => "/Efetivo",
            "/tarefa/paralizacoes/index" or "/tarefa/paralizacoes/cadastro" => "/Tarefa/Paralizacoes",
            "/tarefa/index" => "/Tarefa/Index",
            "/colaborador/index" => "/colaborador/index",
            "/equipamento/index" or "/equipamentos/index" => "/equipamento/index",
            "/empresa/index" => "/empresa/index",
            "/etapa/index" => "/etapa/index",
            "/obra/index" => "/obra/index",
            "/pagina/index" => "/pagina/index",
            _ when path.StartsWith('/') => path,
            _ => "#",
        };
    }
}
