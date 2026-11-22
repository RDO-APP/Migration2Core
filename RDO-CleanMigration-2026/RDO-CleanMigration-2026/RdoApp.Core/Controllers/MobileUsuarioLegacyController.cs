using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Services;

namespace RdoApp.Core.Controllers;

/// <summary>
/// M6 — paridade legado <c>POST /api/Usuario/LoginObra</c> (JWT Bearer).
/// Sem cookie/session — historico + LoginViewModel; token pode ganhar claims obra*.
/// </summary>
[ApiController]
[Route("api/Usuario")]
[EnableCors("MobileJwt")]
[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
public sealed class MobileUsuarioLegacyController : ControllerBase
{
    private readonly RdoDbContext _context;
    private readonly LoginObraService _loginObra;
    private readonly MobileJwtTokenService _tokenService;
    private readonly ILogger<MobileUsuarioLegacyController> _logger;

    public MobileUsuarioLegacyController(
        RdoDbContext context,
        LoginObraService loginObra,
        MobileJwtTokenService tokenService,
        ILogger<MobileUsuarioLegacyController> logger)
    {
        _context = context;
        _loginObra = loginObra;
        _tokenService = tokenService;
        _logger = logger;
    }

    public sealed class LoginObraBody
    {
        public int IdObra { get; set; }
        public int IdUsuario { get; set; }
    }

    [HttpPost("LoginObra")]
    public async Task<IActionResult> LoginObra(
        [FromBody] LoginObraBody? body,
        CancellationToken cancellationToken)
    {
        if (!TryColaboradorId(out var colaboradorId))
        {
            return Unauthorized(new { message = "Unauthorized" });
        }

        if (body is null || body.IdObra <= 0)
        {
            return BadRequest(new { message = "Obra inválida." });
        }

        if (body.IdUsuario > 0 && body.IdUsuario != colaboradorId)
        {
            _logger.LogWarning(
                "LoginObra: body idUsuario {BodyId} ≠ JWT {JwtId} — usando JWT",
                body.IdUsuario,
                colaboradorId);
        }

        var result = await _loginObra.SelectObraAsync(
            colaboradorId,
            body.IdObra,
            existingLogin: null,
            cancellationToken);

        if (!result.Success || result.LoginData is null)
        {
            return BadRequest(new { message = result.ErrorMessage ?? "Não foi possível acessar esta obra." });
        }

        // Reemite JWT com obra (app pode ignorar até passar a gravar o token).
        var colaborador = await _context.Colaboradores.AsNoTracking()
            .FirstOrDefaultAsync(c => c.ColIdColaborador == colaboradorId, cancellationToken);
        if (colaborador is not null)
        {
            var grupoId = result.LoginData.ObraColaborador?.IdGrupo is long g ? (int)g : (int?)null;
            var (accessToken, expiresIn) = _tokenService.CreateToken(
                colaborador,
                result.ObraId,
                result.ObraColaboradorId,
                grupoId);

            return Ok(new
            {
                result.LoginData.Usuario,
                result.LoginData.Routes,
                result.LoginData.Menu,
                result.LoginData.ObraColaborador,
                result.LoginData.Obra,
                accessToken,
                expiresIn,
                tokenType = "Bearer",
            });
        }

        return Ok(result.LoginData);
    }

    private bool TryColaboradorId(out int colaboradorId)
    {
        colaboradorId = 0;
        var claim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return !string.IsNullOrEmpty(claim) && int.TryParse(claim, out colaboradorId);
    }
}
