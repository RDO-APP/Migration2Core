using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Models.Dtos;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

[Authorize]
[ApiController]
[Route("api/bff/obras")]
public class BffObrasController : ControllerBase
{
    private readonly ObrasQueryService _obras;
    private readonly LoginObraService _loginObra;
    private readonly ObraCadastroService _cadastro;

    public BffObrasController(ObrasQueryService obras, LoginObraService loginObra, ObraCadastroService cadastro)
    {
        _obras = obras;
        _loginObra = loginObra;
        _cadastro = cadastro;
    }

    /// <summary>M4.4 — obras do colaborador logado (cookie session).</summary>
    [HttpGet]
    public async Task<IActionResult> Get(CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Sessão inválida." });
        }

        var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
        if (string.IsNullOrEmpty(loginDataJson))
        {
            return Unauthorized(new { message = "LoginData ausente — faça login novamente." });
        }

        var ctx = await _obras.GetEscolherAsync(colaboradorId, cancellationToken);
        if (ctx == null)
        {
            return NotFound(new { message = "Colaborador não encontrado." });
        }

        ctx.UsuarioNome = User.Identity?.Name ?? "";
        return Ok(ctx);
    }

    /// <summary>M4.4 — seleciona obra (mesma lógica POST /Obra/Selecionar).</summary>
    [HttpPost("selecionar")]
    public async Task<IActionResult> Selecionar([FromBody] SelecionarObraRequest body, CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new SelecionarObraResponse { Success = false, ErrorMessage = "Sessão inválida." });
        }

        var idObra = body.IdObra;
        if (idObra <= 0)
        {
            return BadRequest(new SelecionarObraResponse { Success = false, ErrorMessage = "Obra inválida." });
        }

        var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
        var existingLogin = LoginSessionJson.TryDeserialize(loginDataJson);

        var result = await _loginObra.SelectObraAsync(colaboradorId, idObra, existingLogin, cancellationToken);
        if (!result.Success || result.LoginData == null)
        {
            return BadRequest(new SelecionarObraResponse
            {
                Success = false,
                ErrorMessage = result.ErrorMessage ?? "Não foi possível selecionar a obra.",
            });
        }

        HttpContext.Session.SetInt32(SessionKeys.ObraId, result.ObraId);
        HttpContext.Session.SetString(SessionKeys.ObraNome, result.ObraNome ?? string.Empty);
        HttpContext.Session.SetString(SessionKeys.ObraCidadeEstado, result.ObraCidadeEstado ?? string.Empty);
        HttpContext.Session.SetInt32(SessionKeys.ObraColaboradorId, result.ObraColaboradorId);

        if (LoginSessionJson.TrySerialize(result.LoginData, out var loginJson))
        {
            HttpContext.Session.SetString(SessionKeys.LoginData, loginJson);
        }

        return Ok(new SelecionarObraResponse
        {
            Success = true,
            RedirectUrl = Url.Action("Cards", "Tarefa") ?? "/Tarefa/Cards",
        });
    }



    [HttpGet("cadastro")]
    public async Task<IActionResult> GetCadastro(CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var dto = await _cadastro.GetAsync(obraId, cancellationToken);
        if (dto == null) return NotFound(new { message = "Obra nao encontrada." });
        return Ok(dto);
    }

    [HttpPut("cadastro")]
    public async Task<IActionResult> PutCadastro([FromBody] ObraCadastroSaveRequestDto? body, CancellationToken cancellationToken)
    {
        if (!ObraSessionHelper.HasObraSelected(HttpContext))
            return Unauthorized(new { message = "Nenhuma obra selecionada." });
        if (body == null) return BadRequest(new ObraCadastroSaveResultDto { Ok = false, ErrorMessage = "Corpo invalido." });
        var obraId = ObraSessionHelper.GetObraId(HttpContext)!.Value;
        var result = await _cadastro.SaveAsync(obraId, body, cancellationToken);
        if (!result.Ok) return BadRequest(result);
        if (!string.IsNullOrWhiteSpace(result.ObraNome))
            HttpContext.Session.SetString(SessionKeys.ObraNome, result.ObraNome);
        return Ok(result);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
