using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/etapas")]
public class BffEtapasController : ControllerBase
{
    private readonly CardsQueryService _cards;

    public BffEtapasController(CardsQueryService cards)
    {
        _cards = cards;
    }

    /// <summary>
    /// M2 BFF — homolog RDS only (DefaultConnection / homol_rdoapp). Session cookie required.
    /// </summary>
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

        return Ok(payload);
    }
}
