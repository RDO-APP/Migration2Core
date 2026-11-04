using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/etapas")]
public class BffEtapasController : ControllerBase
{
    private readonly CardsQueryService _cards;
    private readonly EtapaCadastroService _etapa;

    public BffEtapasController(CardsQueryService cards, EtapaCadastroService etapa)
    {
        _cards = cards;
        _etapa = etapa;
    }

    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);

        var payload = await _cards.GetCardsForObraAsync(obraId, obraNome, cancellationToken);
        if (payload == null)
        {
            return NotFound(new { message = "Obra não encontrada." });
        }

        payload.UsuarioNome = User.Identity?.Name ?? string.Empty;
        return Ok(payload);
    }

    [HttpGet("cadastro")]
    public async Task<IActionResult> CadastroBlank(CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        return Ok(await _etapa.GetBlankAsync(obraId, cancellationToken));
    }

    [HttpPost]
    public async Task<IActionResult> Create(
        [FromBody] EtapaCadastroSaveRequestDto? body,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        if (body == null)
        {
            return BadRequest(new EtapaCadastroSaveResultDto { Ok = false, ErrorMessage = "Corpo inválido." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _etapa.CreateAsync(obraId, body, cancellationToken);
        if (!result.Ok)
        {
            return BadRequest(result);
        }

        return Ok(result);
    }
}
