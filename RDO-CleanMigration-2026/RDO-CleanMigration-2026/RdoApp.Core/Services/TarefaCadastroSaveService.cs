using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Data.Entities;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>
/// M7 — salvar cadastro / nova medição. Paridade <c>TarefaModel.Update</c> + clone de agrupador no P4.
/// </summary>
public class TarefaCadastroSaveService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private const int StatusPlanejada = 1;
    private const int StatusFinalizada = 3;
    private const int StatusPausada = 4;
    private const int StatusRdoAssinado = 2;
    private const int StatusRdoAssinado2 = 3;
    private const int MaxFotoBytes = 2 * 1024 * 1024;

    private readonly RdoDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _env;

    public TarefaCadastroSaveService(
        RdoDbContext context,
        IConfiguration configuration,
        IWebHostEnvironment env)
    {
        _context = context;
        _configuration = configuration;
        _env = env;
    }

    public async Task<TarefaCadastroSaveResultDto> SaveAsync(
        int obraId,
        int colaboradorId,
        TarefaCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        try
        {
            return await SaveCoreAsync(obraId, colaboradorId, request, cancellationToken);
        }
        catch (Exception ex)
        {
            return Fail(ex.Message);
        }
    }

    private async Task<TarefaCadastroSaveResultDto> SaveCoreAsync(
        int obraId,
        int colaboradorId,
        TarefaCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        var isCreate = request.Id <= 0;

        var descricao = (request.Descricao ?? "").Trim();
        if (descricao.Length < 3)
        {
            return Fail("Por favor, introduza pelo menos três caracteres na Descrição da Tarefa.");
        }

        if (request.IdEtapa <= 0)
        {
            return Fail("A Etapa deve ser preenchida.");
        }

        if (request.Status <= 0)
        {
            return Fail("O Status deve ser preenchido.");
        }

        if (request.Status == StatusPausada && string.IsNullOrWhiteSpace(request.CodigoParalizacao))
        {
            return Fail("O Código de Paralização deve ser preenchido.");
        }

        if (!TryParseDate(request.DataInicio, out var dataInicio))
        {
            return Fail("A Data Inicial Planejada deve ser preenchida.");
        }

        if (!TryParseDate(request.DataPrevisaoFim, out var dataPrevisaoFim))
        {
            return Fail("A Data Final Planejada deve ser preenchida.");
        }

        var dataMedicao = DateTime.Today;
        if (request.NovaMedicao || request.Status != StatusPlanejada)
        {
            if (!TryParseDate(request.DataMedicao, out dataMedicao))
            {
                return Fail("A Data da medição deve ser preenchida.");
            }
        }
        else if (TryParseDate(request.DataMedicao, out var parsedMed))
        {
            dataMedicao = parsedMed;
        }
        else
        {
            dataMedicao = dataInicio.Date;
        }

        var etapaOk = await _context.Etapas.AsNoTracking()
            .AnyAsync(e => e.EtaIdEtapa == request.IdEtapa && e.EtaIdObra == obraId, cancellationToken);
        if (!etapaOk)
        {
            return Fail("Etapa não pertence à obra selecionada.");
        }

        var obraInicio = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == obraId)
            .Select(o => o.ObrDtInicio)
            .FirstOrDefaultAsync(cancellationToken);

        if (dataInicio.Date < obraInicio.Date)
        {
            return Fail("A Data Inicial da Tarefa não pode ser menor do que a Data Inicial da Obra.");
        }

        if (dataPrevisaoFim.Date < obraInicio.Date)
        {
            return Fail("A Data de Previsão de Final da Tarefa não pode ser menor do que a Data Inicial da Obra.");
        }

        if (isCreate)
        {
            if (request.NovaMedicao)
            {
                return Fail("Nova medição exige tarefa existente.");
            }

            var donoId = await _context.Obras.AsNoTracking()
                .Where(o => o.ObrIdObra == obraId)
                .Select(o => o.ObrIdDono)
                .FirstOrDefaultAsync(cancellationToken);
            var lim = 0;
            if (donoId is > 0)
            {
                var licId = await _context.Empresas.AsNoTracking()
                    .Where(e => e.EmpIdEmpresa == donoId.Value)
                    .Select(e => e.EmpIdLicenca)
                    .FirstOrDefaultAsync(cancellationToken);
                if (licId is > 0)
                {
                    lim = await _context.Licencas.AsNoTracking()
                        .Where(l => l.LicIdLicenca == licId.Value)
                        .Select(l => l.LicQtdTarefasObra)
                        .FirstOrDefaultAsync(cancellationToken);
                }
            }

            if (lim > 0)
            {
                var qtdAgrupadores = await (
                    from tar in _context.Tarefas.AsNoTracking()
                    join et in _context.Etapas.AsNoTracking() on tar.TarIdEtapa equals et.EtaIdEtapa
                    where et.EtaIdObra == obraId
                    select tar.TarNrAgrupador
                ).Distinct().CountAsync(cancellationToken);
                if (qtdAgrupadores >= lim)
                {
                    return Fail(
                        "A licença adquirida só permite adicionar " + lim +
                        " tarefas por obra. Favor verificar com o administrador.");
                }
            }

            var horaInicialC = ParseTime(request.HoraInicial);
            var horaFinalC = ParseTime(request.HoraFinal);
            var horimetroIniC = request.HorimetroInicial ?? 0;
            var horimetroFimC = request.HorimetroFinal ?? 0;
            var horimetroTotalC = request.HorimetroTotal ?? Math.Max(0, horimetroFimC - horimetroIniC);
            var horasTrabC = DiffHorasRelogio(horaInicialC, horaFinalC);

            var created = new Tarefa
            {
                TarNrAgrupador = Guid.NewGuid(),
                TarIdStatus = request.Status,
                TarIdEtapa = request.IdEtapa,
                TarIdUnidade = request.IdUnidade > 0 ? request.IdUnidade : null,
                TarDsTarefa = descricao,
                TarNrQtdConstruida = request.QtdConstruida ?? 0,
                TarDtInicio = dataInicio.Date,
                TarDtPrevisaoFim = dataPrevisaoFim.Date,
                TarDtFim = request.Status == StatusFinalizada ? DateTime.Today : null,
                TarDsComentario = request.Comentario ?? "",
                TarDsFoto = "",
                TarNrHorasTrabalhadas = horasTrabC,
                TarDtMedicaoHoraInicial = horaInicialC,
                TarDtMedicaoHoraFinal = horaFinalC,
                TarDtMedicao = dataMedicao.Date,
                TarVlValorUnitario = request.Valor ?? 0,
                TarIdColaboradorInsercao = colaboradorId > 0 ? colaboradorId : 0,
                TarDtInsercao = DateTime.Now,
                TarDtUltimaAtualizacao = DateTime.Now,
                TarNrQtdPrevisao = request.QtdPlanejada ?? 0,
                TarDtMedicaoHorimetroTotal = horimetroTotalC,
                TarCodigoParalizacao = string.IsNullOrWhiteSpace(request.CodigoParalizacao)
                    ? null
                    : request.CodigoParalizacao,
                TarDtMedicaoHorimetroInicial = horimetroIniC,
                TarDtMedicaoHorimetroFinal = horimetroFimC
            };

            _context.Tarefas.Add(created);
            await _context.SaveChangesAsync(cancellationToken);
            await SyncVinculosAsync(created.TarIdTarefa, obraId, request, cancellationToken);
            await SyncAcidentesAsync(created.TarIdTarefa, request, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            return new TarefaCadastroSaveResultDto { Ok = true, Id = created.TarIdTarefa };
        }

        var entity = await _context.Tarefas
            .FirstOrDefaultAsync(t => t.TarIdTarefa == request.Id, cancellationToken);
        if (entity == null)
        {
            return Fail("Tarefa não encontrada.");
        }

        var entityObra = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdEtapa == entity.TarIdEtapa)
            .Select(e => e.EtaIdObra)
            .FirstOrDefaultAsync(cancellationToken);
        if (entityObra != obraId)
        {
            return Fail("Tarefa não pertence à obra selecionada.");
        }

        var rdoAssinadoNoDia = await (
            from r in _context.Rdos.AsNoTracking()
            join rt in _context.RdoTarefas.AsNoTracking() on r.RdoIdRdo equals rt.RtaIdRdo
            join tar in _context.Tarefas.AsNoTracking() on rt.RtaIdTarefa equals tar.TarIdTarefa
            where r.RdoIdObra == obraId &&
                  r.RdoDtRdo.Date == dataMedicao.Date &&
                  (r.RdoIdStatus == StatusRdoAssinado || r.RdoIdStatus == StatusRdoAssinado2) &&
                  tar.TarNrAgrupador == entity.TarNrAgrupador
            select r.RdoIdRdo
        ).AnyAsync(cancellationToken);

        if (rdoAssinadoNoDia)
        {
            return Fail("Já existe RDO assinado para o dia " + dataMedicao.ToString("dd/MM/yyyy", PtBr) + ". Favor verificar!");
        }

        var horaInicial = ParseTime(request.HoraInicial);
        var horaFinal = ParseTime(request.HoraFinal);
        var horimetroIni = request.HorimetroInicial ?? 0;
        var horimetroFim = request.HorimetroFinal ?? 0;
        var horimetroTotal = request.HorimetroTotal ?? Math.Max(0, horimetroFim - horimetroIni);
        var horasTrab = DiffHorasRelogio(horaInicial, horaFinal);

        // Prod: ExisteInterseccaoHorario está comentado — permite nova medição mesmo no mesmo dia.
        if (request.NovaMedicao)
        {
            var clone = new Tarefa
            {
                TarNrAgrupador = entity.TarNrAgrupador,
                TarIdStatus = request.Status,
                TarIdEtapa = entity.TarIdEtapa,
                TarIdUnidade = request.IdUnidade > 0 ? request.IdUnidade : entity.TarIdUnidade,
                TarDsTarefa = entity.TarDsTarefa,
                TarNrQtdConstruida = request.QtdConstruida ?? 0,
                TarDtInicio = entity.TarDtInicio,
                TarDtPrevisaoFim = entity.TarDtPrevisaoFim,
                TarDtFim = request.Status == StatusFinalizada ? DateTime.Today : null,
                TarDsComentario = request.Comentario ?? "",
                TarDsFoto = entity.TarDsFoto ?? "",
                TarNrHorasTrabalhadas = horasTrab,
                TarDtMedicaoHoraInicial = horaInicial,
                TarDtMedicaoHoraFinal = horaFinal,
                TarDtMedicao = dataMedicao.Date,
                TarVlValorUnitario = entity.TarVlValorUnitario,
                TarIdColaboradorInsercao = colaboradorId > 0 ? colaboradorId : entity.TarIdColaboradorInsercao,
                TarDtInsercao = DateTime.Now,
                TarDtUltimaAtualizacao = DateTime.Now,
                TarNrQtdPrevisao = entity.TarNrQtdPrevisao,
                TarDtMedicaoHorimetroTotal = horimetroTotal,
                TarCodigoParalizacao = string.IsNullOrWhiteSpace(request.CodigoParalizacao)
                    ? null
                    : request.CodigoParalizacao,
                TarDtMedicaoHorimetroInicial = horimetroIni,
                TarDtMedicaoHorimetroFinal = horimetroFim
            };

            _context.Tarefas.Add(clone);
            await _context.SaveChangesAsync(cancellationToken);

            var colabs = await _context.ObraTarefaColaboradores
                .Where(x => x.OtcIdTarefa == entity.TarIdTarefa)
                .Select(x => x.OtcIdObraColaborador)
                .ToListAsync(cancellationToken);
            foreach (var ocId in colabs)
            {
                _context.ObraTarefaColaboradores.Add(new ObraTarefaColaborador
                {
                    OtcIdObraColaborador = ocId,
                    OtcIdTarefa = clone.TarIdTarefa
                });
            }

            var equips = await _context.ObraTarefaEquipamentos
                .Where(x => x.OteIdTarefa == entity.TarIdTarefa)
                .Select(x => x.OteIdObraEquipamento)
                .ToListAsync(cancellationToken);
            foreach (var oeId in equips)
            {
                _context.ObraTarefaEquipamentos.Add(new ObraTarefaEquipamento
                {
                    OteIdObraEquipamento = oeId,
                    OteIdTarefa = clone.TarIdTarefa
                });
            }

            await SyncAcidentesAsync(clone.TarIdTarefa, request, cancellationToken);
            await SyncNovasImagensAsync(obraId, clone.TarIdTarefa, request.ListaImagens, cancellationToken);
            await _context.SaveChangesAsync(cancellationToken);
            return new TarefaCadastroSaveResultDto { Ok = true, Id = clone.TarIdTarefa };
        }

        entity.TarDsTarefa = descricao;
        entity.TarIdEtapa = request.IdEtapa;
        entity.TarIdStatus = request.Status;
        entity.TarIdUnidade = request.IdUnidade > 0 ? request.IdUnidade : null;
        entity.TarDtInicio = dataInicio.Date;
        entity.TarDtPrevisaoFim = dataPrevisaoFim.Date;
        entity.TarNrQtdPrevisao = request.QtdPlanejada ?? 0;
        entity.TarVlValorUnitario = request.Valor ?? 0;
        entity.TarNrQtdConstruida = request.QtdConstruida ?? 0;
        entity.TarDtMedicao = dataMedicao.Date;
        entity.TarDtMedicaoHoraInicial = horaInicial;
        entity.TarDtMedicaoHoraFinal = horaFinal;
        entity.TarNrHorasTrabalhadas = horasTrab;
        entity.TarDtMedicaoHorimetroInicial = horimetroIni;
        entity.TarDtMedicaoHorimetroFinal = horimetroFim;
        entity.TarDtMedicaoHorimetroTotal = horimetroTotal;
        entity.TarDsComentario = request.Comentario ?? "";
        entity.TarCodigoParalizacao = string.IsNullOrWhiteSpace(request.CodigoParalizacao)
            ? null
            : request.CodigoParalizacao;
        entity.TarDtUltimaAtualizacao = DateTime.Now;
        if (request.Status == StatusFinalizada)
        {
            entity.TarDtFim = DateTime.Today;
        }

        await SyncVinculosAsync(entity.TarIdTarefa, obraId, request, cancellationToken);
        await SyncAcidentesAsync(entity.TarIdTarefa, request, cancellationToken);
        await SyncNovasImagensAsync(obraId, entity.TarIdTarefa, request.ListaImagens, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return new TarefaCadastroSaveResultDto { Ok = true, Id = entity.TarIdTarefa };
    }

    /// <summary>
    /// Persiste fotos novas (base64) em <c>Uploads/Imagens/{obra}/{tarefa}/{yyyyMM}/</c>
    /// e grava <c>imagem</c>. Paridade prod <c>SaveImages</c> + pasta por mês (melhoria Lucio).
    /// </summary>
    private async Task SyncNovasImagensAsync(
        int obraId,
        int tarefaId,
        List<TarefaCadastroImagemSaveDto>? lista,
        CancellationToken cancellationToken)
    {
        if (lista is null || lista.Count == 0 || tarefaId <= 0)
        {
            return;
        }

        var uploadsRoot = _configuration["FileStorage:UploadsRoot"];
        if (string.IsNullOrWhiteSpace(uploadsRoot))
        {
            uploadsRoot = Path.Combine(_env.ContentRootPath, "Uploads");
        }

        Directory.CreateDirectory(uploadsRoot);
        var ym = DateTime.Today.ToString("yyyyMM", CultureInfo.InvariantCulture);

        foreach (var item in lista)
        {
            var raw = (item.Base64 ?? "").Trim();
            if (raw.Length == 0)
            {
                continue;
            }

            var comma = raw.IndexOf(',');
            if (comma >= 0)
            {
                raw = raw[(comma + 1)..];
            }

            byte[] bytes;
            try
            {
                bytes = Convert.FromBase64String(raw);
            }
            catch (FormatException)
            {
                continue;
            }

            if (bytes.Length == 0 || bytes.Length > MaxFotoBytes)
            {
                continue;
            }

            var ext = ExtFromFiletype(item.Filetype);
            var fileName = Guid.NewGuid().ToString("N") + ext;
            var folderAbs = Path.Combine(
                uploadsRoot,
                "Imagens",
                obraId.ToString(CultureInfo.InvariantCulture),
                tarefaId.ToString(CultureInfo.InvariantCulture),
                ym);
            Directory.CreateDirectory(folderAbs);
            var abs = Path.Combine(folderAbs, fileName);
            await File.WriteAllBytesAsync(abs, bytes, cancellationToken);

            var caminhoDb = $"{obraId}/{tarefaId}/{ym}/{fileName}".Replace('\\', '/');
            _context.Imagens.Add(new Imagem
            {
                ImaDsCaminho = caminhoDb,
                ImaDtImagem = DateTime.Now,
                ImaIdTarefa = tarefaId
            });
        }
    }

    private static string ExtFromFiletype(string? filetype)
    {
        var t = (filetype ?? "").Trim().ToLowerInvariant();
        if (t.Contains("png", StringComparison.Ordinal))
        {
            return ".png";
        }

        if (t.Contains("bmp", StringComparison.Ordinal))
        {
            return ".bmp";
        }

        return ".jpg";
    }

    private async Task SyncAcidentesAsync(
        int tarefaId,
        TarefaCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        if (request.ListaAcidentes == null && request.ListaIdsAcidentesRemovidos == null)
        {
            return;
        }

        var removidos = (request.ListaIdsAcidentesRemovidos ?? [])
            .Where(id => id > 0)
            .Distinct()
            .ToHashSet();
        if (removidos.Count > 0)
        {
            var rows = await _context.Acidentes
                .Where(a => a.AciIdTarefa == tarefaId && removidos.Contains(a.AciIdAcidente))
                .ToListAsync(cancellationToken);
            var ids = rows.Select(r => r.AciIdAcidente).ToList();
            if (ids.Count > 0)
            {
                var links = await _context.AcidenteColaboradores
                    .Where(x => ids.Contains(x.AccIdAcidente))
                    .ToListAsync(cancellationToken);
                _context.AcidenteColaboradores.RemoveRange(links);
                _context.Acidentes.RemoveRange(rows);
            }
        }

        foreach (var item in request.ListaAcidentes ?? [])
        {
            var desc = (item.Descricao ?? "").Trim();
            if (desc.Length < 3)
            {
                continue;
            }

            DateTime? when = null;
            var raw = (item.DataHora ?? "").Trim();
            if (raw.Length > 0)
            {
                if (DateTime.TryParseExact(
                        raw,
                        new[] { "dd/MM/yyyy HH:mm", "dd/MM/yyyy", "yyyy-MM-dd HH:mm", "yyyy-MM-dd" },
                        PtBr,
                        DateTimeStyles.None,
                        out var parsed))
                {
                    when = parsed;
                }
            }

            if (item.Id > 0)
            {
                var existing = await _context.Acidentes
                    .FirstOrDefaultAsync(
                        a => a.AciIdAcidente == item.Id && a.AciIdTarefa == tarefaId,
                        cancellationToken);
                if (existing == null)
                {
                    continue;
                }

                existing.AciDsAcidente = desc;
                existing.AciDtDataHora = when;
                existing.AciStAfastamento = item.HouveAfastamento ? "s" : "n";
            }
            else
            {
                _context.Acidentes.Add(new Acidente
                {
                    AciIdTarefa = tarefaId,
                    AciDsAcidente = desc,
                    AciDtDataHora = when,
                    AciStAfastamento = item.HouveAfastamento ? "s" : "n",
                });
            }
        }
    }

    private async Task SyncVinculosAsync(
        int tarefaId,
        int obraId,
        TarefaCadastroSaveRequestDto request,
        CancellationToken cancellationToken)
    {
        if (request.ListaIdsObraColaborador != null)
        {
            var allowed = await _context.ObraColaboradores.AsNoTracking()
                .Where(x => x.OcoIdObra == obraId)
                .Select(x => x.OcoIdObraColaborador)
                .ToListAsync(cancellationToken);
            var allowedSet = allowed.ToHashSet();
            var wanted = request.ListaIdsObraColaborador.Where(allowedSet.Contains).Distinct().ToHashSet();
            var existing = await _context.ObraTarefaColaboradores
                .Where(x => x.OtcIdTarefa == tarefaId)
                .ToListAsync(cancellationToken);
            _context.ObraTarefaColaboradores.RemoveRange(
                existing.Where(e => !wanted.Contains(e.OtcIdObraColaborador)));
            var have = existing.Select(e => e.OtcIdObraColaborador).ToHashSet();
            foreach (var id in wanted.Where(id => !have.Contains(id)))
            {
                _context.ObraTarefaColaboradores.Add(new ObraTarefaColaborador
                {
                    OtcIdObraColaborador = id,
                    OtcIdTarefa = tarefaId
                });
            }
        }

        if (request.ListaIdsObraEquipamento != null)
        {
            var allowed = await _context.ObraEquipamentos.AsNoTracking()
                .Where(x => x.OeqIdObra == obraId)
                .Select(x => x.OeqIdObraEquipamento)
                .ToListAsync(cancellationToken);
            var allowedSet = allowed.ToHashSet();
            var wanted = request.ListaIdsObraEquipamento.Where(allowedSet.Contains).Distinct().ToHashSet();
            var existing = await _context.ObraTarefaEquipamentos
                .Where(x => x.OteIdTarefa == tarefaId)
                .ToListAsync(cancellationToken);
            _context.ObraTarefaEquipamentos.RemoveRange(
                existing.Where(e => !wanted.Contains(e.OteIdObraEquipamento)));
            var have = existing.Select(e => e.OteIdObraEquipamento).ToHashSet();
            foreach (var id in wanted.Where(id => !have.Contains(id)))
            {
                _context.ObraTarefaEquipamentos.Add(new ObraTarefaEquipamento
                {
                    OteIdObraEquipamento = id,
                    OteIdTarefa = tarefaId
                });
            }
        }
    }

    private static TarefaCadastroSaveResultDto Fail(string message) =>
        new() { Ok = false, ErrorMessage = message };

    private static bool TryParseDate(string? value, out DateTime date)
    {
        date = default;
        if (string.IsNullOrWhiteSpace(value))
        {
            return false;
        }

        return DateTime.TryParseExact(
            value.Trim(),
            new[] { "dd/MM/yyyy", "yyyy-MM-dd" },
            PtBr,
            DateTimeStyles.None,
            out date);
    }

    private static TimeSpan? ParseTime(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        var t = value.Trim();
        if (TimeSpan.TryParseExact(t, new[] { @"hh\:mm", @"hh\:mm\:ss" }, CultureInfo.InvariantCulture, out var ts))
        {
            return ts;
        }

        return TimeSpan.TryParse(t, CultureInfo.InvariantCulture, out ts) ? ts : null;
    }

    private static int? DiffHorasRelogio(TimeSpan? hi, TimeSpan? hf)
    {
        if (hi is null || hf is null || hf <= hi)
        {
            return null;
        }

        return (hf.Value - hi.Value).Hours;
    }
}
