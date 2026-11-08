using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M4.4 — lista obras do colaborador (paridade ObterObras / escolher.html).</summary>
public class ObrasQueryService
{
    private readonly RdoDbContext _context;

    public ObrasQueryService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<EscolherContextDto?> GetEscolherAsync(int colaboradorId, CancellationToken cancellationToken = default)
    {
        // Projeção estreita (mesmo padrão CardsQueryService / M2) — homol_rdoapp tem NULL em colunas string da entidade Obra.
        var rows = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join o in _context.Obras.AsNoTracking() on oc.OcoIdObra equals o.ObrIdObra
            join m in _context.Municipios.AsNoTracking() on o.ObrIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            join uf in _context.UFs.AsNoTracking() on m.MunIdUf equals uf.UfeIdUf into ufj
            from uf in ufj.DefaultIfEmpty()
            join g in _context.Grupos.AsNoTracking() on oc.OcoIdGrupo equals g.GruIdGrupo into gj
            from g in gj.DefaultIfEmpty()
            where oc.OcoIdColaborador == colaboradorId
            orderby o.ObrDsObra ?? string.Empty
            select new ObraEscolherRow
            {
                IdObra = o.ObrIdObra,
                Descricao = o.ObrDsObra ?? string.Empty,
                DtInicio = o.ObrDtInicio,
                DtPrevisaoFim = o.ObrDtPrevisaoFim,
                DtFim = o.ObrDtFim,
                Cidade = m != null ? m.MunDsMunicipio ?? string.Empty : string.Empty,
                UfSigla = uf != null ? uf.UfeDsSigla ?? string.Empty : string.Empty,
                GruStContratante = g != null ? g.GruStContratante : null,
                GruNmNome = g != null ? g.GruNmNome ?? string.Empty : string.Empty,
            }).ToListAsync(cancellationToken);

        if (rows.Count == 0)
        {
            return new EscolherContextDto
            {
                ColaboradorId = colaboradorId,
                Obras = Array.Empty<ObraListItemDto>(),
            };
        }

        var obraIds = rows.Select(r => r.IdObra).Distinct().ToList();
        var pendentePorObra = await ObraComTarefaPendentePosPrazoAsync(obraIds, cancellationToken);

        var obras = rows.Select(r =>
        {
            var progresso = ObraListParity.ProgressoPorcentagem(r.DtInicio, r.DtPrevisaoFim);
            pendentePorObra.TryGetValue(r.IdObra, out var pendente);
            var css = ObraListParity.ClasseStatusCss(progresso, pendente);
            var papel = ObraListParity.ContratanteContratadaIcon(r.GruStContratante);
            var licenca = r.GruNmNome.Trim();

            var cidadeEstado = string.IsNullOrEmpty(r.UfSigla)
                ? r.Cidade
                : $"{r.Cidade}/{r.UfSigla}";

            return new ObraListItemDto
            {
                IdColaborador = colaboradorId,
                IdObra = r.IdObra,
                Descricao = r.Descricao,
                CidadeEstado = cidadeEstado,
                ContratanteContratada = papel,
                StatusBasicaGratuita = licenca,
                ProgressoPorcentagem = progresso,
                ClasseStatusCss = css,
                ObraFinalizada = ObraListParity.ObraFinalizada(r.DtFim),
            };
        }).ToList();

