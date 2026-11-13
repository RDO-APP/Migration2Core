using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/paralizacoes")]
public class BffParalizacoesController : ControllerBase
{
    private readonly ParalizacaoService _service;

    public BffParalizacoesController(ParalizacaoService service)
    {
        _service = service;
    }

    [HttpGet("index/bootstrap")]
    public async Task<IActionResult> IndexBootstrap(CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _service.BootstrapAsync(HttpContext, obraNome, cancellationToken));
    }

    [HttpGet("lista")]
    public async Task<IActionResult> Lista(
        [FromQuery] string? descricao,
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

        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        var filter = new ParalizacaoIndexFilterDto { Descricao = descricao };
        return Ok(await _service.ListAsync(HttpContext, filter, obraNome, cancellationToken));
    }

    [HttpGet("cadastro")]
    public async Task<IActionResult> Cadastro([FromQuery] string? codigo = null, CancellationToken cancellationToken = default)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        }

        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        var (form, error) = await _service.GetFormAsync(HttpContext, codigo, obraNome, cancellationToken);
        if (form == null)
        {
            return BadRequest(new { message = error ?? "Falha ao carregar código de paralização." });
        }

        return Ok(form);
    }

    [HttpPut("cadastro")]
    public async Task<IActionResult> SalvarCadastro(
        [FromBody] ParalizacaoCadastroSaveRequestDto body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new ParalizacaoCadastroSaveResultDto { Ok = false, ErrorMessage = "Nenhuma obra selecionada." });
        }

        var result = await _service.SaveAsync(HttpContext, body, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    [HttpDelete("{codigo}")]
    public async Task<IActionResult> Delete(string codigo, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new ParalizacaoIndexActionResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ParalizacaoService.Can(HttpContext, "deletar"))
        {
            return Forbid();
        }

        var result = await _service.DeleteAsync(HttpContext, codigo, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
