using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

/// <summary>PDF isolado da listagem — ReportViewer não pode derrubar GET /api/bff/rdos.</summary>
[Authorize]
[ApiController]
[IgnoreAntiforgeryToken]
[Route("api/bff/rdos")]
public class BffRdoPdfController : ControllerBase
{
    private readonly IServiceProvider _services;

    public BffRdoPdfController(IServiceProvider services)
    {
        _services = services;
    }

    [HttpPost("{idRdo:int}/pdf")]
    public async Task<IActionResult> GeneratePdf(
        int idRdo,
        [FromBody] RdoPdfRequestDto? body,
        CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var gerarFotos = body?.GerarRelatorioFotografico ?? false;

        try
        {
            var pdf = _services.GetRequiredService<RdoPdfService>();
            var bytes = await pdf.GenerateAsync(obraId, idRdo, gerarFotos, cancellationToken);
            return File(bytes, "application/pdf", $"RDO_{idRdo}.pdf");
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = $"[L9-QuestPDF] {ex.Message}" });
        }
        catch (FileNotFoundException ex)
        {
            return StatusCode(503, new { message = ex.Message });
        }
        catch (Exception ex)
        {
            var leaf = ex;
            while (leaf.InnerException != null)
            {
                leaf = leaf.InnerException;
            }

            return StatusCode(500, new { message = $"Erro ao gerar PDF [L9-QuestPDF]. {leaf.GetType().Name}: {leaf.Message}" });
        }
    }
}
