using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

public class EfetivoQueryService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;
    public EfetivoQueryService(RdoDbContext context) => _context = context;

    public async Task<EfetivoBootstrapDto> GetBootstrapAsync(int obraId, string? obraNome, CancellationToken ct)
    {
        var ultima = await _context.Efetivos.AsNoTracking()
            .Where(e => e.EfeIdObra == obraId)
            .OrderByDescending(e => e.EfeData)
            .Select(e => (DateTime?)e.EfeData)
            .FirstOrDefaultAsync(ct);
        var data = (ultima ?? DateTime.Today).ToString("dd/MM/yyyy", PtBr);
        var cargos = await _context.Cargos.AsNoTracking().OrderBy(c => c.CarDsCargo)
            .Select(c => new EfetivoLookupDto { Id = c.CarIdCargo, Nome = c.CarDsCargo ?? "" }).ToListAsync(ct);
        var statuses = await _context.EfetivoStatuses.AsNoTracking().OrderBy(s => s.EstDsEfetivoStatus)
            .Select(s => new EfetivoLookupDto { Id = s.EstIdEfetivoStatus, Nome = s.EstDsEfetivoStatus ?? "", Cor = s.EstDsColor }).ToListAsync(ct);
        return new EfetivoBootstrapDto { DataPadrao = data, ObraNome = obraNome ?? "", Cargos = cargos, Statuses = statuses };
    }

    public async Task<EfetivoListDto> ListAsync(int obraId, string dataBr, string? nome, int cargoId, int statusId, CancellationToken ct)
    {
        if (!TryParseDate(dataBr, out var data)) throw new InvalidOperationException("A data e obrigatoria.");
        var day = data.Date;
        var nomeFiltro = (nome ?? "").Trim().ToLowerInvariant();
        var colabs = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join c in _context.Colaboradores.AsNoTracking() on oc.OcoIdColaborador equals c.ColIdColaborador
            join car in _context.Cargos.AsNoTracking() on oc.OcoIdCargo equals car.CarIdCargo into cars
            from car in cars.DefaultIfEmpty()
            where oc.OcoIdObra == obraId
            select new { oc.OcoIdObraColaborador, Nome = c.ColNmColaborador ?? "", CargoId = oc.OcoIdCargo, Cargo = car != null ? car.CarDsCargo ?? "" : "" }
        ).ToListAsync(ct);
        var existentes = await (
            from e in _context.Efetivos.AsNoTracking()
            join st in _context.EfetivoStatuses.AsNoTracking() on e.EfeIdEfetivoStatus equals st.EstIdEfetivoStatus
            where e.EfeIdObra == obraId && e.EfeData.Date == day
            select new { e.EfeIdEfetivo, e.EfeIdObraColaborador, e.EfeIdEfetivoStatus, NomeStatus = st.EstDsEfetivoStatus ?? "", Cor = st.EstDsColor }
        ).ToListAsync(ct);
        var byOc = existentes.ToDictionary(x => x.EfeIdObraColaborador);
        var items = new List<EfetivoItemDto>();
        foreach (var oc in colabs.OrderBy(x => x.Nome))
        {
            if (cargoId > 0 && oc.CargoId != cargoId) continue;
            if (nomeFiltro.Length > 0 && !oc.Nome.ToLowerInvariant().Contains(nomeFiltro)) continue;
            byOc.TryGetValue(oc.OcoIdObraColaborador, out var ex);
            var idStatus = ex?.EfeIdEfetivoStatus ?? 0;
            if (statusId > 0 && idStatus != statusId) continue;
            items.Add(new EfetivoItemDto
            {
                IdEfetivo = ex?.EfeIdEfetivo ?? -oc.OcoIdObraColaborador,
                IdObraColaborador = oc.OcoIdObraColaborador,
                Data = day.ToString("dd/MM/yyyy", PtBr),
                NomeColaborador = oc.Nome,
                Cargo = oc.Cargo,
                IdStatus = idStatus,
                NomeStatus = ex?.NomeStatus ?? "",
                Cor = ex?.Cor
            });
        }
        return new EfetivoListDto { Items = items };
    }

    public async Task<EfetivoStatusUpdateResultDto> UpdateStatusAsync(int obraId, EfetivoStatusUpdateRequestDto request, CancellationToken ct)
    {
        if (!TryParseDate(request.Data, out var data))
            return new EfetivoStatusUpdateResultDto { Ok = false, ErrorMessage = "Data invalida." };
        var day = data.Date;
        var ocOk = await _context.ObraColaboradores.AsNoTracking()
            .AnyAsync(x => x.OcoIdObraColaborador == request.IdObraColaborador && x.OcoIdObra == obraId, ct);
        if (!ocOk) return new EfetivoStatusUpdateResultDto { Ok = false, ErrorMessage = "Colaborador nao pertence a obra." };

        if (request.IdStatus <= 0)
        {
            if (request.IdEfetivo > 0)
            {
                var del = await _context.Efetivos.FirstOrDefaultAsync(e => e.EfeIdEfetivo == request.IdEfetivo && e.EfeIdObra == obraId, ct);
                if (del != null) { _context.Efetivos.Remove(del); await _context.SaveChangesAsync(ct); }
            }
            return new EfetivoStatusUpdateResultDto { Ok = true, IdEfetivo = -request.IdObraColaborador };
        }

        if (!await _context.EfetivoStatuses.AsNoTracking().AnyAsync(s => s.EstIdEfetivoStatus == request.IdStatus, ct))
            return new EfetivoStatusUpdateResultDto { Ok = false, ErrorMessage = "Situacao invalida." };

        Efetivo? entity = null;
        if (request.IdEfetivo > 0)
            entity = await _context.Efetivos.FirstOrDefaultAsync(e => e.EfeIdEfetivo == request.IdEfetivo && e.EfeIdObra == obraId, ct);
        entity ??= await _context.Efetivos.FirstOrDefaultAsync(
            e => e.EfeIdObra == obraId && e.EfeIdObraColaborador == request.IdObraColaborador && e.EfeData.Date == day, ct);

        if (entity == null)
        {
            entity = new Efetivo
            {
                EfeIdObra = obraId,
                EfeIdObraColaborador = request.IdObraColaborador,
                EfeIdEfetivoStatus = request.IdStatus,
                EfeData = day
            };
            _context.Efetivos.Add(entity);
        }
        else
        {
            entity.EfeIdEfetivoStatus = request.IdStatus;
            entity.EfeData = day;
        }
        await _context.SaveChangesAsync(ct);
        return new EfetivoStatusUpdateResultDto { Ok = true, IdEfetivo = entity.EfeIdEfetivo };
    }

    /// <summary>Paridade prod <c>EfetivoModel.CopiarEfetivo</c>: copia status do dia origem → destino.</summary>
    public async Task<EfetivoCopiarResultDto> CopiarAsync(int obraId, EfetivoCopiarRequestDto request, CancellationToken ct)
    {
        if (!TryParseDate(request.DataOrigem, out var origem))
            return new EfetivoCopiarResultDto { Ok = false, ErrorMessage = "Informe a data de origem (filtro)." };
        if (!TryParseDate(request.DataDestino, out var destino))
            return new EfetivoCopiarResultDto { Ok = false, ErrorMessage = "Por favor, selecione uma data que deseja copiar o efetivo." };

        var diaOrigem = origem.Date;
        var diaDestino = destino.Date;
        if (diaOrigem == diaDestino)
            return new EfetivoCopiarResultDto { Ok = false, ErrorMessage = "A data de destino deve ser diferente da data de origem." };

        var fonte = await _context.Efetivos.AsNoTracking()
            .Where(e => e.EfeIdObra == obraId && e.EfeData.Date == diaOrigem && e.EfeIdEfetivoStatus > 0)
            .ToListAsync(ct);
        if (fonte.Count == 0)
            return new EfetivoCopiarResultDto { Ok = false, ErrorMessage = "Não há efetivo lançado na data de origem para copiar." };

        var existentesDestino = await _context.Efetivos
            .Where(e => e.EfeIdObra == obraId && e.EfeData.Date == diaDestino)
            .ToListAsync(ct);
        var byOc = existentesDestino.ToDictionary(e => e.EfeIdObraColaborador);

        var copiados = 0;
        foreach (var src in fonte)
        {
            if (byOc.TryGetValue(src.EfeIdObraColaborador, out var dest))
            {
                if (dest.EfeIdEfetivoStatus != src.EfeIdEfetivoStatus)
                {
                    dest.EfeIdEfetivoStatus = src.EfeIdEfetivoStatus;
                    copiados++;
                }
            }
            else
            {
                _context.Efetivos.Add(new Efetivo
                {
                    EfeIdObra = obraId,
                    EfeIdObraColaborador = src.EfeIdObraColaborador,
                    EfeIdEfetivoStatus = src.EfeIdEfetivoStatus,
                    EfeData = diaDestino,
                });
                copiados++;
            }
        }

        if (copiados > 0)
            await _context.SaveChangesAsync(ct);

        return new EfetivoCopiarResultDto { Ok = true, Copiados = copiados };
    }

    private static bool TryParseDate(string? value, out DateTime date)
    {
        date = default;
        if (string.IsNullOrWhiteSpace(value)) return false;
        return DateTime.TryParseExact(value.Trim(), "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date)
               || DateTime.TryParseExact(value.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out date)
               || DateTime.TryParse(value, PtBr, DateTimeStyles.None, out date);
    }
}
