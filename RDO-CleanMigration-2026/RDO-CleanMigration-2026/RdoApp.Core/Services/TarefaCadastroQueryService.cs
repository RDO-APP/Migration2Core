using System.Globalization;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;

namespace RdoApp.Core.Services;

/// <summary>M7 — GET cadastro tarefa (olho/lápis / P4). Paridade <c>TarefaModel.ObterRegistro</c>.</summary>
public class TarefaCadastroQueryService
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");
    private const int StatusRdoAssinado = 2;
    private const int StatusRdoAssinado2 = 3;
    private const int StatusPlanejadaConst = 1;

    private readonly RdoDbContext _context;

    public TarefaCadastroQueryService(RdoDbContext context)
    {
        _context = context;
    }

    public async Task<TarefaCadastroDto?> GetAsync(int obraId, int tarefaId, CancellationToken cancellationToken)
    {
        var row = await (
            from tar in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on tar.TarIdEtapa equals e.EtaIdEtapa
            where tar.TarIdTarefa == tarefaId && e.EtaIdObra == obraId
            select new
            {
                tar.TarIdTarefa,
                tar.TarNrAgrupador,
                tar.TarDsTarefa,
                tar.TarIdEtapa,
                tar.TarIdStatus,
                tar.TarIdUnidade,
                tar.TarDtInicio,
                tar.TarDtPrevisaoFim,
                tar.TarNrQtdPrevisao,
                tar.TarVlValorUnitario,
                tar.TarNrQtdConstruida,
                tar.TarDtMedicao,
                tar.TarDtMedicaoHoraInicial,
                tar.TarDtMedicaoHoraFinal,
                tar.TarDsComentario,
                tar.TarCodigoParalizacao,
                tar.TarDtMedicaoHorimetroInicial,
                tar.TarDtMedicaoHorimetroFinal,
                tar.TarDtMedicaoHorimetroTotal
            }
        ).FirstOrDefaultAsync(cancellationToken);

        if (row == null)
        {
            return null;
        }

        var t = row;

        var rdoAssinado = await (
            from rt in _context.RdoTarefas.AsNoTracking()
            join r in _context.Rdos.AsNoTracking() on rt.RtaIdRdo equals r.RdoIdRdo
            where rt.RtaIdTarefa == t.TarIdTarefa &&
                  (r.RdoIdStatus == StatusRdoAssinado || r.RdoIdStatus == StatusRdoAssinado2)
            select rt.RtaIdRta
        ).AnyAsync(cancellationToken);

        var statusNome = await _context.StatusTarefas.AsNoTracking()
            .Where(s => s.SttIdStatus == t.TarIdStatus)
            .Select(s => s.SttDsStatus)
            .FirstOrDefaultAsync(cancellationToken);

        var etapas = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdObra == obraId)
            .OrderBy(e => e.EtaNrOrderm)
            .Select(e => new TarefaLookupDto { Id = e.EtaIdEtapa, Nome = e.EtaDsEtapa ?? "" })
            .ToListAsync(cancellationToken);

        var status = await _context.StatusTarefas.AsNoTracking()
            .OrderBy(s => s.SttIdStatus)
            .Select(s => new TarefaLookupDto { Id = s.SttIdStatus, Nome = s.SttDsStatus ?? "" })
            .ToListAsync(cancellationToken);

        var unidades = await _context.UnidadesDeMedida.AsNoTracking()
            .OrderBy(u => u.UnmDsUnidade)
            .Select(u => new TarefaLookupDto { Id = u.UnmIdUnidade, Nome = u.UnmDsUnidade ?? "" })
            .ToListAsync(cancellationToken);

        var paralizacoes = await _context.TarefaCodigoParalizacoes.AsNoTracking()
            .OrderBy(p => p.TarcpCodigoParalizacao)
            .Select(p => new TarefaParalizacaoDto
            {
                Codigo = p.TarcpCodigoParalizacao,
                Descricao = p.TarcpDsParalizacao ?? ""
            })
            .ToListAsync(cancellationToken);

        var colaboradores = await LoadColaboradoresAsync(t.TarIdTarefa, cancellationToken);
        if (colaboradores.Count == 0)
        {
            var idsAgrupador = await _context.Tarefas.AsNoTracking()
                .Where(x => x.TarNrAgrupador == t.TarNrAgrupador)
                .Select(x => x.TarIdTarefa)
                .ToListAsync(cancellationToken);
            colaboradores = await LoadColaboradoresByTarefaIdsAsync(idsAgrupador, cancellationToken);
        }

        var equipamentos = await (
            from ote in _context.ObraTarefaEquipamentos.AsNoTracking()
            join oe in _context.ObraEquipamentos.AsNoTracking()
                on ote.OteIdObraEquipamento equals oe.OeqIdObraEquipamento
            join eq in _context.Equipamentos.AsNoTracking()
                on oe.OeqIdEquipamento equals eq.EquIdEquipamento
            join tp in _context.TipoEquipamentos.AsNoTracking()
                on eq.EquIdTipoEquipamento equals tp.TeqIdTipoEquipamento into tipos
            from tp in tipos.DefaultIfEmpty()
            where ote.OteIdTarefa == t.TarIdTarefa
            select new TarefaCadastroEquipamentoDto
            {
                Id = eq.EquIdEquipamento,
                IdObraEquipamento = oe.OeqIdObraEquipamento,
                TipoEquipamento = tp != null ? tp.TeqNmTipoEquipamento ?? "" : "",
                Descricao = eq.EquDsEquipamento ?? "",
                TipoAquisicao = oe.OeqTpAquisicao ?? "",
                FabricanteFornecedor = oe.OeqDsFabricanteFornecedor ?? "",
                Contato = oe.OeqDsContato ?? "",
                Telefone = oe.OeqDsTelefone ?? ""
            }).ToListAsync(cancellationToken);

        var historicoRaw = await (
            from tar in _context.Tarefas.AsNoTracking()
            join st in _context.StatusTarefas.AsNoTracking() on tar.TarIdStatus equals st.SttIdStatus
            join un in _context.UnidadesDeMedida.AsNoTracking() on tar.TarIdUnidade equals un.UnmIdUnidade into uns
            from un in uns.DefaultIfEmpty()
            join col in _context.Colaboradores.AsNoTracking()
                on tar.TarIdColaboradorInsercao equals col.ColIdColaborador into cols
            from col in cols.DefaultIfEmpty()
            where tar.TarNrAgrupador == t.TarNrAgrupador
            orderby tar.TarDtMedicao descending, tar.TarDtMedicaoHoraInicial descending, tar.TarDtUltimaAtualizacao descending
            select new
            {
                tar.TarIdTarefa,
                tar.TarDtMedicao,
                tar.TarDtMedicaoHoraInicial,
                tar.TarDtMedicaoHoraFinal,
                StatusNome = st.SttDsStatus,
                tar.TarDtMedicaoHorimetroInicial,
                tar.TarDtMedicaoHorimetroFinal,
                tar.TarDtMedicaoHorimetroTotal,
                tar.TarNrQtdConstruida,
                Unidade = un != null ? un.UnmDsUnidade : null,
                NomeColab = col != null ? col.ColNmColaborador : null
            }
        ).ToListAsync(cancellationToken);

        var histIds = historicoRaw.Select(h => h.TarIdTarefa).Distinct().ToList();
        var signed = histIds.Count == 0
            ? new HashSet<int>()
            : (await (
                from rt in _context.RdoTarefas.AsNoTracking()
                join r in _context.Rdos.AsNoTracking() on rt.RtaIdRdo equals r.RdoIdRdo
                where histIds.Contains(rt.RtaIdTarefa) &&
                      (r.RdoIdStatus == StatusRdoAssinado || r.RdoIdStatus == StatusRdoAssinado2)
                select rt.RtaIdTarefa
            ).Distinct().ToListAsync(cancellationToken)).ToHashSet();

        var historico = historicoRaw.Select(h => new TarefaCadastroHistoricoDto
        {
            IdTarefa = h.TarIdTarefa,
            Data = FormatDate(h.TarDtMedicao),
            HoraInicial = FormatTime(h.TarDtMedicaoHoraInicial),
            HoraFinal = FormatTime(h.TarDtMedicaoHoraFinal),
            DescricaoStatusTarefa = h.StatusNome ?? "",
            HorimetroInicial = h.TarDtMedicaoHorimetroInicial,
            HorimetroFinal = h.TarDtMedicaoHorimetroFinal,
            HorimetroTotal = h.TarDtMedicaoHorimetroTotal,
            QtdConstruida = h.TarNrQtdConstruida ?? 0,
            UnidadeMedida = h.Unidade ?? "",
            NomeColaborador = h.NomeColab ?? "",
            RdoAssinado = signed.Contains(h.TarIdTarefa)
        }).ToList();

        var imagens = (await _context.Imagens.AsNoTracking()
            .Where(i => i.ImaIdTarefa == t.TarIdTarefa)
            .OrderBy(i => i.ImaDtImagem)
            .Select(i => new { i.ImaIdImagem, i.ImaDsCaminho })
            .ToListAsync(cancellationToken))
            .Select(i => new TarefaCadastroImagemDto
            {
                Id = i.ImaIdImagem,
                Href = FotoHref(i.ImaDsCaminho ?? "")
            })
            .ToList();

        return new TarefaCadastroDto
        {
            Id = t.TarIdTarefa,
            Descricao = t.TarDsTarefa ?? "",
            IdEtapa = t.TarIdEtapa,
            Status = t.TarIdStatus,
            NomeStatus = statusNome ?? "",
            IdUnidade = t.TarIdUnidade ?? 0,
            DataInicio = FormatDate(t.TarDtInicio),
            DataPrevisaoFim = FormatDate(t.TarDtPrevisaoFim),
            QtdPlanejada = t.TarNrQtdPrevisao ?? 0,
            Valor = t.TarVlValorUnitario ?? 0,
            QtdConstruida = t.TarNrQtdConstruida ?? 0,
            DataMedicao = FormatDate(t.TarDtMedicao),
            HoraInicial = FormatTime(t.TarDtMedicaoHoraInicial),
            HoraFinal = FormatTime(t.TarDtMedicaoHoraFinal),
            HorimetroInicial = t.TarDtMedicaoHorimetroInicial ?? 0,
            HorimetroFinal = t.TarDtMedicaoHorimetroFinal ?? 0,
            HorimetroTotal = t.TarDtMedicaoHorimetroTotal ?? 0,
            Comentario = t.TarDsComentario ?? "",
            CodigoParalizacao = t.TarCodigoParalizacao,
            RdoAssinado = rdoAssinado,
            UltimoHorimetroFinal = await _context.Tarefas.AsNoTracking()
                .Where(x => x.TarNrAgrupador == t.TarNrAgrupador && x.TarIdTarefa != t.TarIdTarefa)
                .OrderByDescending(x => x.TarDtMedicao)
                .Select(x => (float?)x.TarDtMedicaoHorimetroFinal)
                .FirstOrDefaultAsync(cancellationToken),
            ListaColaboradores = colaboradores,
            ListaEquipamentos = equipamentos,
            Etapas = etapas,
            StatusTarefa = status,
            Unidades = unidades,
            CodigosParalizacao = paralizacoes,
            ListaHistoricoTarefa = historico,
            ListaImagens = imagens,
            ListaAcidentes = (await _context.Acidentes.AsNoTracking()
                .Where(a => a.AciIdTarefa == t.TarIdTarefa)
                .OrderByDescending(a => a.AciDtDataHora)
                .Select(a => new
                {
                    a.AciIdAcidente,
                    a.AciDsAcidente,
                    a.AciDtDataHora,
                    a.AciStAfastamento
                })
                .ToListAsync(cancellationToken))
                .Select(a => new TarefaCadastroAcidenteDto
                {
                    Id = a.AciIdAcidente,
                    Descricao = a.AciDsAcidente ?? "",
                    DataHora = FormatDateTime(a.AciDtDataHora),
                    HouveAfastamento = a.AciStAfastamento == "s"
                })
                .ToList(),
            ColaboradoresObra = await LoadColaboradoresObraAsync(obraId, cancellationToken),
            EquipamentosObra = await LoadEquipamentosObraAsync(obraId, cancellationToken)
        };
    }


    public async Task<TarefaCadastroDto> GetBlankAsync(
        int obraId,
        int? etapaId,
        CancellationToken cancellationToken)
    {
        var etapas = await _context.Etapas.AsNoTracking()
            .Where(e => e.EtaIdObra == obraId)
            .OrderBy(e => e.EtaNrOrderm)
            .Select(e => new TarefaLookupDto { Id = e.EtaIdEtapa, Nome = e.EtaDsEtapa ?? "" })
            .ToListAsync(cancellationToken);

        var status = await _context.StatusTarefas.AsNoTracking()
            .OrderBy(s => s.SttIdStatus)
            .Select(s => new TarefaLookupDto { Id = s.SttIdStatus, Nome = s.SttDsStatus ?? "" })
            .ToListAsync(cancellationToken);

        var unidades = await _context.UnidadesDeMedida.AsNoTracking()
            .OrderBy(u => u.UnmDsUnidade)
            .Select(u => new TarefaLookupDto { Id = u.UnmIdUnidade, Nome = u.UnmDsUnidade ?? "" })
            .ToListAsync(cancellationToken);

        var paralizacoes = await _context.TarefaCodigoParalizacoes.AsNoTracking()
            .OrderBy(p => p.TarcpCodigoParalizacao)
            .Select(p => new TarefaParalizacaoDto
            {
                Codigo = p.TarcpCodigoParalizacao,
                Descricao = p.TarcpDsParalizacao ?? ""
            })
            .ToListAsync(cancellationToken);

        var idEtapa = 0;
        if (etapaId is > 0 && etapas.Any(e => e.Id == etapaId.Value))
        {
            idEtapa = etapaId.Value;
        }

        return new TarefaCadastroDto
        {
            Id = 0,
            Descricao = "",
            IdEtapa = idEtapa,
            Status = StatusPlanejadaConst,
            NomeStatus = "Planejada",
            IdUnidade = 0,
            DataInicio = "",
            DataPrevisaoFim = "",
            QtdPlanejada = 0,
            Valor = 0,
            QtdConstruida = 0,
            DataMedicao = "",
            HoraInicial = "",
            HoraFinal = "",
            HorimetroInicial = 0,
            HorimetroFinal = 0,
            HorimetroTotal = 0,
            Comentario = "",
            CodigoParalizacao = null,
            RdoAssinado = false,
            ListaColaboradores = Array.Empty<TarefaCadastroColaboradorDto>(),
            ListaEquipamentos = Array.Empty<TarefaCadastroEquipamentoDto>(),
            Etapas = etapas,
            StatusTarefa = status,
            Unidades = unidades,
            CodigosParalizacao = paralizacoes,
            ListaHistoricoTarefa = Array.Empty<TarefaCadastroHistoricoDto>(),
            ListaImagens = Array.Empty<TarefaCadastroImagemDto>(),
            ListaAcidentes = Array.Empty<TarefaCadastroAcidenteDto>(),
            ColaboradoresObra = await LoadColaboradoresObraAsync(obraId, cancellationToken),
            EquipamentosObra = await LoadEquipamentosObraAsync(obraId, cancellationToken)
        };
    }

    private async Task<List<TarefaCadastroColaboradorDto>> LoadColaboradoresAsync(
        int tarefaId,
        CancellationToken cancellationToken) =>
        await LoadColaboradoresByTarefaIdsAsync(new[] { tarefaId }, cancellationToken);

    private async Task<List<TarefaCadastroColaboradorDto>> LoadColaboradoresByTarefaIdsAsync(
        IReadOnlyList<int> tarefaIds,
        CancellationToken cancellationToken)
    {
        if (tarefaIds.Count == 0)
        {
            return new List<TarefaCadastroColaboradorDto>();
        }

        var rows = await (
            from otc in _context.ObraTarefaColaboradores.AsNoTracking()
            join oc in _context.ObraColaboradores.AsNoTracking()
                on otc.OtcIdObraColaborador equals oc.OcoIdObraColaborador
            join c in _context.Colaboradores.AsNoTracking()
                on oc.OcoIdColaborador equals c.ColIdColaborador
            join cargo in _context.Cargos.AsNoTracking()
                on oc.OcoIdCargo equals cargo.CarIdCargo into cargos
            from cargo in cargos.DefaultIfEmpty()
            join g in _context.Grupos.AsNoTracking()
                on oc.OcoIdGrupo equals g.GruIdGrupo into grupos
            from g in grupos.DefaultIfEmpty()
            where tarefaIds.Contains(otc.OtcIdTarefa)
            select new TarefaCadastroColaboradorDto
            {
                Id = c.ColIdColaborador,
                IdObraColaborador = oc.OcoIdObraColaborador,
                Nome = c.ColNmColaborador ?? "",
                DescricaoCargo = cargo != null ? cargo.CarDsCargo ?? "" : "",
                TelefonePrincipal = c.ColDsTelefonePrincipal ?? "",
                Email = c.ColDsEmail ?? "",
                DescricaoGrupo = g != null ? g.GruNmNome ?? "" : ""
            }).ToListAsync(cancellationToken);

        return rows.GroupBy(x => x.IdObraColaborador).Select(g => g.First()).ToList();
    }

    private async Task<List<TarefaCadastroColaboradorDto>> LoadColaboradoresObraAsync(
        int obraId,
        CancellationToken cancellationToken)
    {
        var rows = await (
            from oc in _context.ObraColaboradores.AsNoTracking()
            join c in _context.Colaboradores.AsNoTracking()
                on oc.OcoIdColaborador equals c.ColIdColaborador
            join cargo in _context.Cargos.AsNoTracking()
                on oc.OcoIdCargo equals cargo.CarIdCargo into cargos
            from cargo in cargos.DefaultIfEmpty()
            join g in _context.Grupos.AsNoTracking()
                on oc.OcoIdGrupo equals g.GruIdGrupo into grupos
            from g in grupos.DefaultIfEmpty()
            where oc.OcoIdObra == obraId
            orderby c.ColNmColaborador
            select new TarefaCadastroColaboradorDto
            {
                Id = c.ColIdColaborador,
                IdObraColaborador = oc.OcoIdObraColaborador,
                Nome = c.ColNmColaborador ?? "",
                DescricaoCargo = cargo != null ? cargo.CarDsCargo ?? "" : "",
                TelefonePrincipal = c.ColDsTelefonePrincipal ?? "",
                Email = c.ColDsEmail ?? "",
                DescricaoGrupo = g != null ? g.GruNmNome ?? "" : ""
            }).ToListAsync(cancellationToken);

        return rows.GroupBy(x => x.IdObraColaborador).Select(g => g.First()).ToList();
    }

    private async Task<List<TarefaCadastroEquipamentoDto>> LoadEquipamentosObraAsync(
        int obraId,
        CancellationToken cancellationToken)
    {
        return await (
            from oe in _context.ObraEquipamentos.AsNoTracking()
            join eq in _context.Equipamentos.AsNoTracking()
                on oe.OeqIdEquipamento equals eq.EquIdEquipamento
            join tp in _context.TipoEquipamentos.AsNoTracking()
                on eq.EquIdTipoEquipamento equals tp.TeqIdTipoEquipamento into tipos
            from tp in tipos.DefaultIfEmpty()
            where oe.OeqIdObra == obraId
            orderby eq.EquDsEquipamento
            select new TarefaCadastroEquipamentoDto
            {
                Id = eq.EquIdEquipamento,
                IdObraEquipamento = oe.OeqIdObraEquipamento,
                TipoEquipamento = tp != null ? tp.TeqNmTipoEquipamento ?? "" : "",
                Descricao = eq.EquDsEquipamento ?? "",
                TipoAquisicao = oe.OeqTpAquisicao ?? "",
                FabricanteFornecedor = oe.OeqDsFabricanteFornecedor ?? "",
                Contato = oe.OeqDsContato ?? "",
                Telefone = oe.OeqDsTelefone ?? ""
            }).ToListAsync(cancellationToken);
    }

    private static string FotoHref(string path)
    {
        var p = path.Replace("~", "", StringComparison.Ordinal).Replace("\\", "/", StringComparison.Ordinal).Trim();
        if (p.Length == 0)
        {
            return "";
        }

        if (p.StartsWith("http", StringComparison.OrdinalIgnoreCase))
        {
            return p;
        }

        if (!p.StartsWith('/'))
        {
            p = "/" + p;
        }

        if (p.StartsWith("/Uploads/", StringComparison.OrdinalIgnoreCase) ||
            p.StartsWith("/Upload/", StringComparison.OrdinalIgnoreCase))
        {
            return p;
        }

        return "/Uploads/Imagens" + p;
    }

    private static string FormatDate(DateTime? value) =>
        value.HasValue ? value.Value.ToString("dd/MM/yyyy", PtBr) : "";

    private static string FormatDateTime(DateTime? value) =>
        value.HasValue ? value.Value.ToString("dd/MM/yyyy HH:mm", PtBr) : "";

    private static string FormatTime(TimeSpan? value)
    {
        if (!value.HasValue)
        {
            return "";
        }

        return value.Value.ToString(@"hh\:mm");
    }
}
