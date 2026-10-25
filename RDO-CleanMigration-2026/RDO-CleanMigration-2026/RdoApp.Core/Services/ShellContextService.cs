using System.Text.Json;
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

        var menu = login?.Menu?.ListaPagina?
            .Where(p => !string.IsNullOrWhiteSpace(p.Titulo))
            .Select(p => new ShellNavItemDto
            {
                Titulo = p.Titulo ?? "",
                CssClass = string.IsNullOrWhiteSpace(p.CssClass) ? "fa fa-circle" : p.CssClass.Trim(),
                Href = MapLegacyPath(p.Caminho),
            })
            .ToList() ?? new List<ShellNavItemDto>();

        return new ShellContextDto
        {
            UsuarioNome = context.User.Identity?.Name ?? login?.Usuario?.NomeUsuario ?? "",
            ObraNome = ObraSessionHelper.GetObraNome(context),
            ObraCidadeEstado = ObraSessionHelper.GetObraCidadeEstado(context),
            ShowChart = PermissionHelper.HasPermission(context, "visualizar", "/chart"),
            ShowNovaObra = PermissionHelper.HasPermission(context, "visualizar", "/obra/cadastro"),
            ShowDashboardObra = PermissionHelper.HasPermission(context, "acessarDashboard", "/dashboard/index"),
            MenuPaginas = menu,
            AntiforgeryFieldName = tokens.FormFieldName,
            AntiforgeryToken = tokens.RequestToken,
        };
    }

    private static LoginViewModel? TryReadLogin(HttpContext context)
    {
        var json = context.Session.GetString(SessionKeys.LoginData);
        if (string.IsNullOrEmpty(json))
        {
            return null;
        }

        try
        {
            return JsonSerializer.Deserialize<LoginViewModel>(json);
        }
        catch (JsonException)
        {
            return null;
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
            _ when path.StartsWith('/') => path,
            _ => "#",
        };
    }
}
