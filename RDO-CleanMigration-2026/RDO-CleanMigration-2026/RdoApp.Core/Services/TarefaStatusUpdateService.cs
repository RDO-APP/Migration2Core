using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;
using static RdoApp.Core.Services.CardsTarefaParity;

namespace RdoApp.Core.Services;

/// <summary>
/// Paridade <c>TarefaModel.AtualizarStatus</c> — clone de linha no agrupador ao mudar status.
/// </summary>
public class TarefaStatusUpdateService
{
    private const int StatusFinalizada = 3;

    private readonly RdoDbContext _context;

    public TarefaStatusUpdateService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<TarefaStatusUpdateResultDto> AtualizarAsync(
        int obraId,
        int colaboradorId,
        int tarefaId,
        int idStatus,
        CancellationToken cancellationToken)
    {
        if (tarefaId <= 0 || idStatus <= 0)
        {
            return Fail("Tarefa ou status inválido.");
        }

        var entity = await _context.Tarefas.AsNoTracking()
            .FirstOrDefaultAsync(t => t.TarIdTarefa == tarefaId, cancellationToken);
        if (entity == null)
        {
            return Fail("Tarefa não encontrada.");
        }

        var naObra = await _context.Etapas.AsNoTracking()
            .AnyAsync(e => e.EtaIdEtapa == entity.TarIdEtapa && e.EtaIdObra == obraId, cancellationToken);
        if (!naObra)
        {
            return Fail("Tarefa não pertence à obra selecionada.");
        }

        var permitidos = IdsStatusPermitidos(entity.TarIdStatus);
        if (!permitidos.Contains(idStatus))
        {
            return Fail("Status não permitido a partir do status atual.");
        }

        if (entity.TarIdStatus == idStatus)
        {
            if (entity.TarIdStatus == StatusFinalizada)
            {
                var tracked = await _context.Tarefas
                    .FirstOrDefaultAsync(t => t.TarIdTarefa == tarefaId, cancellationToken);
                if (tracked != null)
                {
                    tracked.TarDtFim = DateTime.Today;
                    await _context.SaveChangesAsync(cancellationToken);
                }
            }

            return new TarefaStatusUpdateResultDto { Ok = true, Id = tarefaId };
        }

        var clone = new Tarefa
        {
            TarNrAgrupador = entity.TarNrAgrupador,
            TarIdStatus = idStatus,
            TarIdEtapa = entity.TarIdEtapa,
            TarIdUnidade = entity.TarIdUnidade,
            TarDsTarefa = entity.TarDsTarefa,
            TarNrQtdConstruida = entity.TarNrQtdConstruida,
            TarDtInicio = entity.TarDtInicio,
            TarDtPrevisaoFim = entity.TarDtPrevisaoFim,
            TarDtFim = idStatus == StatusFinalizada ? DateTime.Today : entity.TarDtFim,
            TarDsComentario = entity.TarDsComentario ?? "",
            TarDsFoto = entity.TarDsFoto ?? "",
            TarNrHorasTrabalhadas = entity.TarNrHorasTrabalhadas,
            TarDtMedicaoHoraInicial = entity.TarDtMedicaoHoraInicial,
            TarDtMedicaoHoraFinal = entity.TarDtMedicaoHoraFinal,
            TarDtMedicao = DateTime.Now,
            TarVlValorUnitario = entity.TarVlValorUnitario,
            TarIdColaboradorInsercao = colaboradorId > 0 ? colaboradorId : entity.TarIdColaboradorInsercao,
            TarDtInsercao = DateTime.Now,
            TarDtUltimaAtualizacao = DateTime.Now,
            TarNrQtdPrevisao = entity.TarNrQtdPrevisao,
            TarDtMedicaoHorimetroTotal = entity.TarDtMedicaoHorimetroTotal,
            TarCodigoParalizacao = entity.TarCodigoParalizacao,
            TarDtMedicaoHorimetroInicial = entity.TarDtMedicaoHorimetroInicial,
            TarDtMedicaoHorimetroFinal = entity.TarDtMedicaoHorimetroFinal
        };

        _context.Tarefas.Add(clone);
        await _context.SaveChangesAsync(cancellationToken);
        return new TarefaStatusUpdateResultDto { Ok = true, Id = clone.TarIdTarefa };
    }

    private static TarefaStatusUpdateResultDto Fail(string message) =>
        new() { Ok = false, ErrorMessage = message };
}
