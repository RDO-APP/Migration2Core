using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M7 7a — paridade prod <c>EtapaModel.ObterEtapasParaRDO</c>.</summary>
public class RdoCadastroQueryService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private readonly RdoDbContext _context;

    public RdoCadastroQueryService(RdoDbContext context)
    {
        _context = context;
    }

    public RdoCadastroBootstrapDto GetBootstrap(int obraId, string? obraNome)
    {
        var today = DateTime.Today;
        var obraFim = _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => o.ObrDtFim)
            .FirstOrDefault();
        var obraFinalizada = obraFim.HasValue && obraFim.Value.Date != DateTime.MinValue.Date;

        return new RdoCadastroBootstrapDto
        {
            DataRdoHoje = today.ToString("dd/MM/yyyy", PtBr),
            ObraFinalizada = obraFinalizada,
            ObraNome = obraNome ?? "",
        };
    }

    public async Task<RdoCadastroEtapasDto> GetEtapasParaRdoAsync(
        int obraId,
        DateTime dataMedicao,
        CancellationToken cancellationToken = default)
    {
        var data = dataMedicao.Date;

        var etapaRows = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdObra == obraId)
            .OrderBy(e => e.EtaNrOrderm)
            .ThenBy(e => e.EtaIdEtapa)
            .Select(e => new { e.EtaIdEtapa, Titulo = e.EtaDsEtapa ?? "", e.EtaNrOrderm })
            .ToListAsync(cancellationToken);

        if (etapaRows.Count == 0)
        {
            return new RdoCadastroEtapasDto();
        }

        var etapaIds = etapaRows.Select(e => e.EtaIdEtapa).ToList();
        var tarefas = await TarefaAgrupadorQuery.LoadByEtapaIdsAsync(_context, etapaIds, cancellationToken);

        var etapas = new List<RdoCadastroEtapaDto>();
        foreach (var etapa in etapaRows)
        {
            var inEtapa = tarefas.Where(t => t.TarIdEtapa == etapa.EtaIdEtapa);
            var reps = TarefaAgrupadorQuery.SelectRepresentantesParaRdo(inEtapa);
            if (reps.Count == 0)
            {
                continue;
            }

            var dtoTarefas = reps.Select(t =>
            {
                var agrupador = t.TarNrAgrupador;
                var noDia = tarefas.Any(x =>
                    x.TarNrAgrupador == agrupador && x.TarDtMedicao.Date == data);
                var diaAnterior = tarefas.Any(x =>
                    x.TarNrAgrupador == agrupador && x.TarDtMedicao.Date == data.AddDays(-1));

                return new RdoCadastroTarefaDto
                {
                    Id = t.TarIdTarefa,
                    Descricao = t.Descricao,
                    Status = t.TarIdStatus,
                    IdEtapa = t.TarIdEtapa,
                    ExisteRegistroMedicaoDataRequerida = noDia,
                    ExisteRegistroMedicaoDiaAnterior = diaAnterior,
                };
            }).ToList();

            etapas.Add(new RdoCadastroEtapaDto
            {
                Id = etapa.EtaIdEtapa,
                Titulo = etapa.Titulo,
                Ordem = etapa.EtaNrOrderm,
                Tarefas = dtoTarefas,
            });
        }

        return new RdoCadastroEtapasDto { Etapas = etapas };
    }
}
