using System.Globalization;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;
using static RdoApp.Core.Services.CardsTarefaParity;

namespace RdoApp.Core.Controllers;

/// <summary>
/// M6 Bearer C — paridade legado <c>/api/tarefa/*</c> (JWT).
/// Reusa TarefaCadastro* / Status / HorasEquipamento (mesma fonte BFF cookie).
/// </summary>
[ApiController]
[Route("api/tarefa")]
[EnableCors("MobileJwt")]
[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
public sealed class MobileTarefaLegacyController : ControllerBase
{
    private static readonly CultureInfo PtBr = CultureInfo.GetCultureInfo("pt-BR");

    private readonly RdoDbContext _context;
    private readonly TarefaCadastroQueryService _query;
    private readonly TarefaCadastroSaveService _save;
    private readonly TarefaStatusUpdateService _status;
    private readonly HorasEquipamentoReportService _horas;
    private readonly ILogger<MobileTarefaLegacyController> _logger;

    public MobileTarefaLegacyController(
        RdoDbContext context,
        TarefaCadastroQueryService query,
        TarefaCadastroSaveService save,
        TarefaStatusUpdateService status,
        HorasEquipamentoReportService horas,
        ILogger<MobileTarefaLegacyController> logger)
    {
        _context = context;
        _query = query;
        _save = save;
        _status = status;
        _horas = horas;
        _logger = logger;
    }

    public sealed class IdBody
    {
        public int Id { get; set; }
    }

    public sealed class RelatorioBody
    {
        public string? DataInicial { get; set; }
        public string? DataFinal { get; set; }
        public string? TipoRelatorio { get; set; }
        public string? DescricaoTarefa { get; set; }
        public int IdTarefa { get; set; }
        public int IdObra { get; set; }
    }

    public sealed class AtualizarStatusBody
    {
        public JsonElement? Tarefa { get; set; }
        public int IdStatus { get; set; }
        public int IdColaboradorInsercao { get; set; }
    }

    [HttpPost("ObterTarefa")]
    public async Task<IActionResult> ObterTarefa(
        [FromBody] JsonElement body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        if (!TryReadInt(body, out var tarefaId) || tarefaId <= 0)
        {
            return BadRequest(new { message = "idTarefa inválido." });
        }

        if (!await TryResolveObraForTarefaAsync(tarefaId, colaboradorId, obraFromBody: null, cancellationToken)
                .ConfigureAwait(false))
        {
            return Unauthorized(new { message = "Sem permissão para esta tarefa." });
        }

        var obraId = _resolvedObraId;
        var dto = await _query.GetAsync(obraId, tarefaId, cancellationToken);
        if (dto is null)
        {
            return NotFound(new { message = "Tarefa não encontrada." });
        }

        var historico = await LoadHistoricoMobileAsync(tarefaId, cancellationToken);
        return Ok(MapObterTarefa(dto, historico));
    }

    [HttpPost("CarregarHistoricoTarefa")]
    public async Task<IActionResult> CarregarHistoricoTarefa(
        [FromBody] IdBody? body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        var tarefaId = body?.Id ?? 0;
        if (tarefaId <= 0)
        {
            return BadRequest(new { message = "id inválido." });
        }

        if (!await TryResolveObraForTarefaAsync(tarefaId, colaboradorId, null, cancellationToken))
        {
            return Unauthorized(new { message = "Sem permissão para esta tarefa." });
        }

        var lista = await LoadHistoricoMobileAsync(tarefaId, cancellationToken);
        return Ok(lista);
    }

    [HttpPost("ObterImagensTarefa")]
    public async Task<IActionResult> ObterImagensTarefa(
        [FromBody] JsonElement body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        if (!TryReadInt(body, out var tarefaId) || tarefaId <= 0)
        {
            return BadRequest(new { message = "idTarefa inválido." });
        }

        if (!await TryResolveObraForTarefaAsync(tarefaId, colaboradorId, null, cancellationToken))
        {
            return Unauthorized(new { message = "Sem permissão para esta tarefa." });
        }

        var imagens = await _context.Imagens.AsNoTracking()
            .Where(i => i.ImaIdTarefa == tarefaId)
            .OrderBy(i => i.ImaDtImagem)
            .Select(i => new { i.ImaIdImagem, i.ImaDsCaminho })
            .ToListAsync(cancellationToken);

        var lista = imagens
            .Where(i => !string.IsNullOrWhiteSpace(i.ImaDsCaminho))
            .Select(i => new { id = i.ImaIdImagem, href = FotoHref(i.ImaDsCaminho!) })
            .Where(i => !string.IsNullOrWhiteSpace(i.href))
            .ToList();

        return Ok(lista);
    }

    [HttpPost("CarregarHorimetroFinalUltimoHistoricoTarefa")]
    public async Task<IActionResult> CarregarHorimetroFinalUltimoHistoricoTarefa(
        [FromBody] IdBody? body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        var tarefaId = body?.Id ?? 0;
        if (tarefaId <= 0)
        {
            return BadRequest(new { message = "id inválido." });
        }

        if (!await TryResolveObraForTarefaAsync(tarefaId, colaboradorId, null, cancellationToken))
        {
            return Unauthorized(new { message = "Sem permissão para esta tarefa." });
        }

        var agrupador = await _context.Tarefas.AsNoTracking()
            .Where(t => t.TarIdTarefa == tarefaId)
            .Select(t => t.TarNrAgrupador)
            .FirstOrDefaultAsync(cancellationToken);

        if (agrupador == Guid.Empty)
        {
            return Ok(null);
        }

        var horimetro = await _context.Tarefas.AsNoTracking()
            .Where(t => t.TarNrAgrupador == agrupador && t.TarIdTarefa != tarefaId)
            .OrderByDescending(t => t.TarDtMedicao)
            .ThenByDescending(t => t.TarDtMedicaoHoraInicial)
            .Select(t => t.TarDtMedicaoHorimetroFinal)
            .FirstOrDefaultAsync(cancellationToken);

        return Ok(horimetro);
    }

    [HttpGet("paralizacoes/GetCodigosParalizacoes")]
    public async Task<IActionResult> GetCodigosParalizacoes(CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        var lista = await _context.TarefaCodigoParalizacoes.AsNoTracking()
            .OrderBy(p => p.TarcpCodigoParalizacao)
            .Select(p => new
            {
                codigo = p.TarcpCodigoParalizacao,
                descricao = p.TarcpDsParalizacao ?? "",
            })
            .ToListAsync(cancellationToken);

        return Ok(lista);
    }

    [HttpPost("Salvar")]
    [RequestSizeLimit(40_000_000)]
    public async Task<IActionResult> Salvar(
        [FromBody] JsonElement body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        if (body.ValueKind is not JsonValueKind.Object)
        {
            return BadRequest(new { resultado = false, mensagem = "Corpo inválido." });
        }

        var request = MapSalvarRequest(body);
        if (request.Id <= 0 && !request.NovaMedicao)
        {
            // create raro no app; exige idEtapa + obra
        }

        int? obraBody = ReadIntProp(body, "idObra") ?? ReadIntProp(body, "IdObra");
        int obraId;

        if (request.Id > 0)
        {
            if (!await TryResolveObraForTarefaAsync(request.Id, colaboradorId, obraBody, cancellationToken))
            {
                return Unauthorized(new { resultado = false, mensagem = "Sem permissão para esta tarefa." });
            }

            obraId = _resolvedObraId;
        }
        else if (obraBody is > 0)
        {
            if (!await TemAcessoObraAsync(colaboradorId, obraBody.Value, cancellationToken))
            {
                return Unauthorized(new { resultado = false, mensagem = "Sem permissão para esta obra." });
            }

            obraId = obraBody.Value;
        }
        else
        {
            return BadRequest(new { resultado = false, mensagem = "Obra/tarefa inválida." });
        }

        var result = await _save.SaveAsync(obraId, colaboradorId, request, cancellationToken);
        if (!result.Ok)
        {
            return BadRequest(new
            {
                resultado = false,
                mensagem = result.ErrorMessage ?? "Falha ao salvar.",
                idTarefa = result.Id,
            });
        }

        // App checa resultado / idTarefa (legado devolve bool).
        return Ok(new
        {
            resultado = true,
            idTarefa = result.Id,
            ok = true,
            id = result.Id,
            imagensGravadas = result.ImagensGravadas,
        });
    }

    [HttpPost("AtualizarStatus")]
    public async Task<IActionResult> AtualizarStatus(
        [FromBody] AtualizarStatusBody? body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        if (body is null || body.IdStatus <= 0)
        {
            return BadRequest(new { resultado = false, mensagem = "Status inválido." });
        }

        var tarefaId = 0;
        if (body.Tarefa is { ValueKind: JsonValueKind.Object } t)
        {
            if (t.TryGetProperty("id", out var idEl) && idEl.TryGetInt32(out var id))
            {
                tarefaId = id;
            }
        }

        if (tarefaId <= 0)
        {
            return BadRequest(new { resultado = false, mensagem = "Tarefa inválida." });
        }

        if (!await TryResolveObraForTarefaAsync(tarefaId, colaboradorId, null, cancellationToken))
        {
            return Unauthorized(new { resultado = false, mensagem = "Sem permissão." });
        }

        var result = await _status.AtualizarAsync(
            _resolvedObraId,
            colaboradorId,
            tarefaId,
            body.IdStatus,
            cancellationToken);

        if (!result.Ok)
        {
            return BadRequest(new
            {
                resultado = false,
                mensagem = result.ErrorMessage ?? "Falha ao atualizar status.",
            });
        }

        return Ok(new { resultado = true, id = result.Id ?? tarefaId });
    }

    [HttpPost("GerarRelatorioControleHorasEquipamentoTarefa")]
    public async Task<IActionResult> GerarRelatorio(
        [FromBody] RelatorioBody? body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        if (body is null || body.IdTarefa <= 0)
        {
            return BadRequest(new { message = "idTarefa inválido." });
        }

        if (!await TryResolveObraForTarefaAsync(
                body.IdTarefa,
                colaboradorId,
                body.IdObra > 0 ? body.IdObra : null,
                cancellationToken))
        {
            return Unauthorized(new { message = "Sem permissão." });
        }

        var req = new HorasEquipamentoReportRequestDto
        {
            DataInicial = ToBrDate(body.DataInicial),
            DataFinal = ToBrDate(body.DataFinal),
            TipoRelatorio = string.IsNullOrWhiteSpace(body.TipoRelatorio) ? "PDF" : body.TipoRelatorio!,
            DescricaoTarefa = body.DescricaoTarefa,
        };

        try
        {
            var file = await _horas.GenerateAsync(_resolvedObraId, body.IdTarefa, req, cancellationToken);
            // Legado Web API serializa byte[] → base64 string no JSON.
            return Ok(Convert.ToBase64String(file.Bytes));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Relatório horas JWT tarefa {Id}", body.IdTarefa);
            return StatusCode(500, new { message = ex.Message });
        }
    }

    // --- helpers ---

    private int _resolvedObraId;

    private async Task<bool> TryResolveObraForTarefaAsync(
        int tarefaId,
        int colaboradorId,
        int? obraFromBody,
        CancellationToken cancellationToken)
    {
        _resolvedObraId = 0;

        var row = await (
            from tar in _context.Tarefas.AsNoTracking()
            join e in _context.Etapas.AsNoTracking() on tar.TarIdEtapa equals e.EtaIdEtapa
            where tar.TarIdTarefa == tarefaId
            select new { e.EtaIdObra }
        ).FirstOrDefaultAsync(cancellationToken);

        if (row is null)
        {
            return false;
        }

        var obraId = row.EtaIdObra;
        if (obraFromBody is > 0 && obraFromBody.Value != obraId)
        {
            _logger.LogWarning(
                "Tarefa {TarefaId}: body obra {Body} ≠ etapa obra {Obra}",
                tarefaId,
                obraFromBody,
                obraId);
        }

        // Prefer claim pós-LoginObra se bater; senão obra da tarefa.
        var claimObra = User.FindFirstValue("obraId");
        if (!string.IsNullOrEmpty(claimObra)
            && int.TryParse(claimObra, out var jwtObra)
            && jwtObra > 0
            && jwtObra != obraId)
        {
            _logger.LogWarning(
                "Tarefa {TarefaId}: JWT obra {Jwt} ≠ tarefa obra {Obra} — usando obra da tarefa",
                tarefaId,
                jwtObra,
                obraId);
        }

        if (!await TemAcessoObraAsync(colaboradorId, obraId, cancellationToken))
        {
            return false;
        }

        _resolvedObraId = obraId;
        return true;
    }

    private Task<bool> TemAcessoObraAsync(int colaboradorId, int obraId, CancellationToken ct) =>
        _context.ObraColaboradores.AsNoTracking()
            .AnyAsync(oc => oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == obraId, ct);

    private async Task<List<object>> LoadHistoricoMobileAsync(int tarefaId, CancellationToken ct)
    {
        var agrupador = await _context.Tarefas.AsNoTracking()
            .Where(t => t.TarIdTarefa == tarefaId)
            .Select(t => t.TarNrAgrupador)
            .FirstOrDefaultAsync(ct);

        if (agrupador == Guid.Empty)
        {
            return new List<object>();
        }

        var raw = await (
            from tar in _context.Tarefas.AsNoTracking()
            join st in _context.StatusTarefas.AsNoTracking() on tar.TarIdStatus equals st.SttIdStatus
            join un in _context.UnidadesDeMedida.AsNoTracking() on tar.TarIdUnidade equals un.UnmIdUnidade into uns
            from un in uns.DefaultIfEmpty()
            join col in _context.Colaboradores.AsNoTracking()
                on tar.TarIdColaboradorInsercao equals col.ColIdColaborador into cols
            from col in cols.DefaultIfEmpty()
            where tar.TarNrAgrupador == agrupador
            orderby tar.TarDtMedicao descending, tar.TarDtMedicaoHoraInicial descending, tar.TarDtUltimaAtualizacao descending
            select new
            {
                tar.TarIdTarefa,
                tar.TarIdStatus,
                tar.TarCodigoParalizacao,
                tar.TarDtMedicao,
                tar.TarDtMedicaoHoraInicial,
                tar.TarDtMedicaoHoraFinal,
                StatusNome = st.SttDsStatus,
                tar.TarDtMedicaoHorimetroInicial,
                tar.TarDtMedicaoHorimetroFinal,
                tar.TarDtMedicaoHorimetroTotal,
                tar.TarNrQtdConstruida,
                tar.TarVlValorUnitario,
                tar.TarDsComentario,
                Unidade = un != null ? un.UnmDsUnidade : null,
                Nome = col != null ? col.ColNmColaborador : null,
                Cpf = col != null ? col.ColNrCpf : null,
            }
        ).ToListAsync(ct);

        var ids = raw.Select(r => r.TarIdTarefa).Distinct().ToList();
        var signed = ids.Count == 0
            ? new HashSet<int>()
            : (await (
                from rt in _context.RdoTarefas.AsNoTracking()
                join r in _context.Rdos.AsNoTracking() on rt.RtaIdRdo equals r.RdoIdRdo
                where ids.Contains(rt.RtaIdTarefa) && (r.RdoIdStatus == 2 || r.RdoIdStatus == 3)
                select rt.RtaIdTarefa
            ).Distinct().ToListAsync(ct)).ToHashSet();

        return raw.Select(h => (object)new
        {
            idHistoricoTarefa = 0,
            idTarefa = h.TarIdTarefa,
            idStatusTarefa = h.TarIdStatus,
            codigoParalizacao = h.TarCodigoParalizacao ?? "",
            dataStatus = h.TarDtMedicao.ToString("yyyy-MM-ddT00:00:00"),
            dataMedicaoTela = h.TarDtMedicao.ToString("dd/MM/yyyy HH:mm:ss", PtBr),
            data = h.TarDtMedicao.ToString("dd/MM/yyyy", PtBr),
            descricaoStatusTarefa = h.StatusNome ?? "",
            cpfColaborador = h.Cpf ?? "",
            nomeColaborador = h.Nome ?? "",
            horaInicial = FormatTimeSpan(h.TarDtMedicaoHoraInicial),
            horaFinal = FormatTimeSpan(h.TarDtMedicaoHoraFinal),
            horimetroInicial = h.TarDtMedicaoHorimetroInicial,
            horimetroFinal = h.TarDtMedicaoHorimetroFinal,
            horimetroTotal = h.TarDtMedicaoHorimetroTotal,
            qtdConstruida = h.TarNrQtdConstruida ?? 0,
            rdoAssinado = signed.Contains(h.TarIdTarefa),
            unidade = h.TarVlValorUnitario ?? 0,
            unidadeMedida = h.Unidade ?? "",
            comentario = h.TarDsComentario ?? "",
        }).ToList();
    }

    private static object MapObterTarefa(TarefaCadastroDto dto, List<object> historico) => new
    {
        id = dto.Id,
        descricao = dto.Descricao,
        status = dto.Status,
        nomeStatus = dto.NomeStatus,
        codigoParalizacao = dto.CodigoParalizacao ?? "",
        idEtapa = dto.IdEtapa,
        idRdo = 0,
        idUnidade = dto.IdUnidade,
        qtdPlanejada = dto.QtdPlanejada,
        valor = dto.Valor,
        qtdConstruida = dto.QtdConstruida,
        comentario = dto.Comentario,
        dataInicio = dto.DataInicio,
        dataPrevisaoFim = dto.DataPrevisaoFim,
        dataMedicaoTela = string.IsNullOrWhiteSpace(dto.DataMedicao)
            ? ""
            : (TryParseFlexibleDate(dto.DataMedicao, out var dm)
                ? dm.ToString("dd/MM/yyyy HH:mm:ss", PtBr)
                : dto.DataMedicao),
        dataMedicao = dto.DataMedicao,
        horaInicial = NormalizeTime(dto.HoraInicial),
        horaFinal = NormalizeTime(dto.HoraFinal),
        horimetroInicial = dto.HorimetroInicial,
        horimetroFinal = dto.HorimetroFinal,
        horimetroTotal = dto.HorimetroTotal,
        ultimoHorimetroFinal = dto.UltimoHorimetroFinal,
        rdoAssinado = dto.RdoAssinado,
        listaColaboradores = dto.ListaColaboradores,
        listaEquipamentos = dto.ListaEquipamentos,
        listaHistoricoTarefa = historico,
        listaImagens = dto.ListaImagens.Select(i => new { id = i.Id, href = i.Href }).ToList(),
        listaAcidentes = dto.ListaAcidentes,
        listaColaboradoresObra = dto.ColaboradoresObra,
        listaEquipamentosObra = dto.EquipamentosObra,
        listaStatusPermitidos = IdsStatusPermitidos(dto.Status).Select(id => new
        {
            id,
            nome = id switch
            {
                1 => "Planejada",
                2 => "Em Execução",
                3 => "Finalizada",
                4 => "Pausada",
                5 => "Cancelada",
                _ => id.ToString(),
            },
            cssClass = id switch
            {
                1 => "bg-cinza",
                2 => "bg-azul",
                3 => "bg-verde",
                4 => "bg-laranja",
                5 => "bg-vermelho",
                _ => "bg-cinza",
            },
        }).ToList(),
        marcado = false,
    };

    private static TarefaCadastroSaveRequestDto MapSalvarRequest(JsonElement body)
    {
        var req = new TarefaCadastroSaveRequestDto
        {
            Id = ReadIntProp(body, "id") ?? 0,
            NovaMedicao = ReadBoolProp(body, "novaMedicao") ?? false,
            Descricao = ReadStringProp(body, "descricao") ?? "",
            IdEtapa = ReadIntProp(body, "idEtapa") ?? 0,
            Status = ReadIntProp(body, "status") ?? ReadIntProp(body, "idStatus") ?? 0,
            IdUnidade = ReadIntProp(body, "idUnidade") ?? 0,
            DataInicio = NormalizeDateForSave(ReadStringProp(body, "dataInicio")),
            DataPrevisaoFim = NormalizeDateForSave(ReadStringProp(body, "dataPrevisaoFim")),
            QtdPlanejada = ReadDecimalProp(body, "qtdPlanejada"),
            Valor = ReadDecimalProp(body, "valor"),
            QtdConstruida = ReadFloatProp(body, "qtdConstruida"),
            DataMedicao = NormalizeDateForSave(
                ReadStringProp(body, "dataMedicao")
                ?? ReadStringProp(body, "dataMedicaoTela")),
            HoraInicial = ReadStringProp(body, "horaInicial"),
            HoraFinal = ReadStringProp(body, "horaFinal"),
            HorimetroInicial = ReadFloatProp(body, "horimetroInicial"),
            HorimetroFinal = ReadFloatProp(body, "horimetroFinal"),
            HorimetroTotal = ReadFloatProp(body, "horimetroTotal"),
            Comentario = ReadStringProp(body, "comentario"),
            CodigoParalizacao = ReadStringProp(body, "codigoParalizacao"),
        };

        if (body.TryGetProperty("listaImagens", out var imgs) && imgs.ValueKind == JsonValueKind.Array)
        {
            req.ListaImagens = new List<TarefaCadastroImagemSaveDto>();
            foreach (var img in imgs.EnumerateArray())
            {
                req.ListaImagens.Add(new TarefaCadastroImagemSaveDto
                {
                    Id = ReadIntProp(img, "id") ?? 0,
                    Href = ReadStringProp(img, "href"),
                    Base64 = ReadStringProp(img, "base64"),
                    Filetype = ReadStringProp(img, "filetype") ?? ReadStringProp(img, "mimeType"),
                });
            }
        }

        // Mobile manda listas de objetos; extrair ids obraColaborador / obraEquipamento se presentes.
        if (body.TryGetProperty("listaColaboradores", out var cols) && cols.ValueKind == JsonValueKind.Array)
        {
            var ids = new List<int>();
            foreach (var c in cols.EnumerateArray())
            {
                var id = ReadIntProp(c, "idObraColaborador") ?? ReadIntProp(c, "IdObraColaborador");
                if (id is > 0)
                {
                    ids.Add(id.Value);
                }
            }

            if (ids.Count > 0)
            {
                req.ListaIdsObraColaborador = ids;
            }
        }

        if (body.TryGetProperty("listaEquipamentos", out var eqs) && eqs.ValueKind == JsonValueKind.Array)
        {
            var ids = new List<int>();
            foreach (var e in eqs.EnumerateArray())
            {
                var id = ReadIntProp(e, "idObraEquipamento") ?? ReadIntProp(e, "IdObraEquipamento");
                if (id is > 0)
                {
                    ids.Add(id.Value);
                }
            }

            if (ids.Count > 0)
            {
                req.ListaIdsObraEquipamento = ids;
            }
        }

        return req;
    }

    private static string NormalizeDateForSave(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return "";
        }

        if (TryParseFlexibleDate(value, out var dt))
        {
            return dt.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }

        return value.Trim();
    }

    private static string ToBrDate(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return "";
        }

        if (TryParseFlexibleDate(value, out var dt))
        {
            return dt.ToString("dd/MM/yyyy", PtBr);
        }

        return value.Trim();
    }

    private static bool TryParseFlexibleDate(string value, out DateTime date)
    {
        date = default;
        var v = value.Trim();

        if (DateTime.TryParseExact(
                v,
                new[] { "dd/MM/yyyy", "dd/MM/yyyy HH:mm:ss", "yyyy-MM-dd", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-ddTHH:mm:ss.fffZ", "yyyy-MM-ddTHH:mm:ssZ" },
                CultureInfo.InvariantCulture,
                DateTimeStyles.AllowWhiteSpaces | DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal,
                out date))
        {
            date = date.Date;
            return true;
        }

        if (DateTime.TryParse(v, PtBr, DateTimeStyles.None, out date)
            || DateTime.TryParse(v, CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out date))
        {
            date = date.Date;
            return true;
        }

        return false;
    }

    private static string FormatTimeSpan(TimeSpan? value) =>
        value.HasValue ? value.Value.ToString(@"hh\:mm\:ss") : "";

    private static string NormalizeTime(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return "";
        }

        var t = value.Trim();
        if (t.Length == 5)
        {
            return t + ":00";
        }

        return t;
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

    private static bool TryReadInt(JsonElement body, out int value)
    {
        value = 0;
        if (body.ValueKind == JsonValueKind.Number && body.TryGetInt32(out value))
        {
            return true;
        }

        if (body.ValueKind == JsonValueKind.String && int.TryParse(body.GetString(), out value))
        {
            return true;
        }

        if (body.ValueKind == JsonValueKind.Object)
        {
            var n = ReadIntProp(body, "id") ?? ReadIntProp(body, "idTarefa");
            if (n is > 0)
            {
                value = n.Value;
                return true;
            }
        }

        return false;
    }

    private static int? ReadIntProp(JsonElement el, string name)
    {
        if (!TryGetProp(el, name, out var p))
        {
            return null;
        }

        if (p.ValueKind == JsonValueKind.Number && p.TryGetInt32(out var n))
        {
            return n;
        }

        if (p.ValueKind == JsonValueKind.String && int.TryParse(p.GetString(), out n))
        {
            return n;
        }

        return null;
    }

    private static float? ReadFloatProp(JsonElement el, string name)
    {
        if (!TryGetProp(el, name, out var p))
        {
            return null;
        }

        if (p.ValueKind == JsonValueKind.Number && p.TryGetSingle(out var f))
        {
            return f;
        }

        if (p.ValueKind == JsonValueKind.String
            && float.TryParse(p.GetString(), NumberStyles.Any, CultureInfo.InvariantCulture, out f))
        {
            return f;
        }

        return null;
    }

    private static decimal? ReadDecimalProp(JsonElement el, string name)
    {
        if (!TryGetProp(el, name, out var p))
        {
            return null;
        }

        if (p.ValueKind == JsonValueKind.Number && p.TryGetDecimal(out var d))
        {
            return d;
        }

        if (p.ValueKind == JsonValueKind.String
            && decimal.TryParse(p.GetString(), NumberStyles.Any, CultureInfo.InvariantCulture, out d))
        {
            return d;
        }

        return null;
    }

    private static bool? ReadBoolProp(JsonElement el, string name)
    {
        if (!TryGetProp(el, name, out var p))
        {
            return null;
        }

        return p.ValueKind switch
        {
            JsonValueKind.True => true,
            JsonValueKind.False => false,
            JsonValueKind.String when bool.TryParse(p.GetString(), out var b) => b,
            _ => null,
        };
    }

    private static string? ReadStringProp(JsonElement el, string name)
    {
        if (!TryGetProp(el, name, out var p))
        {
            return null;
        }

        return p.ValueKind switch
        {
            JsonValueKind.String => p.GetString(),
            JsonValueKind.Number => p.ToString(),
            JsonValueKind.True => "true",
            JsonValueKind.False => "false",
            _ => null,
        };
    }

    private static bool TryGetProp(JsonElement el, string name, out JsonElement prop)
    {
        if (el.ValueKind == JsonValueKind.Object && el.TryGetProperty(name, out prop))
        {
            return true;
        }

        // PascalCase fallback
        if (el.ValueKind == JsonValueKind.Object
            && name.Length > 0
            && el.TryGetProperty(char.ToUpperInvariant(name[0]) + name[1..], out prop))
        {
            return true;
        }

        prop = default;
        return false;
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
