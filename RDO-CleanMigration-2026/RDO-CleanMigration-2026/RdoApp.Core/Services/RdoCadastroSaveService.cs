using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M7 7a — paridade prod <c>RdoModel.Salvar</c> + <c>SalvarHistoricoTarefa</c> (subset).</summary>
public class RdoCadastroSaveService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private const int StatusPlanejada = 1;
    private const int StatusRdoAberto = 1;

    private readonly RdoDbContext _context;

    public RdoCadastroSaveService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<RdoCadastroSaveResultDto> SaveAsync(
        int obraId,
        int colaboradorId,
        RdoCadastroSaveRequestDto request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.DataRdo))
        {
            return Fail("A data deve ser preenchida.");
        }

        if (!TryParseDate(request.DataRdo, out var dataRdo))
        {
            return Fail("A data é inválida.");
        }

        if (request.ListaTarefas.Count == 0)
        {
            return Fail("Selecione ao menos uma tarefa.");
        }

        var obra = await _context.Obras.FirstOrDefaultAsync(o => o.ObrIdObra == obraId, cancellationToken);
        if (obra == null)
        {
            return Fail("Obra não encontrada.");
        }

        if (dataRdo.Date < obra.ObrDtInicio.Date)
        {
            return Fail("Não é possível gerar um RDO anterior a data inicial da obra.");
        }

        if (obra.ObrDtFim.HasValue && obra.ObrDtFim.Value.Date != DateTime.MinValue.Date &&
            dataRdo.Date > obra.ObrDtFim.Value.Date)
        {
            return Fail("Não é possível gerar um RDO posterior a data final da obra.");
        }

        var rdoRow = await _context.Rdos
            .FirstOrDefaultAsync(r => r.RdoIdObra == obraId && r.RdoDtRdo.Date == dataRdo.Date, cancellationToken);

        string? statusText = null;
        if (rdoRow != null)
        {
            statusText = await _context.StatusRdos.AsNoTracking()
                .Where(s => s.StrIdStatus == rdoRow.RdoIdStatus)
                .Select(s => s.StrDsStatus)
                .FirstOrDefaultAsync(cancellationToken);
        }

        if (rdoRow != null && !request.ConfirmSubstituir)
        {
            return new RdoCadastroSaveResultDto
            {
                Ok = false,
                NeedsConfirm = "substituir",
                ConfirmDetail = dataRdo.ToString("dd/MM/yyyy", PtBr),
            };
        }

        if (rdoRow != null && statusText != null && statusText.Contains("assinado", StringComparison.OrdinalIgnoreCase))
        {
            return Fail("Não é possível sobrescrever um RDO que já foi assinado.");
        }

        var selectedIds = request.ListaTarefas.Select(t => t.Id).Distinct().ToList();
        var tarefasObra = await TarefaAgrupadorQuery.LoadByObraIdAsync(_context, obraId, cancellationToken);

        var semHistorico = new List<string>();
        foreach (var id in selectedIds)
        {
            var seed = tarefasObra.FirstOrDefault(t => t.TarIdTarefa == id);
            if (seed == null)
            {
                continue;
            }

            var agrupador = seed.TarNrAgrupador;
            var noDia = tarefasObra.Any(t =>
                t.TarNrAgrupador == agrupador && t.TarIdStatus != StatusPlanejada && t.TarDtMedicao.Date == dataRdo.Date);
            var diaAnterior = tarefasObra.Any(t =>
                t.TarNrAgrupador == agrupador && t.TarIdStatus != StatusPlanejada &&
                t.TarDtMedicao.Date == dataRdo.Date.AddDays(-1));

            if (diaAnterior && !noDia)
            {
                semHistorico.Add(seed.Descricao.Length > 0 ? seed.Descricao : $"Tarefa {id}");
            }
        }

        if (semHistorico.Count > 0 && !request.ConfirmCopiarDiaAnterior)
        {
            return new RdoCadastroSaveResultDto
            {
                Ok = false,
                NeedsConfirm = "copiarDiaAnterior",
                ConfirmDetail = string.Join(", ", semHistorico),
            };
        }

        await using var tx = await _context.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            var impro = new Improdutividade();
            _context.Improdutividades.Add(impro);
            await _context.SaveChangesAsync(cancellationToken);

            var isNew = rdoRow == null;
            if (isNew)
            {
                rdoRow = new Rdo
                {
                    RdoIdObra = obraId,
                    RdoIdColaborador = colaboradorId > 0 ? colaboradorId : null,
                    RdoDsComentarioAssinatura = "",
                    RdoTpComentarioAssinatura = "",
                    RdoDsComentarioGeracao = request.Comentario ?? "",
                    RdoTpComentarioGeracao = MapTipoComentarioGeracao(request.TipoComentarioGeracao),
                };
                _context.Rdos.Add(rdoRow);
            }
            else
            {
                rdoRow!.RdoDsComentarioGeracao = request.Comentario ?? rdoRow.RdoDsComentarioGeracao;
                rdoRow.RdoTpComentarioGeracao = MapTipoComentarioGeracao(request.TipoComentarioGeracao);
            }

            rdoRow!.RdoDtRdo = dataRdo.Date;
            rdoRow.RdoIdStatus = StatusRdoAberto;
            rdoRow.RdoDsClimaManha = request.ClimaManha;
            rdoRow.RdoDsClimaTarde = request.ClimaTarde;
            rdoRow.RdoDsClimaNoite = request.ClimaNoite;
            rdoRow.RdoDsChuvaManha = request.ChuvaManha;
            rdoRow.RdoDsChuvaTarde = request.ChuvaTarde;
            rdoRow.RdoDsChuvaNoite = request.ChuvaNoite;
            rdoRow.RdoDtGeracao = DateTime.Now;
            rdoRow.RdoIdImprodutividade = impro.ImpIdImprodutividade;

            await _context.SaveChangesAsync(cancellationToken);

            await SyncRdoTarefasAsync(
                rdoRow.RdoIdRdo,
                dataRdo.Date,
                selectedIds,
                tarefasObra,
                request.ConfirmCopiarDiaAnterior,
                cancellationToken);

            await tx.CommitAsync(cancellationToken);

            return new RdoCadastroSaveResultDto { Ok = true, IdRdo = rdoRow.RdoIdRdo };
        }
        catch (Exception ex)
        {
            await tx.RollbackAsync(cancellationToken);
            return Fail(ex.Message);
        }
    }

    private async Task SyncRdoTarefasAsync(
        int rdoId,
        DateTime dataRdo,
        List<int> selectedIds,
        List<TarefaAgrupadorRow> tarefasObra,
        bool allowCopyPreviousDay,
        CancellationToken cancellationToken)
    {
        var links = await _context.RdoTarefas.Where(rt => rt.RtaIdRdo == rdoId).ToListAsync(cancellationToken);
        var remaining = new List<RdoTarefa>(links);

        foreach (var idTarefa in selectedIds)
        {
            var seed = tarefasObra.FirstOrDefault(t => t.TarIdTarefa == idTarefa);
            if (seed == null)
            {
                continue;
            }

            var agrupador = seed.TarNrAgrupador;
            var noDia = tarefasObra
                .Where(t => t.TarNrAgrupador == agrupador && t.TarIdStatus != StatusPlanejada && t.TarDtMedicao.Date == dataRdo)
                .ToList();

            if (noDia.Count == 0 && allowCopyPreviousDay)
            {
                var prev = tarefasObra
                    .Where(t => t.TarNrAgrupador == agrupador && t.TarIdStatus != StatusPlanejada &&
                                t.TarDtMedicao.Date == dataRdo.AddDays(-1))
                    .ToList();
                foreach (var tar in prev)
                {
                    var newId = await CopyTarefaHistoricoAsync(tar.TarIdTarefa, cancellationToken);
                    await EnsureLinkAsync(rdoId, newId, remaining, cancellationToken);
                }

                continue;
            }

            foreach (var tar in noDia)
            {
                await EnsureLinkAsync(rdoId, tar.TarIdTarefa, remaining, cancellationToken);
            }
        }

        if (remaining.Count > 0)
        {
            _context.RdoTarefas.RemoveRange(remaining);
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    private async Task EnsureLinkAsync(
        int rdoId,
        int tarefaId,
        List<RdoTarefa> remaining,
        CancellationToken cancellationToken)
    {
        var existing = remaining.FirstOrDefault(r => r.RtaIdTarefa == tarefaId);
        if (existing != null)
        {
            remaining.Remove(existing);
            return;
        }

        var already = await _context.RdoTarefas.AnyAsync(
            rt => rt.RtaIdRdo == rdoId && rt.RtaIdTarefa == tarefaId,
            cancellationToken);
        if (!already)
        {
            _context.RdoTarefas.Add(new RdoTarefa { RtaIdRdo = rdoId, RtaIdTarefa = tarefaId });
            await _context.SaveChangesAsync(cancellationToken);
        }
    }

    private async Task<int> CopyTarefaHistoricoAsync(int tarIdOrigem, CancellationToken cancellationToken)
    {
        var tar = await _context.Tarefas.FirstAsync(t => t.TarIdTarefa == tarIdOrigem, cancellationToken);
        var newTar = new Tarefa
        {
            TarDsComentario = tar.TarDsComentario,
            TarDsFoto = tar.TarDsFoto,
            TarDsTarefa = tar.TarDsTarefa,
            TarDtFim = tar.TarDtFim,
            TarDtInicio = tar.TarDtInicio,
            TarDtInsercao = DateTime.Now,
            TarDtMedicao = tar.TarDtMedicao.Date.AddDays(1),
            TarDtMedicaoHoraFinal = tar.TarDtMedicaoHoraFinal,
            TarDtMedicaoHoraInicial = tar.TarDtMedicaoHoraInicial,
            TarDtPrevisaoFim = tar.TarDtPrevisaoFim,
            TarDtUltimaAtualizacao = DateTime.Now,
            TarIdColaboradorInsercao = tar.TarIdColaboradorInsercao,
            TarIdEtapa = tar.TarIdEtapa,
            TarIdStatus = tar.TarIdStatus,
            TarIdUnidade = tar.TarIdUnidade,
            TarNrAgrupador = tar.TarNrAgrupador,
            TarNrHorasTrabalhadas = tar.TarNrHorasTrabalhadas,
            TarNrQtdConstruida = tar.TarNrQtdConstruida ?? 0,
            TarVlValorUnitario = tar.TarVlValorUnitario,
        };

        _context.Tarefas.Add(newTar);
        await _context.SaveChangesAsync(cancellationToken);

        var colabs = await _context.ObraTarefaColaboradores.AsNoTracking()
            .Where(o => o.OtcIdTarefa == tar.TarIdTarefa)
            .ToListAsync(cancellationToken);
        foreach (var otc in colabs)
        {
            _context.ObraTarefaColaboradores.Add(new ObraTarefaColaborador
            {
                OtcIdObraColaborador = otc.OtcIdObraColaborador,
                OtcIdTarefa = newTar.TarIdTarefa,
            });
        }

        var equips = await _context.ObraTarefaEquipamentos.AsNoTracking()
            .Where(o => o.OteIdTarefa == tar.TarIdTarefa)
            .ToListAsync(cancellationToken);
        foreach (var ote in equips)
        {
            _context.ObraTarefaEquipamentos.Add(new ObraTarefaEquipamento
            {
                OteIdObraEquipamento = ote.OteIdObraEquipamento,
                OteIdTarefa = newTar.TarIdTarefa,
            });
        }

        await _context.SaveChangesAsync(cancellationToken);
        return newTar.TarIdTarefa;
    }

    private static string MapTipoComentarioGeracao(int tipo) =>
        tipo switch
        {
            1 => "P",
            2 => "N",
            _ => "",
        };

    private static bool TryParseDate(string value, out DateTime date)
    {
        if (DateTime.TryParseExact(value.Trim(), "dd/MM/yyyy", PtBr, DateTimeStyles.None, out date))
        {
            return true;
        }

        return DateTime.TryParse(value, PtBr, DateTimeStyles.None, out date);
    }

    private static RdoCadastroSaveResultDto Fail(string message) =>
        new() { Ok = false, ErrorMessage = message };
}
