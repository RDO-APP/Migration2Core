using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M5 web — paridade prod <c>RdoModel.Lista</c> (homol_rdoapp).</summary>
public class RdoListQueryService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private const int DefaultPageSize = 10;

    private readonly RdoDbContext _context;

    public RdoListQueryService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<IReadOnlyList<RdoStatusOptionDto>> GetStatusOptionsAsync(CancellationToken cancellationToken = default)
    {
        return await _context.StatusRdos.AsNoTracking()
            .OrderBy(s => s.StrIdStatus)
            .Select(s => new RdoStatusOptionDto { Id = s.StrIdStatus, Nome = s.StrDsStatus })
            .ToListAsync(cancellationToken);
    }

    public async Task<RdoListPageDto> GetListAsync(
        int obraId,
        string? obraNome,
        int page,
        int statusRdo,
        DateTime? dataInicial,
        DateTime? dataFinal,
        CancellationToken cancellationToken = default)
    {
        page = Math.Max(1, page);

        var obraFim = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => o.ObrDtFim)
            .FirstOrDefaultAsync(cancellationToken);
        var obraFinalizada = obraFim.HasValue && obraFim.Value.Date != DateTime.MinValue.Date;

        var query = _context.Rdos.AsNoTracking().Where(r => r.RdoIdObra == obraId);

        if (statusRdo > 0)
        {
            query = query.Where(r => r.RdoIdStatus == statusRdo);
        }

        if (dataInicial.HasValue)
        {
            var d0 = dataInicial.Value.Date;
            query = query.Where(r => r.RdoDtRdo >= d0);
        }

        if (dataFinal.HasValue)
        {
            var d1 = dataFinal.Value.Date;
            query = query.Where(r => r.RdoDtRdo <= d1);
        }

        var total = await query.CountAsync(cancellationToken);
        var totalPages = total == 0 ? 1 : (int)Math.Ceiling(total / (double)DefaultPageSize);

        var rows = await (
            from r in query
            join s in _context.StatusRdos.AsNoTracking() on r.RdoIdStatus equals s.StrIdStatus
            orderby r.RdoDtRdo descending
            select new { r.RdoIdRdo, r.RdoDtRdo, r.RdoIdStatus, s.StrDsStatus }
        ).Skip((page - 1) * DefaultPageSize).Take(DefaultPageSize).ToListAsync(cancellationToken);

        var rdoIds = rows.Select(x => x.RdoIdRdo).ToList();
        var qtdTarefasByRdo = await GetQtdTarefasByRdoAsync(rdoIds, cancellationToken);
        var qtdColabByRdo = await GetQtdColaboradoresByRdoAsync(rdoIds, cancellationToken);
        var qtdEquipByRdo = await GetQtdEquipamentosByRdoAsync(rdoIds, cancellationToken);

        var items = rows.Select(r =>
        {
            var dt = r.RdoDtRdo.Date;
            return new RdoListItemDto
            {
                IdRdo = r.RdoIdRdo,
                DataRdo = dt.ToString("dd/MM/yyyy"),
                DiaDaSemana = PtBr.DateTimeFormat.GetDayName(dt.DayOfWeek),
                StatusRdo = r.RdoIdStatus,
                DescricaoStatus = r.StrDsStatus,
                QtdTarefas = qtdTarefasByRdo.GetValueOrDefault(r.RdoIdRdo, 0),
                QtdColaboradores = qtdColabByRdo.GetValueOrDefault(r.RdoIdRdo, 0),
                QtdMaquinas = qtdEquipByRdo.GetValueOrDefault(r.RdoIdRdo, 0),
            };
        }).ToList();

        return new RdoListPageDto
        {
            CurrentPage = page,
            PageSize = DefaultPageSize,
            TotalPages = totalPages,
            TotalCount = total,
            Items = items,
            ObraNome = obraNome ?? "",
            ObraFinalizada = obraFinalizada,
        };
    }

    private async Task<Dictionary<int, int>> GetQtdTarefasByRdoAsync(List<int> rdoIds, CancellationToken cancellationToken)
    {
        if (rdoIds.Count == 0)
        {
            return new Dictionary<int, int>();
        }

        var pairs = await (
            from rt in _context.RdoTarefas.AsNoTracking()
            join t in _context.Tarefas.AsNoTracking() on rt.RtaIdTarefa equals t.TarIdTarefa
            where rdoIds.Contains(rt.RtaIdRdo)
            select new { rt.RtaIdRdo, t.TarNrAgrupador }
        ).ToListAsync(cancellationToken);

        return pairs
            .GroupBy(x => x.RtaIdRdo)
            .ToDictionary(g => g.Key, g => g.Select(x => x.TarNrAgrupador).Distinct().Count());
    }

    private async Task<Dictionary<int, int>> GetQtdColaboradoresByRdoAsync(List<int> rdoIds, CancellationToken cancellationToken)
    {
        if (rdoIds.Count == 0)
        {
            return new Dictionary<int, int>();
        }

        var pairs = await (
            from rt in _context.RdoTarefas.AsNoTracking()
            join otc in _context.ObraTarefaColaboradores.AsNoTracking() on rt.RtaIdTarefa equals otc.OtcIdTarefa
            join oc in _context.ObraColaboradores.AsNoTracking() on otc.OtcIdObraColaborador equals oc.OcoIdObraColaborador
            where rdoIds.Contains(rt.RtaIdRdo)
            select new { rt.RtaIdRdo, oc.OcoIdColaborador }
        ).ToListAsync(cancellationToken);

        return pairs
            .GroupBy(x => x.RtaIdRdo)
            .ToDictionary(g => g.Key, g => g.Select(x => x.OcoIdColaborador).Distinct().Count());
    }

    private async Task<Dictionary<int, int>> GetQtdEquipamentosByRdoAsync(List<int> rdoIds, CancellationToken cancellationToken)
    {
        if (rdoIds.Count == 0)
        {
            return new Dictionary<int, int>();
        }

        var counts = await (
            from rt in _context.RdoTarefas.AsNoTracking()
            join ote in _context.ObraTarefaEquipamentos.AsNoTracking() on rt.RtaIdTarefa equals ote.OteIdTarefa
            where rdoIds.Contains(rt.RtaIdRdo)
            group ote by rt.RtaIdRdo into g
            select new { RdoId = g.Key, Count = g.Count() }
        ).ToListAsync(cancellationToken);

        return counts.ToDictionary(x => x.RdoId, x => x.Count);
    }
}
