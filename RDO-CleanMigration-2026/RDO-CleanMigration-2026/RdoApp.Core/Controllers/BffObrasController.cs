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

    public BffObrasController(ObrasQueryService obras, LoginObraService loginObra)
    {
        _obras = obras;
        _loginObra = loginObra;
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

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
