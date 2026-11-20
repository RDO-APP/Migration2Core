using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Controllers;

/// <summary>M6 Fase 1.2 — smallest JWT slice for Apontador (login + me).</summary>
[ApiController]
[Route("api/mobile/auth")]
[EnableCors("MobileJwt")]
public sealed class BffMobileAuthController : ControllerBase
{
    private readonly RdoDbContext _context;
    private readonly MobileJwtTokenService _tokenService;
    private readonly HistoricoLoginWriter _historicoLogin;
    private readonly ILogger<BffMobileAuthController> _logger;

    public BffMobileAuthController(
        RdoDbContext context,
        MobileJwtTokenService tokenService,
        HistoricoLoginWriter historicoLogin,
        ILogger<BffMobileAuthController> logger)
    {
        _context = context;
        _tokenService = tokenService;
        _historicoLogin = historicoLogin;
        _logger = logger;
    }

    /// <summary>POST /api/mobile/auth/login — CPF + senha (TripleDES, same as AccountController).</summary>
    [HttpPost("login")]
    [AllowAnonymous]
    public async Task<IActionResult> Login(
        [FromBody] MobileLoginRequestDto body,
        CancellationToken cancellationToken)
    {
        if (body is null || string.IsNullOrWhiteSpace(body.Cpf) || string.IsNullOrWhiteSpace(body.Senha))
        {
            return Unauthorized(new { message = "Usuário ou senha não existem." });
        }

        var cpf = body.Cpf.Replace(".", "").Replace("-", "").Trim();
        var senhaEncriptada = Seguranca.EncryptTripleDES(body.Senha);

        var colaborador = await _context.Colaboradores
            .AsNoTracking()
            .FirstOrDefaultAsync(
                c => c.ColNrCpf == cpf && c.ColDsSenha == senhaEncriptada,
                cancellationToken);

        if (colaborador is null)
        {
            _logger.LogWarning(
                "Mobile JWT login failed for CPF {CpfPrefix}***",
                cpf.Length > 3 ? cpf[..3] : "***");
            return Unauthorized(new { message = "Usuário ou senha não existem." });
        }

        var (accessToken, expiresIn) = _tokenService.CreateToken(colaborador);

        // Paridade web/prod: gravar historico_login (obra ainda null — LoginObra preenche depois).
        await _historicoLogin.RecordAsync(
            colaborador.ColIdColaborador,
            colaborador.ColNrCpf ?? "",
            colaborador.ColNmColaborador ?? "",
            colaborador.ColDsEmail ?? "",
            obraId: null,
            obraNome: null,
            cancellationToken);

        _logger.LogInformation(
            "Mobile JWT issued for {Nome} (ID: {ColaboradorId})",
            colaborador.ColNmColaborador,
            colaborador.ColIdColaborador);

        return Ok(new MobileLoginResponseDto
        {
            AccessToken = accessToken,
            ExpiresIn = expiresIn,
            TokenType = "Bearer",
            Colaborador = new MobileColaboradorDto
            {
                Id = colaborador.ColIdColaborador,
                Nome = colaborador.ColNmColaborador,
                Cpf = colaborador.ColNrCpf,
                Email = colaborador.ColDsEmail,
            },
        });
    }

    /// <summary>GET /api/mobile/auth/me — claims from Bearer JWT.</summary>
    [HttpGet("me")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public IActionResult Me()
    {
        return Ok(new MobileMeResponseDto
        {
            Id = User.FindFirstValue(ClaimTypes.NameIdentifier),
            Nome = User.FindFirstValue(ClaimTypes.Name),
            Cpf = User.FindFirstValue("cpf"),
            Email = User.FindFirstValue("email"),
            IsAdmin = User.FindFirstValue("isAdmin"),
        });
    }
}
