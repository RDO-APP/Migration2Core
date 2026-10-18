using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Services;

/// <summary>
/// Loads route permissions and menu for a grupo — port of legacy LoginModel.ObterRotas / ObterMenu.
/// </summary>
public class RbacRouteService
{
    private readonly RdoDbContext _context;

    public RbacRouteService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<List<RouteViewModel>> GetRoutesForGroupAsync(int idGrupo, CancellationToken cancellationToken = default)
    {
        var rows = await (
            from gpa in _context.GrupoPaginaAcoes
            join pa in _context.PaginaAcoes on gpa.GpaIdPaginaAcao equals pa.PaaIdPaginaAcao
            join pag in _context.Paginas on pa.PaaIdPagina equals pag.PagIdPagina
            join ac in _context.Acoes on pa.PaaIdAcao equals ac.AcaIdAcao into acJoin
            from ac in acJoin.DefaultIfEmpty()
            where gpa.GpaIdGrupo == idGrupo
            select new
            {
                pag.PagDsUrl,
                pag.PagNmTitulo,
                Alias = ac != null ? ac.AcaDsAlias : string.Empty
            }).ToListAsync(cancellationToken);

        var routes = rows
            .Where(r => !string.IsNullOrWhiteSpace(r.PagDsUrl))
            .GroupBy(r => r.PagDsUrl!)
            .Select(g => new RouteViewModel
            {
                Name = g.First().PagNmTitulo ?? string.Empty,
                Path = g.Key,
                Permissions = g.Select(x => x.Alias).Where(a => !string.IsNullOrEmpty(a)).Distinct().ToList()
            })
            .ToList();

        AppendFixedRoutes(routes);
        return routes;
    }

    public async Task<MenuViewModel> GetMenuForGroupAsync(int idGrupo, CancellationToken cancellationToken = default)
    {
        var grupo = await _context.Grupos.AsNoTracking()
            .FirstOrDefaultAsync(g => g.GruIdGrupo == idGrupo, cancellationToken);

        if (grupo == null)
        {
            return new MenuViewModel();
        }

        var menu = await _context.Menus.AsNoTracking()
            .FirstOrDefaultAsync(m => m.MenIdMenu == grupo.GruIdMenu, cancellationToken);

        var menuPaginas = await (
            from mp in _context.MenuPaginas
            join p in _context.Paginas on mp.MpaIdPagina equals p.PagIdPagina
            where mp.MpaIdMenu == grupo.GruIdMenu
            orderby mp.MpaVlOrdem
            select new MenuPaginaRow(mp.MpaIdMenuPagina, mp.MpaIdPaginaPai, mp.MpaVlOrdem, mp.MpaDsClass, p.PagIdPagina, p.PagNmTitulo, p.PagDsUrl)
        ).ToListAsync(cancellationToken);

        var result = new MenuViewModel
        {
            Id = grupo.GruIdMenu,
            Titulo = menu?.MenNmTitulo ?? string.Empty,
            ListaPagina = new List<PaginaViewModel>()
        };

        foreach (var top in menuPaginas.Where(x => x.PaginaPaiId == null).OrderBy(x => x.Ordem))
        {
            var pai = new PaginaViewModel
            {
                Id = top.PaginaId,
                Titulo = top.Titulo,
                Caminho = top.Caminho,
                CssClass = top.CssClass,
                Paginas = GetChildPages(menuPaginas, top.MenuPaginaId)
            };
            result.ListaPagina.Add(pai);
        }

        return result;
    }

    private sealed record MenuPaginaRow(
        int MenuPaginaId,
        int? PaginaPaiId,
        int Ordem,
        string CssClass,
        int PaginaId,
        string Titulo,
        string Caminho);

    private static List<PaginaViewModel> GetChildPages(List<MenuPaginaRow> menuPaginas, int parentMenuPaginaId)
    {
        return menuPaginas
            .Where(m => m.PaginaPaiId == parentMenuPaginaId)
            .OrderBy(m => m.Ordem)
            .Select(m => new PaginaViewModel
            {
                Id = m.PaginaId,
                Titulo = m.Titulo,
                Caminho = m.Caminho,
                CssClass = m.CssClass,
                Paginas = new List<PaginaViewModel>()
            })
            .ToList();
    }

    private static void AppendFixedRoutes(List<RouteViewModel> routes)
    {
        void AddIfMissing(string path, string name, params string[] perms)
        {
            if (routes.Any(r => r.Path == path))
            {
                return;
            }

            routes.Add(new RouteViewModel
            {
                Name = name,
                Path = path,
                Permissions = perms.ToList()
            });
        }

        AddIfMissing("/convidada", "Convidada", "visualizar");
        AddIfMissing("/obra/escolher", "Escolher Obra", "visualizar");
        AddIfMissing("/tarefa/paralizacoes/index", "Códigos de Paralizações", "visualizar", "criarNovo", "editar", "deletar");
        AddIfMissing("/tarefa/paralizacoes/cadastro", "Cadastro Códigos de Paralizações");
    }
}
