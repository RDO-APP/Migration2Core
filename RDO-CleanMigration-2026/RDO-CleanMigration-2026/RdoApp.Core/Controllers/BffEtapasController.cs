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

    /// <summary>Cards P3 — não confundir com listagem do menu Etapas.</summary>
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

    [HttpGet("lista")]
    public async Task<IActionResult> Lista([FromQuery] string? titulo, CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _etapa.ListAsync(obraId, obraNome, titulo, cancellationToken));
    }

    [HttpGet("cadastro")]
    public async Task<IActionResult> CadastroBlank([FromQuery] int? id, CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        if (id is > 0)
        {
            var edit = await _etapa.GetForEditAsync(obraId, id.Value, cancellationToken);
            if (edit == null)
            {
                return NotFound(new { message = "Etapa não encontrada." });
            }

            return Ok(edit);
        }

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
        if (body.Id is > 0)
        {
            var updated = await _etapa.UpdateAsync(obraId, body.Id.Value, body, cancellationToken);
            return updated.Ok ? Ok(updated) : BadRequest(updated);
        }

        var result = await _etapa.CreateAsync(obraId, body, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(
        int id,
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
        var result = await _etapa.UpdateAsync(obraId, id, body, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _etapa.DeleteAsync(obraId, id, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }
}
