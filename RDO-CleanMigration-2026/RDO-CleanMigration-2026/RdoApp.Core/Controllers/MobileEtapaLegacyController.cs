using System.Globalization;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

/// <summary>
/// M6 — paridade legado <c>GET /api/etapa/Get</c> e <c>ObterEtapaTarefa</c> (JWT Bearer).
/// Mesma fonte CardsQueryService (homol_rdoapp); shape camelCase p/ Apontador.
/// </summary>
[ApiController]
[Route("api/etapa")]
[EnableCors("MobileJwt")]
[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
public sealed class MobileEtapaLegacyController : ControllerBase
{
    private readonly RdoDbContext _context;
    private readonly CardsQueryService _cards;
    private readonly ILogger<MobileEtapaLegacyController> _logger;

    public MobileEtapaLegacyController(
        RdoDbContext context,
        CardsQueryService cards,
        ILogger<MobileEtapaLegacyController> logger)
    {
        _context = context;
        _cards = cards;
        _logger = logger;
    }

    [HttpGet("Get")]
    public async Task<IActionResult> Get(
        [FromQuery] int idObra,
        CancellationToken cancellationToken)
    {
        return await LoadEtapasAsync(idObra, cancellationToken);
    }

    /// <summary>Filtros legado ignorados no esqueleto — retorna cards atuais (statusTarefa=0 no app).</summary>
    [HttpGet("ObterEtapaTarefa")]
    public async Task<IActionResult> ObterEtapaTarefa(
        [FromQuery] int idObra,
        [FromQuery] string? descricao,
        [FromQuery] int statusTarefa,
        [FromQuery] string? dataInicial,
        [FromQuery] string? dataInicialExecutada,
        [FromQuery] string? dataFinalExecutada,
        CancellationToken cancellationToken)
    {
        _ = (descricao, statusTarefa, dataInicial, dataInicialExecutada, dataFinalExecutada);
        return await LoadEtapasAsync(idObra, cancellationToken);
    }

    private async Task<IActionResult> LoadEtapasAsync(int idObra, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        if (idObra <= 0)
        {
            return BadRequest(new { message = "idObra inválido." });
        }

        var temAcesso = await _context.ObraColaboradores.AsNoTracking()
            .AnyAsync(
                oc => oc.OcoIdColaborador == colaboradorId && oc.OcoIdObra == idObra,
                cancellationToken);
        if (!temAcesso)
        {
            _logger.LogWarning(
                "Etapa JWT: colaborador {ColId} sem acesso à obra {ObraId}",
                colaboradorId,
                idObra);
            return Unauthorized(new { message = "Sem permissão para esta obra." });
        }

        var obraNome = await _context.Obras.AsNoTracking()
            .Where(o => o.ObrIdObra == idObra)
            .Select(o => o.ObrDsObra ?? "")
            .FirstOrDefaultAsync(cancellationToken);

        var payload = await _cards.GetCardsForObraAsync(idObra, obraNome, cancellationToken);
        if (payload is null)
        {
            return NotFound(new { message = "Obra não encontrada." });
        }

        // Shape legado: array de etapas (não envelope CardsContext).
        var lista = payload.Etapas.Select(MapEtapaMobile).ToList();
        return Ok(lista);
    }

    private static object MapEtapaMobile(EtapaComTarefasDto e) => new
    {
        id = e.Id,
        titulo = e.Titulo,
        ordem = e.Ordem,
        idObra = e.IdObra,
        tituloObra = e.TituloObra ?? "",
        dataInicial = "0001-01-01T00:00:00",
        dataFinalPlanejada = "0001-01-01T00:00:00",
        dataInicialExecutada = "0001-01-01T00:00:00",
        dataFinalExecutada = "0001-01-01T00:00:00",
        idStatus = 0,
        tarefas = e.Tarefas.Select(MapTarefaMobile).ToList(),
    };

    private static object MapTarefaMobile(TarefaCardDto t) => new
    {
        id = t.Id,
        descricao = t.Descricao,
        status = t.Status,
        nomeStatus = t.NomeStatus,
        idEtapa = t.IdEtapa,
        idRdo = 0,
        idUnidade = 0,
        ordemStatus = t.Status,
        dataInicio = t.DataInicio,
        dataPrevisaoFim = t.DataPrevisaoFim,
        // ISO para o app (formatDate usa new Date(...); dd/MM/yyyy → NaN).
        primeiraExecucao = ToIsoDate(t.PrimeiraExecucao),
        ultimaExecucao = ToIsoDate(t.UltimaExecucao),
        quantidadeEquipamentos = t.QuantidadeEquipamentos,
        quantidadeColaboradores = t.QuantidadeColaboradores,
        percentualConcluido = t.PercentualConcluido,
        percentualExtrapolado = t.PercentualExtrapolado,
        classeStatusCss = t.ClasseStatusCss,
        existeExecucao = t.ExisteExecucao,
        marcado = false,
        rdoAssinado = false,
        listaStatusPermitidos = t.ListaStatusPermitidos.Select(s => new
        {
            id = s.Id,
            nome = s.Nome,
            cssClass = s.CssClass,
        }).ToList(),
        listaImagem = Array.Empty<object>(),
    };

    /// <summary>Aceita vazio, ISO ou dd/MM/yyyy (CardsQueryService) → ISO p/ RN formatDate.</summary>
    private static string ToIsoDate(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return "0001-01-01T00:00:00";
        }

        if (DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.RoundtripKind, out var iso))
        {
            return iso.Date.ToString("yyyy-MM-ddT00:00:00");
        }

        if (DateTime.TryParseExact(
                value.Trim(),
                "dd/MM/yyyy",
                CultureInfo.GetCultureInfo("pt-BR"),
                DateTimeStyles.None,
                out var br))
        {
            return br.Date.ToString("yyyy-MM-ddT00:00:00");
        }

        return "0001-01-01T00:00:00";
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
