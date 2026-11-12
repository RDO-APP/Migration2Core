using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/empresas")]
public class BffEmpresasController : ControllerBase
{
    private readonly EmpresaIndexService _empresas;

    public BffEmpresasController(EmpresaIndexService empresas)
    {
        _empresas = empresas;
    }

    [HttpGet("index/bootstrap")]
    public async Task<IActionResult> IndexBootstrap(CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _empresas.BootstrapAsync(HttpContext, obraNome, cancellationToken));
    }

    [HttpGet("index/municipios")]
    public async Task<IActionResult> IndexMunicipios([FromQuery] int idUf, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        return Ok(await _empresas.MunicipiosByUfAsync(idUf, cancellationToken));
    }

    [HttpGet("lista")]
    public async Task<IActionResult> Lista(
        [FromQuery] string? razaoSocial,
        [FromQuery] string? cnpj,
        [FromQuery] int idUf = 0,
        [FromQuery] int idMunicipio = 0,
        [FromQuery] int idRamo = 0,
        [FromQuery] int idSetor = 0,
        CancellationToken cancellationToken = default)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var filter = new EmpresaIndexFilterDto
        {
            RazaoSocial = razaoSocial,
            Cnpj = cnpj,
            IdUf = idUf,
            IdMunicipio = idMunicipio,
            IdRamo = idRamo,
            IdSetor = idSetor,
        };
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _empresas.ListAsync(colaboradorId, obraId, filter, obraNome, cancellationToken));
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
