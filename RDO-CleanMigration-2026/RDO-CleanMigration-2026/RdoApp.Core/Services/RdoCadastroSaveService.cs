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
        try
        {
            return await SaveAsyncCore(obraId, colaboradorId, request, cancellationToken);
        }
        catch (Exception ex)
        {
            return Fail(ex.Message);
        }
    }

    private async Task<RdoCadastroSaveResultDto> SaveAsyncCore(
        int obraId,
        int colaboradorId,
        RdoCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        request.ListaTarefas ??= new List<RdoCadastroTarefaIdDto>();

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

        // Paridade prod <c>RdoModel.Salvar</c>: tempo/chuva opcionais (relatório = "Não Informado").

        var obra = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => new { o.ObrDtInicio, o.ObrDtFim })
            .FirstOrDefaultAsync(cancellationToken);
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

        var dayStart = dataRdo.Date;
        var dayEnd = dayStart.AddDays(1);
        var existingRdo = await _context.Rdos.AsNoTracking()
            .Where(r => r.RdoIdObra == obraId && r.RdoDtRdo >= dayStart && r.RdoDtRdo < dayEnd)
            .Select(r => new { r.RdoIdRdo, r.RdoIdStatus, ComentarioGeracao = r.RdoDsComentarioGeracao ?? "" })
            .FirstOrDefaultAsync(cancellationToken);

        string? statusText = null;
        if (existingRdo != null)
        {
            statusText = await _context.StatusRdos.AsNoTracking()
                .Where(s => s.StrIdStatus == existingRdo.RdoIdStatus)
                .Select(s => s.StrDsStatus ?? "")
                .FirstOrDefaultAsync(cancellationToken);
        }

        if (existingRdo != null && !request.ConfirmSubstituir)
        {
            return new RdoCadastroSaveResultDto
            {
                Ok = false,
                NeedsConfirm = "substituir",
                ConfirmDetail = dataRdo.ToString("dd/MM/yyyy", PtBr),
            };
        }

        if (existingRdo != null && statusText != null && statusText.Contains("assinado", StringComparison.OrdinalIgnoreCase))
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

        var climaManha = NormalizeLegadoChar(request.ClimaManha);
        var climaTarde = NormalizeLegadoChar(request.ClimaTarde);
        var climaNoite = NormalizeLegadoChar(request.ClimaNoite);
        var chuvaManha = NormalizeLegadoChar(request.ChuvaManha);
        var chuvaTarde = NormalizeLegadoChar(request.ChuvaTarde);
        var chuvaNoite = NormalizeLegadoChar(request.ChuvaNoite);

        var strategy = _context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var tx = await _context.Database.BeginTransactionAsync(cancellationToken);
            try
            {
                var impro = new Improdutividade
                {
                    ImpStClima = request.ImprodutividadeCondicoesClimaticas,
                    ImpStMaterial = request.ImprodutividadeMateriais,
                    ImpStParalizacao = request.ImprodutividadeParalizacoes,
                    ImpStEquipamento = request.ImprodutividadeEquipamentos,
                    ImpStContratante = request.ImprodutividadeContratante,
                    ImpStFornecedores = request.ImprodutividadeFornecedores,
                    ImpStMaodeobra = request.ImprodutividadeMaodeObra,
                    ImpStProjeto = request.ImprodutividadeProjeto,
                    ImpStPlanejamento = request.ImprodutividadePlanejamento,
                    ImpStAcidentes = request.ImprodutividadeAcidente,
                };
                _context.Improdutividades.Add(impro);
                await _context.SaveChangesAsync(cancellationToken);

                var comentarioGeracao = request.Comentario ?? (existingRdo?.ComentarioGeracao ?? "");
                var tpComentarioGeracao = MapTipoComentarioGeracao(request.TipoComentarioGeracao);
                int rdoId;

                if (existingRdo == null)
                {
                    var rdoRow = new Rdo
                    {
                        RdoIdObra = obraId,
                        RdoIdColaborador = colaboradorId > 0 ? colaboradorId : null,
                        RdoDsComentarioAssinatura = "",
                        RdoTpComentarioAssinatura = "",
                        RdoDsComentarioGeracao = comentarioGeracao,
                        RdoTpComentarioGeracao = tpComentarioGeracao,
                        RdoDtRdo = dataRdo.Date,
                        RdoIdStatus = StatusRdoAberto,
                        RdoDsClimaManha = climaManha,
                        RdoDsClimaTarde = climaTarde,
                        RdoDsClimaNoite = climaNoite,
                        RdoDsChuvaManha = chuvaManha,
                        RdoDsChuvaTarde = chuvaTarde,
                        RdoDsChuvaNoite = chuvaNoite,
                        RdoDtGeracao = DateTime.Now,
                        RdoIdImprodutividade = impro.ImpIdImprodutividade,
                    };
                    _context.Rdos.Add(rdoRow);
                    await _context.SaveChangesAsync(cancellationToken);
                    rdoId = rdoRow.RdoIdRdo;
                }
                else
                {
                    rdoId = existingRdo.RdoIdRdo;
                    await _context.Rdos
                        .Where(r => r.RdoIdRdo == rdoId)
                        .ExecuteUpdateAsync(
                            s => s
                                .SetProperty(r => r.RdoDsComentarioGeracao, comentarioGeracao)
                                .SetProperty(r => r.RdoTpComentarioGeracao, tpComentarioGeracao)
                                .SetProperty(r => r.RdoDtRdo, dataRdo.Date)
                                .SetProperty(r => r.RdoIdStatus, StatusRdoAberto)
                                .SetProperty(r => r.RdoDsClimaManha, climaManha)
                                .SetProperty(r => r.RdoDsClimaTarde, climaTarde)
                                .SetProperty(r => r.RdoDsClimaNoite, climaNoite)
                                .SetProperty(r => r.RdoDsChuvaManha, chuvaManha)
                                .SetProperty(r => r.RdoDsChuvaTarde, chuvaTarde)
                                .SetProperty(r => r.RdoDsChuvaNoite, chuvaNoite)
                                .SetProperty(r => r.RdoDtGeracao, DateTime.Now)
                                .SetProperty(r => r.RdoIdImprodutividade, impro.ImpIdImprodutividade),
                            cancellationToken);
                }

                await SyncRdoTarefasAsync(
                    rdoId,
                    dataRdo.Date,
                    selectedIds,
                    tarefasObra,
                    request.ConfirmCopiarDiaAnterior,
                    cancellationToken);

                if (request.ListaImagems != null)
                {
                    await SyncRdoImagensAsync(rdoId, request.ListaImagems, cancellationToken);
                }

                await tx.CommitAsync(cancellationToken);

                return new RdoCadastroSaveResultDto { Ok = true, IdRdo = rdoId };
            }
            catch (Exception ex)
            {
                await tx.RollbackAsync(cancellationToken);
                return Fail(ex.Message);
            }
        });
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
        // Legado RDS: tar_ds_* pode ser NULL — evitar materializar entidade Tarefa inteira (DBNull → string).
        var tar = await _context.Tarefas.AsNoTracking()
            .Where(t => t.TarIdTarefa == tarIdOrigem)
            .Select(t => new
            {
                TarDsComentario = t.TarDsComentario ?? "",
                TarDsFoto = t.TarDsFoto ?? "",
                TarDsTarefa = t.TarDsTarefa ?? "",
                t.TarDtFim,
                t.TarDtInicio,
                t.TarDtMedicao,
                t.TarDtMedicaoHoraFinal,
                t.TarDtMedicaoHoraInicial,
                t.TarDtPrevisaoFim,
                t.TarIdColaboradorInsercao,
                t.TarIdEtapa,
                t.TarIdStatus,
                t.TarIdUnidade,
                t.TarNrAgrupador,
                t.TarNrHorasTrabalhadas,
                t.TarNrQtdConstruida,
                t.TarVlValorUnitario,
            })
            .FirstAsync(cancellationToken);

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

        var colabIds = await _context.ObraTarefaColaboradores.AsNoTracking()
            .Where(o => o.OtcIdTarefa == tarIdOrigem)
            .Select(o => o.OtcIdObraColaborador)
            .ToListAsync(cancellationToken);
        foreach (var otcId in colabIds)
        {
            _context.ObraTarefaColaboradores.Add(new ObraTarefaColaborador
            {
                OtcIdObraColaborador = otcId,
                OtcIdTarefa = newTar.TarIdTarefa,
            });
        }

        var equipIds = await _context.ObraTarefaEquipamentos.AsNoTracking()
            .Where(o => o.OteIdTarefa == tarIdOrigem)
            .Select(o => o.OteIdObraEquipamento)
            .ToListAsync(cancellationToken);
        foreach (var oteId in equipIds)
        {
            _context.ObraTarefaEquipamentos.Add(new ObraTarefaEquipamento
            {
                OteIdObraEquipamento = oteId,
                OteIdTarefa = newTar.TarIdTarefa,
            });
        }

        await _context.SaveChangesAsync(cancellationToken);
        return newTar.TarIdTarefa;
    }

    /// <summary>Paridade prod <c>RdoModel.IncluirImagens</c>.</summary>
    private async Task SyncRdoImagensAsync(
        int rdoId,
        List<RdoCadastroImagemIdDto> listaImagems,
        CancellationToken cancellationToken)
    {
        var existing = await _context.RdoImagens
            .Where(ri => ri.RimIdRdo == rdoId)
            .ToListAsync(cancellationToken);

        foreach (var link in existing)
        {
            _context.RdoImagens.Remove(link);
            var imagem = await _context.Imagens.FindAsync(new object[] { link.RimIdImagem }, cancellationToken);
            if (imagem != null)
            {
                imagem.ImaIdHistoricoTarefaRdo = null;
            }
        }

        await _context.SaveChangesAsync(cancellationToken);

        var ids = listaImagems
            .Select(x => x.IdImagem)
            .Where(id => id > 0)
            .Distinct()
            .ToList();

        foreach (var idImagem in ids)
        {
            _context.RdoImagens.Add(new RdoImagem
            {
                RimIdRdo = rdoId,
                RimIdImagem = idImagem,
            });

            var imagem = await _context.Imagens.FindAsync(new object[] { idImagem }, cancellationToken);
            if (imagem != null)
            {
                imagem.ImaIdHistoricoTarefaRdo = rdoId;
            }
        }

        await _context.SaveChangesAsync(cancellationToken);
    }

    private static string MapTipoComentarioGeracao(int tipo) =>
        tipo switch
        {
            1 => "P",
            2 => "N",
            _ => "",
        };

    private static string? NormalizeLegadoChar(string? value) =>
        string.IsNullOrWhiteSpace(value) ? null : value.Trim();

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
