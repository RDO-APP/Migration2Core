using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Services;

/// <summary>Menu ☰ Empresas — listagem/filtros (paridade Empresa/index.html · EmpresaModel.Lista).</summary>
public class EmpresaIndexService
{
    private readonly RdoDbContext _context;

    public EmpresaIndexService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<EmpresaIndexBootstrapDto> BootstrapAsync(
        HttpContext httpContext,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        var ufs = await _context.UFs.AsNoTracking()
            .OrderBy(u => u.UfeDsSigla)
            .Select(u => new EmpresaIndexLookupDto { Id = u.UfeIdUf, Nome = u.UfeDsSigla ?? "" })
            .ToListAsync(cancellationToken);

        var ramos = await _context.Ramos.AsNoTracking()
            .OrderBy(r => r.RamDsRamo)
            .Select(r => new EmpresaIndexLookupDto { Id = r.RamIdRamo, Nome = r.RamDsRamo ?? "" })
            .ToListAsync(cancellationToken);

        var setores = await _context.Setores.AsNoTracking()
            .OrderBy(s => s.SetDsSetor)
            .Select(s => new EmpresaIndexLookupDto { Id = s.SetIdSetor, Nome = s.SetDsSetor ?? "" })
            .ToListAsync(cancellationToken);

        return new EmpresaIndexBootstrapDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Ufs = ufs,
            Ramos = ramos,
            Setores = setores,
            Permissions = new EmpresaIndexPermissionsDto
            {
                // Prod: permission="visualizarRegistro" sem permission-route → path atual /empresa/index
                ShowVisualizar = PermissionHelper.HasPermission(httpContext, "visualizarRegistro", "/empresa/index"),
            },
        };
    }

    public async Task<IReadOnlyList<EmpresaIndexLookupDto>> MunicipiosByUfAsync(
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
            .Select(m => new EmpresaIndexLookupDto { Id = m.MunIdMunicipio, Nome = m.MunDsMunicipio ?? "" })
            .ToListAsync(cancellationToken);
    }

    public async Task<EmpresaIndexListResponseDto> ListAsync(
        int colaboradorId,
        int obraId,
        EmpresaIndexFilterDto filter,
        string? obraNomeSessao,
        CancellationToken cancellationToken)
    {
        if (obraId <= 0)
        {
            return new EmpresaIndexListResponseDto { ObraNomeSessao = obraNomeSessao ?? "" };
        }

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrIdEmpresaContratante, o.ObrIdEmpresaContratada })
            .FirstOrDefaultAsync(cancellationToken);

        if (obra == null)
        {
            return new EmpresaIndexListResponseDto { ObraNomeSessao = obraNomeSessao ?? "" };
        }

        var empresaIds = new List<int>();
        if (obra.ObrIdEmpresaContratante is > 0)
        {
            empresaIds.Add(obra.ObrIdEmpresaContratante.Value);
        }

        if (obra.ObrIdEmpresaContratada is > 0
            && !empresaIds.Contains(obra.ObrIdEmpresaContratada.Value))
        {
            empresaIds.Add(obra.ObrIdEmpresaContratada.Value);
        }

        if (empresaIds.Count == 0)
        {
            return new EmpresaIndexListResponseDto { ObraNomeSessao = obraNomeSessao ?? "" };
        }

        var q =
            from e in _context.Empresas.AsNoTracking()
            join m in _context.Municipios.AsNoTracking() on e.EmpIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            join uf in _context.UFs.AsNoTracking() on (m != null ? m.MunIdUf : 0) equals uf.UfeIdUf into ufj
            from uf in ufj.DefaultIfEmpty()
            where empresaIds.Contains(e.EmpIdEmpresa)
            select new
            {
                e.EmpIdEmpresa,
                RazaoSocial = e.EmpDsRazaoSocial ?? "",
                NomeFantasia = e.EmpNmFantasia ?? "",
                Cnpj = e.EmpNrCnpj ?? "",
                e.EmpIdMunicipio,
                e.EmpIdRamo,
                e.EmpIdSetor,
                e.EmpIdColaborador,
                Telefone = e.EmpDsTelefone ?? "",
                MunIdUf = m != null ? m.MunIdUf : 0,
                Cidade = m != null ? m.MunDsMunicipio ?? "" : "",
                Uf = uf != null ? uf.UfeDsSigla ?? "" : "",
            };

        var razao = (filter.RazaoSocial ?? "").Trim();
        if (razao.Length > 0)
        {
            var lower = razao.ToLowerInvariant();
            q = q.Where(x => x.RazaoSocial.ToLower().Contains(lower));
        }

        var cnpjDigits = DigitsOnly(filter.Cnpj);
        if (cnpjDigits.Length > 0)
        {
            q = q.Where(x => x.Cnpj == cnpjDigits);
        }

        if (filter.IdUf > 0)
        {
            q = q.Where(x => x.MunIdUf == filter.IdUf);
        }

        if (filter.IdMunicipio > 0)
        {
            q = q.Where(x => x.EmpIdMunicipio == filter.IdMunicipio);
        }

        if (filter.IdRamo > 0)
        {
            q = q.Where(x => x.EmpIdRamo == filter.IdRamo);
        }

        if (filter.IdSetor > 0)
        {
            q = q.Where(x => x.EmpIdSetor == filter.IdSetor);
        }

        var rows = await q.OrderBy(x => x.NomeFantasia).ToListAsync(cancellationToken);
        var items = rows.Select(r =>
        {
            var local = string.IsNullOrEmpty(r.Cidade) && string.IsNullOrEmpty(r.Uf)
                ? ""
                : $"{r.Cidade}-{r.Uf}";
            return new EmpresaIndexItemDto
            {
                IdEmpresa = r.EmpIdEmpresa,
                RazaoSocial = r.RazaoSocial,
                NomeFantasia = r.NomeFantasia,
                Local = local,
                Telefone = r.Telefone,
                Editavel = r.EmpIdColaborador == colaboradorId,
            };
        }).ToList();

        return new EmpresaIndexListResponseDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Items = items,
        };
    }

    private static string DigitsOnly(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return "";
        }

        return new string(value.Where(char.IsDigit).ToArray());
    }
}
