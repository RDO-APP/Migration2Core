using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;
using static RdoApp.Core.Services.CardsTarefaParity;

namespace RdoApp.Core.Services;

/// <summary>
/// M2 — Cards data from homolog RDS (same connection as Core). Not prod API proxy.
/// Prod web reference: GET api/etapa/ObterEtapaTarefa — EtapaModel.ObterEtapaTarefa (EQ-L).
/// Agrupador: GroupBy tar_nr_agrupador + current row (M2.1 C1).
/// </summary>
public class CardsQueryService
{
    private sealed class TarefaRow
    {
        public int TarIdTarefa { get; init; }
        public Guid TarNrAgrupador { get; init; }
        public string Descricao { get; init; } = string.Empty;
        public int TarIdStatus { get; init; }
        public int TarIdEtapa { get; init; }
        public DateTime TarDtInicio { get; init; }
        public DateTime? TarDtPrevisaoFim { get; init; }
        public DateTime TarDtMedicao { get; init; }
        public TimeSpan? TarDtMedicaoHoraInicial { get; init; }
        public TimeSpan? TarDtMedicaoHoraFinal { get; init; }
    }

    private readonly RdoDbContext _context;

    public CardsQueryService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<CardsContextDto?> GetCardsForObraAsync(int obraId, string? obraNome, CancellationToken cancellationToken = default)
    {
        var obraExists = await _context.Obras.AsNoTracking()
            .AnyAsync(o => o.ObrIdObra == obraId, cancellationToken);
        if (!obraExists)
        {
            return null;
        }

        var etapaRows = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdObra == obraId)
            .OrderBy(e => e.EtaNrOrderm)
            .ThenBy(e => e.EtaIdEtapa)
            .Select(e => new
            {
                e.EtaIdEtapa,
                Titulo = e.EtaDsEtapa ?? string.Empty,
                e.EtaNrOrderm,
                e.EtaIdObra
            })
            .ToListAsync(cancellationToken);

        if (etapaRows.Count == 0)
        {
            return new CardsContextDto
            {
                ObraId = obraId,
                ObraNome = obraNome ?? string.Empty,
                Etapas = Array.Empty<EtapaComTarefasDto>()
            };
        }

        var etapaIds = etapaRows.Select(e => e.EtaIdEtapa).ToList();

        var tarefaRows = await _context.Tarefas.AsNoTracking()
            .Where(t => etapaIds.Contains(t.TarIdEtapa))
            .Select(t => new TarefaRow
            {
                TarIdTarefa = t.TarIdTarefa,
                TarNrAgrupador = t.TarNrAgrupador,
                Descricao = t.TarDsTarefa ?? string.Empty,
                TarIdStatus = t.TarIdStatus,
                TarIdEtapa = t.TarIdEtapa,
                TarDtInicio = t.TarDtInicio,
                TarDtPrevisaoFim = t.TarDtPrevisaoFim,
                TarDtMedicao = t.TarDtMedicao,
                TarDtMedicaoHoraInicial = t.TarDtMedicaoHoraInicial,
                TarDtMedicaoHoraFinal = t.TarDtMedicaoHoraFinal
            })
            .ToListAsync(cancellationToken);

        var periodosPorAgrupador = await LoadPeriodosExecucaoAsync(
            tarefaRows.Select(t => t.TarNrAgrupador).Distinct(),
            cancellationToken);

        var statusIds = tarefaRows.Select(t => t.TarIdStatus).Distinct().ToList();
        var statusMap = statusIds.Count == 0
            ? new Dictionary<int, string>()
            : await _context.StatusTarefas.AsNoTracking()
                .Where(s => statusIds.Contains(s.SttIdStatus))
                .Select(s => new { s.SttIdStatus, Nome = s.SttDsStatus ?? string.Empty })
                .ToDictionaryAsync(x => x.SttIdStatus, x => x.Nome, cancellationToken);

        var tarefasByEtapa = tarefaRows
            .GroupBy(t => t.TarIdEtapa)
            .ToDictionary(g => g.Key, g => g.ToList());

        var dtoEtapas = new List<EtapaComTarefasDto>();

