using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/colaboradores")]
public class BffColaboradoresController : ControllerBase
{
    private readonly ColaboradorIndexService _colaboradores;

    public BffColaboradoresController(ColaboradorIndexService colaboradores)
    {
        _colaboradores = colaboradores;
    }

    [HttpGet("index/bootstrap")]
    public async Task<IActionResult> IndexBootstrap(CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _colaboradores.BootstrapAsync(HttpContext, obraNome, cancellationToken));
    }

    [HttpGet("index/municipios")]
    public async Task<IActionResult> IndexMunicipios([FromQuery] int idUf, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        return Ok(await _colaboradores.MunicipiosByUfAsync(idUf, cancellationToken));
    }

    [HttpGet("lista")]
    public async Task<IActionResult> Lista(
        [FromQuery] string? nome,
        [FromQuery] string? cpf,
        [FromQuery] string? sexo,
        [FromQuery] string? email,
        [FromQuery] string? crea,
        [FromQuery] int idUf = 0,
        [FromQuery] int idMunicipio = 0,
        [FromQuery] int idCargo = 0,
        [FromQuery] int idGrupo = 0,
        [FromQuery] string? dataContratacao = null,
        CancellationToken cancellationToken = default)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var filter = new ColaboradorIndexFilterDto
        {
            Nome = nome,
            Cpf = cpf,
            Sexo = sexo,
            Email = email,
            Crea = crea,
            IdUf = idUf,
            IdMunicipio = idMunicipio,
            IdCargo = idCargo,
            IdGrupo = idGrupo,
            DataContratacao = dataContratacao,
        };
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        try
        {
            return Ok(await _colaboradores.ListAsync(HttpContext, obraId, filter, obraNome, cancellationToken));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{idColaborador:int}")]
    public async Task<IActionResult> Delete(int idColaborador, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new ColaboradorIndexActionResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ColaboradorIndexService.CanColaboradorIndex(HttpContext, "deletar"))
        {
            return Forbid();
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new ColaboradorIndexActionResultDto { Ok = false, ErrorMessage = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _colaboradores.DeleteAsync(HttpContext, idColaborador, obraId, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
