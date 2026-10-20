using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
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
        var rows = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join o in _context.Obras.AsNoTracking() on oc.OcoIdObra equals o.ObrIdObra
            join m in _context.Municipios.AsNoTracking() on o.ObrIdMunicipio equals m.MunIdMunicipio
            join uf in _context.UFs.AsNoTracking() on m.MunIdUf equals uf.UfeIdUf
            join g in _context.Grupos.AsNoTracking() on oc.OcoIdGrupo equals g.GruIdGrupo into gj
            from g in gj.DefaultIfEmpty()
            where oc.OcoIdColaborador == colaboradorId
            orderby o.ObrDsObra
            select new
            {
                Obra = o,
                Cidade = m.MunDsMunicipio,
                UfSigla = uf.UfeDsSigla,
                Grupo = g,
            }).ToListAsync(cancellationToken);

        if (rows.Count == 0)
        {
            return new EscolherContextDto
            {
                ColaboradorId = colaboradorId,
                Obras = Array.Empty<ObraListItemDto>(),
            };
        }

        var obraIds = rows.Select(r => r.Obra.ObrIdObra).Distinct().ToList();
        var pendentePorObra = await ObraComTarefaPendentePosPrazoAsync(obraIds, cancellationToken);

        var obras = rows.Select(r =>
        {
            var progresso = ObraListParity.ProgressoPorcentagem(r.Obra);
            pendentePorObra.TryGetValue(r.Obra.ObrIdObra, out var pendente);
            var css = ObraListParity.ClasseStatusCss(r.Obra, progresso, pendente);
            var papel = ObraListParity.ContratanteContratadaIcon(r.Grupo);
            var licenca = r.Grupo?.GruNmNome?.Trim() ?? "";

            return new ObraListItemDto
            {
                IdColaborador = colaboradorId,
                IdObra = r.Obra.ObrIdObra,
                Descricao = r.Obra.ObrDsObra ?? "",
                CidadeEstado = $"{r.Cidade}/{r.UfSigla}",
                ContratanteContratada = papel,
                StatusBasicaGratuita = licenca,
                ProgressoPorcentagem = progresso,
                ClasseStatusCss = css,
                ObraFinalizada = ObraListParity.ObraFinalizada(r.Obra),
            };
        }).ToList();

        return new EscolherContextDto
        {
            ColaboradorId = colaboradorId,
            Obras = obras,
        };
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
