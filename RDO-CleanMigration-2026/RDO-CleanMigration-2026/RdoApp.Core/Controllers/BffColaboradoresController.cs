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
    private readonly ColaboradorCadastroService _cadastro;

    public BffColaboradoresController(ColaboradorIndexService colaboradores, ColaboradorCadastroService cadastro)
    {
        _colaboradores = colaboradores;
        _cadastro = cadastro;
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

    [HttpGet("cadastro")]
    public async Task<IActionResult> Cadastro([FromQuery] int id = 0, CancellationToken cancellationToken = default)
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
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        var (form, error) = await _cadastro.GetFormAsync(HttpContext, id, obraId, obraNome, cancellationToken);
        if (form == null)
        {
            return BadRequest(new { message = error ?? "Falha ao carregar colaborador." });
        }

        return Ok(form);
    }

    [HttpPut("cadastro")]
    public async Task<IActionResult> SalvarCadastro(
        [FromBody] ColaboradorCadastroSaveRequestDto body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new ColaboradorCadastroSaveResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new ColaboradorCadastroSaveResultDto { Ok = false, ErrorMessage = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _cadastro.SaveAsync(HttpContext, obraId, body, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
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
