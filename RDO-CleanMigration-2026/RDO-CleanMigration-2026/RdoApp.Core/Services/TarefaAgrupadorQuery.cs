using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;

namespace RdoApp.Core.Services;

/// <summary>
/// Projeção enxuta de <c>tarefa</c> (evita materializar entidade completa no RDS homolog).
/// </summary>
internal sealed class TarefaAgrupadorRow
{
    public int TarIdTarefa { get; init; }
    public Guid TarNrAgrupador { get; init; }
    public string Descricao { get; init; } = string.Empty;
    public int TarIdStatus { get; init; }
    public int TarIdEtapa { get; init; }
    public DateTime TarDtInicio { get; init; }
    public DateTime TarDtMedicao { get; init; }
    public TimeSpan? TarDtMedicaoHoraInicial { get; init; }
    public TimeSpan? TarDtMedicaoHoraFinal { get; init; }
}

internal static class TarefaAgrupadorQuery
{
    internal const int StatusPlanejada = 1;

    internal static async Task<List<TarefaAgrupadorRow>> LoadByEtapaIdsAsync(
        RdoDbContext context,
        IReadOnlyList<int> etapaIds,
        CancellationToken cancellationToken = default)
    {
        if (etapaIds.Count == 0)
        {
            return new List<TarefaAgrupadorRow>();
        }

        return await context.Tarefas.AsNoTracking()
            .Where(t => etapaIds.Contains(t.TarIdEtapa))
            .Select(t => new TarefaAgrupadorRow
            {
                TarIdTarefa = t.TarIdTarefa,
                TarNrAgrupador = t.TarNrAgrupador,
                Descricao = t.TarDsTarefa ?? string.Empty,
                TarIdStatus = t.TarIdStatus,
                TarIdEtapa = t.TarIdEtapa,
                TarDtInicio = t.TarDtInicio,
                TarDtMedicao = t.TarDtMedicao,
                TarDtMedicaoHoraInicial = t.TarDtMedicaoHoraInicial,
                TarDtMedicaoHoraFinal = t.TarDtMedicaoHoraFinal,
            })
            .ToListAsync(cancellationToken);
    }

    internal static async Task<List<TarefaAgrupadorRow>> LoadByObraIdAsync(
        RdoDbContext context,
        int obraId,
        CancellationToken cancellationToken = default)
    {
        return await (
            from t in context.Tarefas.AsNoTracking()
            join e in context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            where e.EtaIdObra == obraId
            select new TarefaAgrupadorRow
            {
                TarIdTarefa = t.TarIdTarefa,
                TarNrAgrupador = t.TarNrAgrupador,
                Descricao = t.TarDsTarefa ?? string.Empty,
                TarIdStatus = t.TarIdStatus,
                TarIdEtapa = t.TarIdEtapa,
                TarDtInicio = t.TarDtInicio,
                TarDtMedicao = t.TarDtMedicao,
                TarDtMedicaoHoraInicial = t.TarDtMedicaoHoraInicial,
                TarDtMedicaoHoraFinal = t.TarDtMedicaoHoraFinal,
            }).ToListAsync(cancellationToken);
    }

    /// <summary>M7 RDO — <c>EtapaModel.ObterEtapasParaRDO</c>.</summary>
    internal static List<TarefaAgrupadorRow> SelectRepresentantesParaRdo(IEnumerable<TarefaAgrupadorRow> rowsInEtapa) =>
        rowsInEtapa
            .Where(t => t.TarIdStatus != StatusPlanejada)
            .GroupBy(t => t.TarNrAgrupador)
            .Select(g => g
                .OrderByDescending(t => t.TarIdTarefa)
                .ThenByDescending(t => t.TarDtMedicao)
                .ThenByDescending(t => t.TarDtMedicaoHoraInicial ?? TimeSpan.Zero)
                .First())
            .Where(t => t.TarIdStatus != StatusPlanejada)
            .OrderBy(t => t.TarIdStatus)
            .ThenBy(t => t.TarDtInicio)
            .ToList();
}
