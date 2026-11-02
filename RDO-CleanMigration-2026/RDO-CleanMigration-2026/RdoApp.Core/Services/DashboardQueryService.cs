using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

public class DashboardQueryService
{
    private readonly RdoDbContext _context;

    public DashboardQueryService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<DashboardObraDto> GetAsync(int obraId, CancellationToken cancellationToken)
    {
        var pizza = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join c in _context.Cargos.AsNoTracking() on oc.OcoIdCargo equals c.CarIdCargo
            where oc.OcoIdObra == obraId
            group oc by c.CarDsCargo into g
            select new DashboardSliceDto
            {
                Name = $"{g.Key}: {g.Count()}",
                Y = g.Count(),
            }
        ).ToListAsync(cancellationToken);

        var barra = await (
            from t in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on t.TarIdEtapa equals e.EtaIdEtapa
            join st in _context.StatusTarefas.AsNoTracking() on t.TarIdStatus equals st.SttIdStatus
            where e.EtaIdObra == obraId
            group t by st.SttDsStatus into g
            orderby g.Count()
            select new { Status = g.Key, Qtd = g.Count() }
        ).ToListAsync(cancellationToken);

        var desde = DateTime.Today.AddMonths(-1);
        var efetivo = await (
            from efe in _context.Efetivos.AsNoTracking()
            join oc in _context.ObraColaboradores.AsNoTracking() on efe.EfeIdObraColaborador equals oc.OcoIdObraColaborador
            join est in _context.EfetivoStatuses.AsNoTracking() on efe.EfeIdEfetivoStatus equals est.EstIdEfetivoStatus
            where oc.OcoIdObra == obraId && efe.EfeData >= desde
            group efe by est.EstDsEfetivoStatus into g
            orderby g.Key
            select new DashboardSliceDto
            {
                Name = $"{g.Key.ToUpperInvariant()}: {g.Count()}",
                Y = g.Count(),
            }
        ).ToListAsync(cancellationToken);

        return new DashboardObraDto
        {
            PizzaColaboradores = pizza,
            BarraCategorias = barra.Select(x => x.Status).ToList(),
            BarraValores = barra.Select(x => x.Qtd).ToList(),
            PizzaEfetivo = efetivo,
        };
    }
}
