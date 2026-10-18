using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>
/// M2 — Cards data from homolog RDS (same connection as Core). Not prod API proxy.
/// </summary>
public class CardsQueryService
{
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

        var etapas = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdObra == obraId)
            .OrderBy(e => e.EtaNrOrderm)
            .ThenBy(e => e.EtaIdEtapa)
            .ToListAsync(cancellationToken);

        if (etapas.Count == 0)
        {
            return new CardsContextDto
            {
                ObraId = obraId,
                ObraNome = obraNome ?? "",
                Etapas = Array.Empty<EtapaComTarefasDto>()
            };
        }

        var etapaIds = etapas.Select(e => e.EtaIdEtapa).ToList();

        var tarefas = await _context.Tarefas.AsNoTracking()
            .Where(t => etapaIds.Contains(t.TarIdEtapa))
            .ToListAsync(cancellationToken);

        var statusIds = tarefas.Select(t => t.TarIdStatus).Distinct().ToList();
        var statusMap = await _context.StatusTarefas.AsNoTracking()
            .Where(s => statusIds.Contains(s.SttIdStatus))
            .ToDictionaryAsync(s => s.SttIdStatus, s => s.SttDsStatus, cancellationToken);

        var tarefasByEtapa = tarefas
            .GroupBy(t => t.TarIdEtapa)
            .ToDictionary(g => g.Key, g => g.ToList());

        var dtoEtapas = etapas.Select(e =>
        {
            tarefasByEtapa.TryGetValue(e.EtaIdEtapa, out var list);
            list ??= new List<Data.Entities.Tarefa>();

            return new EtapaComTarefasDto
            {
                Id = e.EtaIdEtapa,
                Titulo = e.EtaDsEtapa,
                Ordem = e.EtaNrOrderm,
                IdObra = e.EtaIdObra,
                TituloObra = obraNome,
                Tarefas = list.Select(t => new TarefaCardDto
                {
                    Id = t.TarIdTarefa,
                    Descricao = t.TarDsTarefa,
                    Status = t.TarIdStatus,
                    NomeStatus = statusMap.GetValueOrDefault(t.TarIdStatus, ""),
                    IdEtapa = t.TarIdEtapa
                }).ToList()
            };
        }).ToList();

        return new CardsContextDto
        {
            ObraId = obraId,
            ObraNome = obraNome ?? "",
            Etapas = dtoEtapas
        };
    }
}
