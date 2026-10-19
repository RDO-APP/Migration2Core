using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>
/// M2 — Cards data from homolog RDS (same connection as Core). Not prod API proxy.
/// Prod web reference: GET api/etapa/ObterEtapaTarefa (agrupador + filtros) — ver EtapaModel.ObterEtapaTarefa (EQ-L).
/// This BFF is a simplified read for EQ-R homolog; extend toward prod rules in M2+.
/// </summary>
public class CardsQueryService
{
    private sealed class TarefaRow
    {
        public int TarIdTarefa { get; init; }
        public string Descricao { get; init; } = string.Empty;
        public int TarIdStatus { get; init; }
        public int TarIdEtapa { get; init; }
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
                Descricao = t.TarDsTarefa ?? string.Empty,
                TarIdStatus = t.TarIdStatus,
                TarIdEtapa = t.TarIdEtapa
            })
            .ToListAsync(cancellationToken);

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

        var dtoEtapas = etapaRows.Select(e =>
        {
            tarefasByEtapa.TryGetValue(e.EtaIdEtapa, out var list);
            list ??= new List<TarefaRow>();

            return new EtapaComTarefasDto
            {
                Id = e.EtaIdEtapa,
                Titulo = e.Titulo,
                Ordem = e.EtaNrOrderm,
                IdObra = e.EtaIdObra,
                TituloObra = obraNome,
                Tarefas = list.Select(t => new TarefaCardDto
                {
                    Id = t.TarIdTarefa,
                    Descricao = t.Descricao,
                    Status = t.TarIdStatus,
                    NomeStatus = statusMap.GetValueOrDefault(t.TarIdStatus, string.Empty),
                    IdEtapa = t.TarIdEtapa
                }).ToList()
            };
        }).ToList();

        return new CardsContextDto
        {
            ObraId = obraId,
            ObraNome = obraNome ?? string.Empty,
            Etapas = dtoEtapas
        };
    }
}