        foreach (var e in etapaRows)
        {
            if (!tarefasByEtapa.TryGetValue(e.EtaIdEtapa, out var list) || list.Count == 0)
            {
                continue;
            }

            var cards = SelectCurrentTarefaPerAgrupador(list);
            if (cards.Count == 0)
            {
                continue;
            }

            dtoEtapas.Add(new EtapaComTarefasDto
            {
                Id = e.EtaIdEtapa,
                Titulo = e.Titulo,
                Ordem = e.EtaNrOrderm,
                IdObra = e.EtaIdObra,
                TituloObra = obraNome,
                Tarefas = cards.Select(t => MapTarefaCard(t, statusMap, periodosPorAgrupador)).ToList()
            });
        }

        return new CardsContextDto
        {
            ObraId = obraId,
            ObraNome = obraNome ?? string.Empty,
            Etapas = dtoEtapas
        };
    }

    /// <summary>
    /// Mirrors EtapaModel.ObterEtapaTarefa: one card per agrupador (status/medicao atual).
    /// </summary>
    private static List<TarefaRow> SelectCurrentTarefaPerAgrupador(IEnumerable<TarefaRow> rows)
    {
        return rows
            .GroupBy(t => t.TarNrAgrupador)
            .Select(g => g
                .OrderByDescending(t => t.TarIdTarefa)
                .ThenByDescending(t => t.TarDtMedicao)
                .ThenByDescending(t => t.TarDtMedicaoHoraFinal ?? TimeSpan.Zero)
                .First())
            .ToList();
    }

    private async Task<IReadOnlyDictionary<Guid, PeriodoExecucao>> LoadPeriodosExecucaoAsync(
        IEnumerable<Guid> agrupadorIds,
        CancellationToken cancellationToken)
    {
        var ids = agrupadorIds.Distinct().ToList();
        if (ids.Count == 0)
        {
            return new Dictionary<Guid, PeriodoExecucao>();
        }

        var rows = await _context.Tarefas.AsNoTracking()
            .Where(t => ids.Contains(t.TarNrAgrupador))
            .GroupBy(t => t.TarNrAgrupador)
            .Select(g => new
            {
                Agrupador = g.Key,
                PrimeiroDia = g.Min(t => t.TarDtMedicao),
                UltimoDia = g.Max(t => t.TarDtMedicao)
            })
            .ToListAsync(cancellationToken);

        return rows.ToDictionary(
            x => x.Agrupador,
            x => new PeriodoExecucao { PrimeiroDia = x.PrimeiroDia, UltimoDia = x.UltimoDia });
    }

    private static TarefaCardDto MapTarefaCard(
        TarefaRow row,
        IReadOnlyDictionary<int, string> statusMap,
        IReadOnlyDictionary<Guid, PeriodoExecucao> periodosPorAgrupador)
    {
        periodosPorAgrupador.TryGetValue(row.TarNrAgrupador, out var periodo);
        var entity = new Tarefa
        {
            TarIdStatus = row.TarIdStatus,
            TarDtInicio = row.TarDtInicio,
            TarDtPrevisaoFim = row.TarDtPrevisaoFim,
            TarDtMedicaoHoraInicial = row.TarDtMedicaoHoraInicial,
            TarDtMedicaoHoraFinal = row.TarDtMedicaoHoraFinal
        };

        var percentual = CalcularPercentualConcluido(entity, periodo);
        var percentualCap = percentual > 100 ? 100 : percentual;

        return new TarefaCardDto
        {
            Id = row.TarIdTarefa,
            Descricao = row.Descricao,
            Status = row.TarIdStatus,
            NomeStatus = statusMap.GetValueOrDefault(row.TarIdStatus, string.Empty),
            IdEtapa = row.TarIdEtapa,
            DataInicio = FormatDate(row.TarDtInicio),
            DataPrevisaoFim = FormatDate(row.TarDtPrevisaoFim),
            PercentualConcluido = percentualCap,
            PercentualExtrapolado = percentual > 100 ? "false" : "true",
            ClasseStatusCss = ClasseStatusCss(row.TarIdStatus)
        };
    }
}
