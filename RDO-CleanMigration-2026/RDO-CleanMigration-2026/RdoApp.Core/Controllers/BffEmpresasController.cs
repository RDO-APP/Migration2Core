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
    private readonly EmpresaCadastroService _cadastro;

    public BffEmpresasController(EmpresaIndexService empresas, EmpresaCadastroService cadastro)
    {
        _empresas = empresas;
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

    [HttpGet("cadastro")]
    public async Task<IActionResult> Cadastro([FromQuery] int id = 0, CancellationToken cancellationToken = default)
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
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        var (form, error) = await _cadastro.GetFormAsync(id, colaboradorId, obraId, obraNome, cancellationToken);
        if (form == null)
        {
            return BadRequest(new { message = error ?? "Falha ao carregar empresa." });
        }

        return Ok(form);
    }

    [HttpPut("cadastro")]
    public async Task<IActionResult> SalvarCadastro(
        [FromBody] EmpresaCadastroSaveRequestDto body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new EmpresaCadastroSaveResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new EmpresaCadastroSaveResultDto { Ok = false, ErrorMessage = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _cadastro.SaveAsync(colaboradorId, obraId, body, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
