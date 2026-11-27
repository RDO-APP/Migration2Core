using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Services;
using RdoApp.Core.Utils;

namespace RdoApp.Core.Controllers;

/// <summary>
/// Paridade legado POST /api/login/LoginUser para o APK de producao (cenario A).
/// Mesma regra do login Web (CPF sem mascara + senha TripleDES), grava cookie e sessao
/// e devolve o mesmo JSON que o app espera (usuario, routes, menu).
/// Falha de credencial responde 200 com Message (o app le data.Message).
/// </summary>
[ApiController]
[Route("api/login")]
[EnableCors("MobileJwt")]
[AllowAnonymous]
public sealed class MobileLoginLegacyController : ControllerBase
{
    private readonly RdoDbContext _context;
    private readonly LoginLegacyService _loginLegacy;
    private readonly ILogger<MobileLoginLegacyController> _logger;

    public MobileLoginLegacyController(
        RdoDbContext context,
        LoginLegacyService loginLegacy,
        ILogger<MobileLoginLegacyController> logger)
    {
        _context = context;
        _loginLegacy = loginLegacy;
        _logger = logger;
    }

    public sealed class LoginUserBody
    {
        public string? Cpf { get; set; }
        public string? Senha { get; set; }
        public string? Email { get; set; }
        public bool ManterLogado { get; set; }
    }

    [HttpPost("LoginUser")]
    public async Task<IActionResult> LoginUser(
        [FromBody] LoginUserBody? body,
        CancellationToken cancellationToken)
    {
        if (body is null || string.IsNullOrWhiteSpace(body.Cpf) || string.IsNullOrEmpty(body.Senha))
        {
            return Ok(new { Message = "Usuario ou senha nao existem." });
        }

        var cpf = body.Cpf.Replace(".", "").Replace("-", "");
        var senhaEncriptada = Seguranca.EncryptTripleDES(body.Senha);

        var colaborador = await _context.Colaboradores
            .FirstOrDefaultAsync(c => c.ColNrCpf == cpf && c.ColDsSenha == senhaEncriptada, cancellationToken);

        if (colaborador is null)
        {
            _logger.LogWarning("LoginUser (mobile): credencial invalida para CPF {Cpf}", cpf.Length > 3 ? cpf[..3] + "***" : "***");
            return Ok(new { Message = "Usuario ou senha nao existem." });
        }

        var loginViewModel = _loginLegacy.BuildLoginViewModel(colaborador);

        await _loginLegacy.InserirHistoricoLogin(new HistoricoLogin
        {
            col_id_colaborador = colaborador.ColIdColaborador,
            col_ds_email = colaborador.ColDsEmail,
            col_nm_colaborador = colaborador.ColNmColaborador,
            col_nr_cpf = colaborador.ColNrCpf,
            data_login = DateTime.Now
        });

        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, colaborador.ColIdColaborador.ToString()),
            new Claim(ClaimTypes.Name, colaborador.ColNmColaborador),
            new Claim("cpf", colaborador.ColNrCpf),
            new Claim("email", colaborador.ColDsEmail ?? ""),
            new Claim("isAdmin", (colaborador.ColStAdmin == true).ToString())
        };

        var principal = new ClaimsPrincipal(new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme));

        var authProperties = new AuthenticationProperties
        {
            IsPersistent = body.ManterLogado,
            ExpiresUtc = body.ManterLogado
                ? DateTimeOffset.UtcNow.AddDays(30)
                : DateTimeOffset.UtcNow.AddHours(8)
        };

        await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal, authProperties);

        HttpContext.Session.SetInt32("ColaboradorId", colaborador.ColIdColaborador);
        HttpContext.Session.SetString(SessionKeys.LoginData, LoginSessionJson.Serialize(loginViewModel));

        _logger.LogInformation("LoginUser (mobile): colaborador {ColaboradorId} autenticado por cookie", colaborador.ColIdColaborador);

        return Ok(loginViewModel);
    }
}
