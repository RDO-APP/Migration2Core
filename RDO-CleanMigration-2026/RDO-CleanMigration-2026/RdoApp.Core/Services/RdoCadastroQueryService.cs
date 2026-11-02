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

        var reps = etapaRows
            .SelectMany(etapa =>
            {
                var inEtapa = tarefas.Where(t => t.TarIdEtapa == etapa.EtaIdEtapa);
                return TarefaAgrupadorQuery.SelectRepresentantesParaRdo(inEtapa);
            })
            .ToList();

        var tarefaIds = reps.Select(t => t.TarIdTarefa).Distinct().ToList();
        var statusIds = reps.Select(t => t.TarIdStatus).Distinct().ToList();
        var statusMap = statusIds.Count == 0
            ? new Dictionary<int, string>()
            : await _context.StatusTarefas.AsNoTracking()
                .Where(s => statusIds.Contains(s.SttIdStatus))
                .Select(s => new { s.SttIdStatus, Nome = s.SttDsStatus ?? string.Empty })
                .ToDictionaryAsync(x => x.SttIdStatus, x => x.Nome, cancellationToken);

        var colabCounts = await LoadColaboradorCountsAsync(tarefaIds, cancellationToken);
        var equipCounts = await LoadEquipamentoCountsAsync(tarefaIds, cancellationToken);
        var agrupadores = reps.Select(t => t.TarNrAgrupador).Distinct().ToList();
        var imagensPorAgrupador = await LoadImagensPorAgrupadorAsync(agrupadores, data, cancellationToken);

        var etapas = new List<RdoCadastroEtapaDto>();
        foreach (var etapa in etapaRows)
        {
            var inEtapa = tarefas.Where(t => t.TarIdEtapa == etapa.EtaIdEtapa);
            var repsEtapa = TarefaAgrupadorQuery.SelectRepresentantesParaRdo(inEtapa);
            if (repsEtapa.Count == 0)
            {
                continue;
            }

            var dtoTarefas = repsEtapa.Select(t =>
            {
                var agrupador = t.TarNrAgrupador;
                var noDia = tarefas.Any(x =>
                    x.TarNrAgrupador == agrupador && x.TarDtMedicao.Date == data);
                var diaAnterior = tarefas.Any(x =>
                    x.TarNrAgrupador == agrupador && x.TarDtMedicao.Date == data.AddDays(-1));

                imagensPorAgrupador.TryGetValue(agrupador, out var imgs);

                return new RdoCadastroTarefaDto
                {
                    Id = t.TarIdTarefa,
                    Descricao = t.Descricao,
                    Status = t.TarIdStatus,
                    NomeStatus = statusMap.GetValueOrDefault(t.TarIdStatus, string.Empty),
                    IdEtapa = t.TarIdEtapa,
                    QuantidadeColaboradores = colabCounts.GetValueOrDefault(t.TarIdTarefa, 0),
                    QuantidadeEquipamentos = equipCounts.GetValueOrDefault(t.TarIdTarefa, 0),
                    ExisteRegistroMedicaoDataRequerida = noDia,
                    ExisteRegistroMedicaoDiaAnterior = diaAnterior,
                    ListaImagem = imgs ?? Array.Empty<RdoCadastroImagemDto>(),
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

    public async Task<RdoCadastroEditDto?> GetEditAsync(
        int obraId,
        int idRdo,
        CancellationToken cancellationToken)
    {
        var row = await _context.Rdos.AsNoTracking()
            .Where(r => r.RdoIdRdo == idRdo && r.RdoIdObra == obraId)
            .Select(r => new
            {
                r.RdoIdRdo,
                r.RdoDtRdo,
                r.RdoIdStatus,
                r.RdoIdImprodutividade,
                Comentario = (string?)r.RdoDsComentarioGeracao,
                ClimaManha = (string?)r.RdoDsClimaManha,
                ClimaTarde = (string?)r.RdoDsClimaTarde,
                ClimaNoite = (string?)r.RdoDsClimaNoite,
                ChuvaManha = (string?)r.RdoDsChuvaManha,
                ChuvaTarde = (string?)r.RdoDsChuvaTarde,
                ChuvaNoite = (string?)r.RdoDsChuvaNoite,
                TipoGeracao = (string?)r.RdoTpComentarioGeracao,
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            return null;
        }

        var imp = await _context.Improdutividades.AsNoTracking()
            .Where(i => i.ImpIdImprodutividade == row.RdoIdImprodutividade)
            .Select(i => new
            {
                i.ImpStClima,
                i.ImpStMaterial,
                i.ImpStParalizacao,
                i.ImpStEquipamento,
                i.ImpStContratante,
                i.ImpStFornecedores,
                i.ImpStMaodeobra,
                i.ImpStProjeto,
                i.ImpStPlanejamento,
                i.ImpStAcidentes,
            })
            .FirstOrDefaultAsync(cancellationToken);

        var tarefaIds = await _context.RdoTarefas.AsNoTracking()
            .Where(t => t.RtaIdRdo == idRdo)
            .Select(t => t.RtaIdTarefa)
            .ToListAsync(cancellationToken);

        var imagemIds = await _context.RdoImagens.AsNoTracking()
            .Where(i => i.RimIdRdo == idRdo)
            .Select(i => i.RimIdImagem)
            .ToListAsync(cancellationToken);

        var tp = (row.TipoGeracao ?? "").Trim().ToUpperInvariant();
        var tipoGeracao = tp == "P" ? 1 : tp == "N" ? 2 : 0;

        return new RdoCadastroEditDto
        {
            IdRdo = row.RdoIdRdo,
            DataRdo = row.RdoDtRdo.ToString("dd/MM/yyyy", PtBr),
            Comentario = row.Comentario ?? "",
            StatusRdo = row.RdoIdStatus,
            ClimaManha = row.ClimaManha ?? "",
            ClimaTarde = row.ClimaTarde ?? "",
            ClimaNoite = row.ClimaNoite ?? "",
            ChuvaManha = row.ChuvaManha ?? "",
            ChuvaTarde = row.ChuvaTarde ?? "",
            ChuvaNoite = row.ChuvaNoite ?? "",
            TipoComentarioGeracao = tipoGeracao,
            ImprodutividadeCondicoesClimaticas = imp?.ImpStClima ?? false,
            ImprodutividadeMateriais = imp?.ImpStMaterial ?? false,
            ImprodutividadeParalizacoes = imp?.ImpStParalizacao ?? false,
            ImprodutividadeEquipamentos = imp?.ImpStEquipamento ?? false,
            ImprodutividadeContratante = imp?.ImpStContratante ?? false,
            ImprodutividadeFornecedores = imp?.ImpStFornecedores ?? false,
            ImprodutividadeMaodeObra = imp?.ImpStMaodeobra ?? false,
            ImprodutividadeProjeto = imp?.ImpStProjeto ?? false,
            ImprodutividadePlanejamento = imp?.ImpStPlanejamento ?? false,
            ImprodutividadeAcidente = imp?.ImpStAcidentes ?? false,
            ListaTarefaIds = tarefaIds,
            ListaImagemIds = imagemIds,
        };
    }

    private async Task<Dictionary<int, int>> LoadColaboradorCountsAsync(
        List<int> tarefaIds,
        CancellationToken cancellationToken)
    {
        if (tarefaIds.Count == 0)
        {
            return new Dictionary<int, int>();
        }

        return await _context.ObraTarefaColaboradores.AsNoTracking()
            .Where(x => tarefaIds.Contains(x.OtcIdTarefa))
            .GroupBy(x => x.OtcIdTarefa)
            .Select(g => new { Id = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Id, x => x.Count, cancellationToken);
    }

    private async Task<Dictionary<int, int>> LoadEquipamentoCountsAsync(
        List<int> tarefaIds,
        CancellationToken cancellationToken)
    {
        if (tarefaIds.Count == 0)
        {
            return new Dictionary<int, int>();
        }

        return await _context.ObraTarefaEquipamentos.AsNoTracking()
            .Where(x => tarefaIds.Contains(x.OteIdTarefa))
            .GroupBy(x => x.OteIdTarefa)
            .Select(g => new { Id = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.Id, x => x.Count, cancellationToken);
    }

    /// <summary>Paridade <c>TarefaModel.ObterTodasImagensHistoricoMedicao</c>.</summary>
    private async Task<Dictionary<Guid, IReadOnlyList<RdoCadastroImagemDto>>> LoadImagensPorAgrupadorAsync(
        List<Guid> agrupadores,
        DateTime dataMedicao,
        CancellationToken cancellationToken)
    {
        if (agrupadores.Count == 0)
        {
            return new Dictionary<Guid, IReadOnlyList<RdoCadastroImagemDto>>();
        }

        var rows = await (
            from img in _context.Imagens.AsNoTracking()
            join t in _context.Tarefas.AsNoTracking() on img.ImaIdTarefa equals t.TarIdTarefa
            where agrupadores.Contains(t.TarNrAgrupador) && t.TarDtMedicao.Date <= dataMedicao.Date
            select new
            {
                t.TarNrAgrupador,
                img.ImaIdImagem,
                Caminho = img.ImaDsCaminho ?? "",
            }).ToListAsync(cancellationToken);

        return rows
            .GroupBy(x => x.TarNrAgrupador)
            .ToDictionary(
                g => g.Key,
                g => (IReadOnlyList<RdoCadastroImagemDto>)g
                    .GroupBy(x => x.ImaIdImagem)
                    .Select(x => x.First())
                    .Select(x => new RdoCadastroImagemDto
                    {
                        IdImagem = x.ImaIdImagem,
                        DsCaminho = NormalizeImagemCaminho(x.Caminho),
                    })
                    .Where(x => !string.IsNullOrWhiteSpace(x.DsCaminho))
                    .ToList());
    }

    private static string NormalizeImagemCaminho(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return string.Empty;
        }

        if (path.StartsWith("http://", StringComparison.OrdinalIgnoreCase)
            || path.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            return path;
        }

        var normalized = path.Replace('\\', '/').Trim();
        if (normalized.StartsWith('/'))
        {
            return normalized;
        }

        // Paridade prod: basePath + ima_ds_caminho → /Uploads/Imagens/{obra}/…
        return "/Uploads/Imagens/" + normalized.TrimStart('/');
    }
}
