using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/equipamentos")]
public class BffEquipamentosController : ControllerBase
{
    private readonly EquipamentoIndexService _equipamentos;
    private readonly EquipamentoCadastroService _cadastro;

    public BffEquipamentosController(EquipamentoIndexService equipamentos, EquipamentoCadastroService cadastro)
    {
        _equipamentos = equipamentos;
        _cadastro = cadastro;
    }

    [HttpGet("index/bootstrap")]
    public IActionResult IndexBootstrap()
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(_equipamentos.Bootstrap(HttpContext, obraNome));
    }

    [HttpGet("lista")]
    public async Task<IActionResult> Lista(
        [FromQuery] string? tipoEquipamento,
        [FromQuery] string? descricao,
        [FromQuery] string? marca,
        [FromQuery] string? modelo,
        [FromQuery] string? tipoAquisicao,
        [FromQuery] string? fabricanteFornecedor,
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
        var filter = new EquipamentoIndexFilterDto
        {
            TipoEquipamento = tipoEquipamento,
            Descricao = descricao,
            Marca = marca,
            Modelo = modelo,
            TipoAquisicao = tipoAquisicao,
            FabricanteFornecedor = fabricanteFornecedor,
        };
        var obraNome = ObraSessionHelper.GetObraNome(HttpContext);
        return Ok(await _equipamentos.ListAsync(obraId, filter, obraNome, cancellationToken));
    }

    [HttpDelete("{idEquipamento:int}")]
    public async Task<IActionResult> Delete(int idEquipamento, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new EquipamentoIndexActionResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!EquipamentoIndexService.CanEquipamentoIndex(HttpContext, "deletar"))
        {
            return Forbid();
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new EquipamentoIndexActionResultDto { Ok = false, ErrorMessage = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _equipamentos.DeleteAsync(idEquipamento, obraId, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
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
            return BadRequest(new { message = error ?? "Falha ao carregar equipamento." });
        }

        return Ok(form);
    }

    [HttpPut("cadastro")]
    public async Task<IActionResult> SalvarCadastro(
        [FromBody] EquipamentoCadastroSaveRequestDto body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out _))
        {
            return Unauthorized(new EquipamentoCadastroSaveResultDto { Ok = false, ErrorMessage = "Sessão inválida." });
        }

        if (!ObraSessionHelper.HasObraSelected(HttpContext))
        {
            return Unauthorized(new EquipamentoCadastroSaveResultDto { Ok = false, ErrorMessage = "Nenhuma obra selecionada." });
        }

        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _cadastro.SaveAsync(HttpContext, obraId, body, cancellationToken);
        return result.Ok ? Ok(result) : BadRequest(result);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