        return new EscolherContextDto
        {
            ColaboradorId = colaboradorId,
            Obras = obras,
        };
    }


    /// <summary>Menu ☰ Obras — listagem do colaborador (paridade ObraModel.Lista parcial: filtro nome).</summary>
    public async Task<ObraIndexListResponseDto> ListIndexAsync(
        int colaboradorId,
        string? descricao,
        string? obraNomeSessao,
        CancellationToken cancellationToken = default)
    {
        var q =
            from oc in _context.ObraColaboradores.AsNoTracking()
            join o in _context.Obras.AsNoTracking() on oc.OcoIdObra equals o.ObrIdObra
            join m in _context.Municipios.AsNoTracking() on o.ObrIdMunicipio equals m.MunIdMunicipio into mj
            from m in mj.DefaultIfEmpty()
            join uf in _context.UFs.AsNoTracking() on (m != null ? m.MunIdUf : 0) equals uf.UfeIdUf into ufj
            from uf in ufj.DefaultIfEmpty()
            join ec in _context.Empresas.AsNoTracking() on o.ObrIdEmpresaContratante equals ec.EmpIdEmpresa into ecj
            from ec in ecj.DefaultIfEmpty()
            join ed in _context.Empresas.AsNoTracking() on o.ObrIdEmpresaContratada equals ed.EmpIdEmpresa into edj
            from ed in edj.DefaultIfEmpty()
            where oc.OcoIdColaborador == colaboradorId
            select new
            {
                o.ObrIdObra,
                Descricao = o.ObrDsObra ?? "",
                o.ObrDtInicio,
                o.ObrDtFim,
                Cidade = m != null ? m.MunDsMunicipio ?? "" : "",
                Uf = uf != null ? uf.UfeDsSigla ?? "" : "",
                Contratante = ec != null ? ec.EmpNmFantasia ?? "" : "",
                Contratada = ed != null ? ed.EmpNmFantasia ?? "" : "",
            };

        var filtro = (descricao ?? "").Trim();
        if (filtro.Length > 0)
        {
            var lower = filtro.ToLowerInvariant();
            q = q.Where(x => x.Descricao.ToLower().Contains(lower));
        }

        var rows = await q.OrderBy(x => x.Descricao).ToListAsync(cancellationToken);
        var hoje = DateTime.Now.Date;
        var items = rows.Select(r =>
        {
            var cidadeEstado = string.IsNullOrEmpty(r.Uf)
                ? r.Cidade
                : $"{r.Cidade}/{r.Uf}";
            var fim = r.ObrDtFim ?? DateTime.MinValue;
            var dias = fim == DateTime.MinValue
                ? (hoje - r.ObrDtInicio.Date).Days
                : (fim.Date - r.ObrDtInicio.Date).Days;
            return new ObraIndexItemDto
            {
                IdObra = r.ObrIdObra,
                Descricao = r.Descricao,
                DescricaoContratante = r.Contratante,
                DescricaoContratada = r.Contratada,
                DataInicio = r.ObrDtInicio.ToString("dd/MM/yyyy"),
                DataConclusao = r.ObrDtFim == null || r.ObrDtFim == DateTime.MinValue
                    ? ""
                    : r.ObrDtFim.Value.ToString("dd/MM/yyyy"),
                CidadeEstado = cidadeEstado,
                DiasDecorridos = dias,
            };
        }).ToList();

        return new ObraIndexListResponseDto
        {
            ObraNomeSessao = obraNomeSessao ?? "",
            Items = items,
        };
    }

    public async Task<ObraIndexActionResultDto> DeleteAsync(
        int colaboradorId,
        int idObra,
        CancellationToken cancellationToken = default)
    {
        var vinculado = await _context.ObraColaboradores.AsNoTracking()
            .AnyAsync(oc => oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == idObra, cancellationToken);
        if (!vinculado)
        {
            return new ObraIndexActionResultDto { Ok = false, ErrorMessage = "Obra não encontrada ou sem permissão." };
        }

        var entity = await _context.Obras.FirstOrDefaultAsync(o => o.ObrIdObra == idObra, cancellationToken);
        if (entity == null)
        {
            return new ObraIndexActionResultDto { Ok = false, ErrorMessage = "Obra não encontrada." };
        }

        _context.Obras.Remove(entity);
        try
        {
            await _context.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            return new ObraIndexActionResultDto
            {
                Ok = false,
                ErrorMessage = "Não é possível excluir esta obra. Existem registros dependentes.",
            };
        }

        return new ObraIndexActionResultDto { Ok = true };
    }

    private sealed class ObraEscolherRow
    {
        public int IdObra { get; init; }
        public string Descricao { get; init; } = string.Empty;
        public DateTime DtInicio { get; init; }
        public DateTime? DtPrevisaoFim { get; init; }
        public DateTime? DtFim { get; init; }
        public string Cidade { get; init; } = string.Empty;
        public string UfSigla { get; init; } = string.Empty;
        public int? GruStContratante { get; init; }
        public string GruNmNome { get; init; } = string.Empty;
    }

    /// <summary>Legado ObraModel.ClasseStatusCss — tarefas agrupador com status pendente quando progresso = 100%.</summary>
    private async Task<Dictionary<int, bool>> ObraComTarefaPendentePosPrazoAsync(
        IReadOnlyList<int> obraIds,
        CancellationToken cancellationToken)
    {
        var result = obraIds.ToDictionary(id => id, _ => false);
        if (obraIds.Count == 0)
        {
            return result;
        }

        var tarefas = await (
            from t in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            where obraIds.Contains(e.EtaIdObra)
            select new
            {
                e.EtaIdObra,
                t.TarNrAgrupador,
                t.TarIdStatus,
                t.TarDtMedicao,
                t.TarDtMedicaoHoraInicial,
                t.TarIdTarefa,
            }).ToListAsync(cancellationToken);

        foreach (var grp in tarefas.GroupBy(x => x.EtaIdObra))
        {
            var latestPerAgrupador = grp
                .GroupBy(x => x.TarNrAgrupador)
                .Select(g => g
                    .OrderByDescending(x => x.TarDtMedicao)
                    .ThenByDescending(x => x.TarDtMedicaoHoraInicial)
                    .First());

            var pendente = latestPerAgrupador.Any(t => t.TarIdStatus <= 2 || t.TarIdStatus == 4);
            result[grp.Key] = pendente;
        }

        return result;
    }
}
