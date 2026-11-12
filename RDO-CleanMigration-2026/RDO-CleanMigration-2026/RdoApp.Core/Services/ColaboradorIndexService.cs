using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

/// <summary>Menu ☰ Colaboradores — listagem/filtros/ações (paridade Colaborador/index.html).</summary>
public class ColaboradorIndexService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;

    public ColaboradorIndexService(RdoDbContext context)
    {
        _context = context;
    }

    public static bool CanColaboradorIndex(HttpContext httpContext, string permission) =>
        PermissionHelper.HasPermission(httpContext, permission, "/colaborador/index");

    public async Task<ColaboradorIndexBootstrapDto> BootstrapAsync(
        HttpContext httpContext,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        var ufs = await _context.UFs.AsNoTracking()
            .OrderBy(u => u.UfeDsSigla)
            .Select(u => new ColaboradorIndexLookupDto { Id = u.UfeIdUf, Nome = u.UfeDsSigla ?? "" })
            .ToListAsync(cancellationToken);

        var cargos = await _context.Cargos.AsNoTracking()
            .OrderBy(c => c.CarDsCargo)
            .Select(c => new ColaboradorIndexLookupDto { Id = c.CarIdCargo, Nome = c.CarDsCargo ?? "" })
            .ToListAsync(cancellationToken);

        var grupos = await _context.Grupos.AsNoTracking()
            .OrderBy(g => g.GruNmNome)
            .Select(g => new ColaboradorIndexLookupDto { Id = g.GruIdGrupo, Nome = g.GruNmNome ?? "" })
            .ToListAsync(cancellationToken);

        var canEditar = CanColaboradorIndex(httpContext, "editar");
        return new ColaboradorIndexBootstrapDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Ufs = ufs,
            Cargos = cargos,
            Grupos = grupos,
            Permissions = new ColaboradorIndexPermissionsDto
            {
                ShowVisualizar = CanColaboradorIndex(httpContext, "visualizarRegistro"),
                ShowEditar = canEditar,
                ShowDeletar = CanColaboradorIndex(httpContext, "deletar"),
                ShowNovo = canEditar,
            },
        };
    }

    public async Task<IReadOnlyList<ColaboradorIndexLookupDto>> MunicipiosByUfAsync(
        int idUf,
        CancellationToken cancellationToken)
    {
        if (idUf <= 0)
        {
            return [];
        }

        return await _context.Municipios.AsNoTracking()
            .Where(m => m.MunIdUf == idUf)
            .OrderBy(m => m.MunDsMunicipio)
            .Select(m => new ColaboradorIndexLookupDto { Id = m.MunIdMunicipio, Nome = m.MunDsMunicipio ?? "" })
            .ToListAsync(cancellationToken);
    }

    public async Task<ColaboradorIndexListResponseDto> ListAsync(
        HttpContext httpContext,
        int obraId,
        ColaboradorIndexFilterDto filter,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        if (obraId <= 0)
        {
            return new ColaboradorIndexListResponseDto { ObraNomeSessao = obraNomeSessao ?? "" };
        }

        // Paridade legado: lista mesmo sem lado na sessão; editável/excluível fica restrito.
        var meuLado = LoginSessionHelper.GetContratanteContratadaUsuario(httpContext) ?? "";

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrIdObra, o.ObrIdColaborador })
            .FirstOrDefaultAsync(cancellationToken);

        if (obra == null)
        {
            return new ColaboradorIndexListResponseDto { ObraNomeSessao = obraNomeSessao ?? "" };
        }

        // Evita left-join triplo Cargo/Grupo/Município (Pomelo/EF 500 em homolog).
        // Mesmo padrão do cadastro: join OC+Colaborador + left Municipio; nomes via lookup.
        var q =
            from oc in _context.ObraColaboradores.AsNoTracking()
            join c in _context.Colaboradores.AsNoTracking() on oc.OcoIdColaborador equals c.ColIdColaborador
            join m in _context.Municipios.AsNoTracking() on c.ColIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            where oc.OcoIdObra == obraId
            select new
            {
                c.ColIdColaborador,
                Nome = c.ColNmColaborador ?? "",
                Cpf = c.ColNrCpf ?? "",
                Sexo = c.ColDsSexo ?? "",
                Email = c.ColDsEmail ?? "",
                Crea = c.ColDsCrea ?? "",
                Telefone = c.ColDsTelefonePrincipal ?? "",
                c.ColIdMunicipio,
                MunIdUf = m != null ? m.MunIdUf : 0,
                CargoId = oc.OcoIdCargo,
                GrupoId = oc.OcoIdGrupo,
                oc.OcoDtContratacao,
                Lado = oc.OcoStContratanteContratada ?? "",
            };

        var nome = (filter.Nome ?? "").Trim();
        if (nome.Length > 0)
        {
            var lower = nome.ToLowerInvariant();
            q = q.Where(x => x.Nome.ToLower().Contains(lower));
        }

        var cpfDigits = DigitsOnly(filter.Cpf);
        if (cpfDigits.Length > 0)
        {
            q = q.Where(x => x.Cpf == cpfDigits);
        }

        var sexo = (filter.Sexo ?? "S").Trim();
        if (!string.IsNullOrEmpty(sexo) && sexo != "S")
        {
            q = q.Where(x => x.Sexo == sexo);
        }

        var email = (filter.Email ?? "").Trim();
        if (email.Length > 0)
        {
            var lower = email.ToLowerInvariant();
            q = q.Where(x => x.Email.ToLower().Contains(lower));
        }

        var crea = (filter.Crea ?? "").Trim();
        if (crea.Length > 0)
        {
            var lower = crea.ToLowerInvariant();
            q = q.Where(x => x.Crea != null && x.Crea.ToLower().Contains(lower));
        }

        if (filter.IdUf > 0)
        {
            q = q.Where(x => x.MunIdUf == filter.IdUf);
        }

        if (filter.IdMunicipio > 0)
        {
            q = q.Where(x => x.ColIdMunicipio == filter.IdMunicipio);
        }

        if (filter.IdCargo > 0)
        {
            q = q.Where(x => x.CargoId == filter.IdCargo);
        }

        if (filter.IdGrupo > 0)
        {
            q = q.Where(x => x.GrupoId == filter.IdGrupo);
        }

        if (TryParseDate(filter.DataContratacao, out var dataContrato))
        {
            q = q.Where(x => x.OcoDtContratacao != null && x.OcoDtContratacao.Value.Date == dataContrato);
        }

        var rows = await q.OrderBy(x => x.Nome).ToListAsync(cancellationToken);

        var cargoIds = rows.Select(r => r.CargoId).Where(id => id > 0).Distinct().ToList();
        var grupoIds = rows.Select(r => r.GrupoId).Where(id => id > 0).Distinct().ToList();

        var cargoNomes = cargoIds.Count == 0
            ? new Dictionary<int, string>()
            : await _context.Cargos.AsNoTracking()
                .Where(c => cargoIds.Contains(c.CarIdCargo))
                .ToDictionaryAsync(c => c.CarIdCargo, c => c.CarDsCargo ?? "", cancellationToken);

        var grupoNomes = grupoIds.Count == 0
            ? new Dictionary<int, string>()
            : await _context.Grupos.AsNoTracking()
                .Where(g => grupoIds.Contains(g.GruIdGrupo))
                .ToDictionaryAsync(g => g.GruIdGrupo, g => g.GruNmNome ?? "", cancellationToken);

        var criadorObra = obra.ObrIdColaborador;
        var items = rows.Select(r =>
        {
            var mesmoLado = r.Lado == meuLado || string.IsNullOrEmpty(r.Lado);
            return new ColaboradorIndexItemDto
            {
                IdColaborador = r.ColIdColaborador,
                Nome = r.Nome,
                DescricaoCargo = cargoNomes.TryGetValue(r.CargoId, out var cargoNome) ? cargoNome : "",
                TelefonePrincipal = FormatPhone(r.Telefone),
                Email = r.Email,
                DescricaoGrupo = grupoNomes.TryGetValue(r.GrupoId, out var grupoNome) ? grupoNome : "",
                Editavel = mesmoLado,
                Excluivel = mesmoLado && criadorObra != r.ColIdColaborador,
            };
        }).ToList();

        return new ColaboradorIndexListResponseDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Items = items,
        };
    }

    public async Task<ColaboradorIndexActionResultDto> DeleteAsync(
        HttpContext httpContext,
        int colaboradorId,
        int obraId,
        CancellationToken cancellationToken)
    {
        if (colaboradorId <= 0 || obraId <= 0)
        {
            return new ColaboradorIndexActionResultDto { Ok = false, ErrorMessage = "Colaborador inválido." };
        }

        var meuLado = LoginSessionHelper.GetContratanteContratadaUsuario(httpContext);
        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrIdColaborador })
            .FirstOrDefaultAsync(cancellationToken);

        if (obra == null)
        {
            return new ColaboradorIndexActionResultDto { Ok = false, ErrorMessage = "Obra não encontrada." };
        }

        if (obra.ObrIdColaborador == colaboradorId)
        {
            return new ColaboradorIndexActionResultDto { Ok = false, ErrorMessage = "Não é possível excluir o criador da obra." };
        }

        var links = await _context.ObraColaboradores
            .Where(oc => oc.OcoIdObra == obraId && oc.OcoIdColaborador == colaboradorId)
            .ToListAsync(cancellationToken);

        if (links.Count == 0)
        {
            return new ColaboradorIndexActionResultDto { Ok = false, ErrorMessage = "Colaborador não está nesta obra." };
        }

        if (!string.IsNullOrEmpty(meuLado)
            && links.Any(l => !string.IsNullOrEmpty(l.OcoStContratanteContratada)
                && l.OcoStContratanteContratada != meuLado))
        {
            return new ColaboradorIndexActionResultDto { Ok = false, ErrorMessage = "Sem permissão para excluir este colaborador." };
        }

        _context.ObraColaboradores.RemoveRange(links);
        await _context.SaveChangesAsync(cancellationToken);
        return new ColaboradorIndexActionResultDto { Ok = true };
    }

    private static string DigitsOnly(string? value) =>
        string.IsNullOrWhiteSpace(value) ? "" : new string(value.Where(char.IsDigit).ToArray());

    private static bool TryParseDate(string? raw, out DateTime date)
    {
        date = default;
        if (string.IsNullOrWhiteSpace(raw))
        {
            return false;
        }

        return DateTime.TryParseExact(raw.Trim(), "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date);
    }

    private static string FormatPhone(string? raw)
    {
        var d = DigitsOnly(raw);
        if (d.Length == 11)
        {
            return $"({d[..2]}) {d[2..7]}-{d[7..]}";
        }

        if (d.Length == 10)
        {
            return $"({d[..2]}) {d[2..6]}-{d[6..]}";
        }

        return raw?.Trim() ?? "";
    }
}
