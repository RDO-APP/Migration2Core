using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Infrastructure;
using RdoApp.Core.Utils;
using RdoApp.Core.Services;
using System.Security.Claims;

namespace RdoApp.Core.Controllers
{
    /// <summary>
    /// Account Controller - Clean Migration 2026
    /// EXACT COPY of legacy LoginController logic
    /// </summary>
    public class AccountController : Controller
    {
        private readonly RdoDbContext _context;
        private readonly RecuperarSenhaService _recuperarSenha;
        private readonly IWebHostEnvironment _env;
        private readonly ILogger<AccountController> _logger;
        private readonly LoginLegacyService _loginLegacy;

        public AccountController(
            RdoDbContext context,
            RecuperarSenhaService recuperarSenha,
            IWebHostEnvironment env,
            ILogger<AccountController> logger,
            LoginLegacyService loginLegacy)
        {
            _context = context;
            _recuperarSenha = recuperarSenha;
            _env = env;
            _logger = logger;
            _loginLegacy = loginLegacy;
        }

        /// <summary>
        /// GET: /Account/Login
        /// Displays the login page
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> Login(string? returnUrl = null)
        {
            // Homolog: não redirecionar GET /Login → Escolher (evita loop com cookie/sessão inconsistentes).
            // Limpa auth órfã; após POST login o fluxo segue para Escolher como no legado.
            if (User.Identity?.IsAuthenticated == true)
            {
                var loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
                if (string.IsNullOrEmpty(loginDataJson))
                {
                    // Cookie persistente (Lembrar-me) sobrevive ao fechar o browser; a sessão não.
                    // Rehidrata em vez de SignOut — senão o checkbox de 30 dias não tem efeito.
                    var restored = await TryRestoreLoginSessionFromCookieAsync();
                    if (!restored)
                    {
                        await HttpContext.SignOutAsync("Cookies");
                        HttpContext.Session.Clear();
                    }
                    else
                    {
                        loginDataJson = HttpContext.Session.GetString(SessionKeys.LoginData);
                    }
                }

                if (!string.IsNullOrEmpty(loginDataJson))
                {
                    // Já logado: nunca 302 de volta ao ReturnUrl (loop Login ↔ /Rdo/Index).
                    if (ObraSessionHelper.HasObraSelected(HttpContext))
                    {
                        return RedirectToAction("Cards", "Tarefa");
                    }

                    return RedirectToAction("Escolher", "Obra");
                }
            }

            ViewData["ReturnUrl"] = returnUrl;
            ViewData["Title"] = "Login - RDO App Equipamentos";
            
            _logger.LogInformation("Displaying login page");

            var spaIndex = Path.Combine(_env.WebRootPath, "app", "index.html");
            if (System.IO.File.Exists(spaIndex))
            {
                return PhysicalFile(spaIndex, "text/html");
            }

            return View(new LoginDto());
        }

        /// <summary>
        /// POST: /Account/Login
        /// EXACT COPY of legacy LoginUser logic
        /// </summary>
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginDto model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            ViewData["Title"] = "Login - RDO App Equipamentos";

            _logger.LogInformation("Processing login attempt for CPF: {Cpf}", 
                model.Cpf?.Length > 3 ? model.Cpf.Substring(0, 3) + "***" : "***");

            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Login form validation failed");
                return View(model);
            }

            try
            {
                // EXACT COPY: Remove CPF formatting (keep only numbers)
                string cpf = model.Cpf;
                cpf = !string.IsNullOrEmpty(cpf) ? cpf.Replace(".", "").Replace("-", "") : cpf;

                // EXACT COPY: Encrypt password with TripleDES
                string senhaEncriptada = Seguranca.EncryptTripleDES(model.Senha);

                _logger.LogInformation("Looking up colaborador with CPF: {Cpf}", cpf.Substring(0, 3) + "***");

                // EXACT COPY: Find colaborador by CPF AND encrypted password
                var colaborador = await _context.Colaboradores
                    .FirstOrDefaultAsync(c => c.ColNrCpf == cpf && c.ColDsSenha == senhaEncriptada);

                if (colaborador == null)
                {
                    _logger.LogWarning("Colaborador not found or invalid password for CPF: {Cpf}", cpf.Substring(0, 3) + "***");
                    ModelState.AddModelError(string.Empty, "Usuário ou senha não existem.");
                    return View(model);
                }

                var loginViewModel = BuildLoginViewModel(colaborador);

                // EXACT COPY: Log to historico_login
                await InserirHistoricoLogin(new HistoricoLogin
                {
                    col_id_colaborador = colaborador.ColIdColaborador,
                    col_ds_email = colaborador.ColDsEmail,
                    col_nm_colaborador = colaborador.ColNmColaborador,
                    col_nr_cpf = colaborador.ColNrCpf,
                    data_login = DateTime.Now
                });

                // Create authentication cookie
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.NameIdentifier, colaborador.ColIdColaborador.ToString()),
                    new Claim(ClaimTypes.Name, colaborador.ColNmColaborador),
                    new Claim("cpf", colaborador.ColNrCpf),
                    new Claim("email", colaborador.ColDsEmail ?? ""),
                    new Claim("isAdmin", (colaborador.ColStAdmin == true).ToString())
                };

                var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
                var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = model.LembrarMe,
                    ExpiresUtc = model.LembrarMe 
                        ? DateTimeOffset.UtcNow.AddDays(30) 
                        : DateTimeOffset.UtcNow.AddHours(8)
                };

                await HttpContext.SignInAsync("Cookies", claimsPrincipal, authProperties);

                // Store colaboradorId and login data in session
                HttpContext.Session.SetInt32("ColaboradorId", colaborador.ColIdColaborador);
                HttpContext.Session.SetString(SessionKeys.LoginData, LoginSessionJson.Serialize(loginViewModel));

                _logger.LogInformation("User {Nome} (ID: {ColaboradorId}) logged in successfully", 
                    colaborador.ColNmColaborador, colaborador.ColIdColaborador);

                // EXACT COPY: Redirect to Obra selection (not home)
                return RedirectToAction("Escolher", "Obra");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login for CPF {Cpf}", 
                    model.Cpf?.Length > 3 ? model.Cpf.Substring(0, 3) + "***" : "***");
                
                ModelState.AddModelError(string.Empty, "Erro interno do sistema. Tente novamente.");
                return View(model);
            }
        }

        /// <summary>
        /// POST: /Account/Logout
        /// Logs out the current user
        /// </summary>
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            var userName = User.Identity?.Name ?? "Unknown User";
            
            try
            {
                await HttpContext.SignOutAsync("Cookies");
                HttpContext.Session.Clear();
                _logger.LogInformation("User {UserName} logged out successfully", userName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during logout for user {UserName}", userName);
            }
            
            return RedirectToAction("Login");
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult EsqueciSenha()
        {
            return View(new EsqueciSenhaDto());
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EsqueciSenha(EsqueciSenhaDto model, CancellationToken cancellationToken)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var result = await _recuperarSenha.RecuperarAsync(model.Email, model.Cpf, cancellationToken);
            if (!result.Success)
            {
                ModelState.AddModelError(string.Empty, result.Message);
                return View(model);
            }

            ViewData["Sucesso"] = result.Message;
            return View(new EsqueciSenhaDto());
        }

        [HttpGet]
        [Authorize]
        public IActionResult ChangePassword()
        {
            return View("EmMigracao", new EmMigracaoViewModel
            {
                Titulo = "Trocar senha",
                Descricao = "Alteração de senha em migração — use recuperar senha no login ou contate o suporte.",
                VoltarUrl = "/Obra/Escolher",
            });
        }

        /// <summary>
        /// GET: /Account/AccessDenied
        /// Displays access denied page
        /// </summary>
        [HttpGet]
        [AllowAnonymous]
        public IActionResult AccessDenied()
        {
            _logger.LogWarning("Access denied for user {UserName}", User.Identity?.Name ?? "Anonymous");
            return View();
        }

        private LoginViewModel BuildLoginViewModel(Data.Entities.Colaborador colaborador) => _loginLegacy.BuildLoginViewModel(colaborador);

        private async Task<bool> TryRestoreLoginSessionFromCookieAsync()
        {
            var idStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!long.TryParse(idStr, out var colaboradorId))
            {
                return false;
            }

            var colaborador = await _context.Colaboradores
                .FirstOrDefaultAsync(c => c.ColIdColaborador == colaboradorId);
            if (colaborador == null)
            {
                return false;
            }

            HttpContext.Session.SetInt32("ColaboradorId", (int)colaborador.ColIdColaborador);
            HttpContext.Session.SetString(SessionKeys.LoginData, LoginSessionJson.Serialize(BuildLoginViewModel(colaborador)));
            _logger.LogInformation(
                "Restored login session from persistent cookie for colaborador {ColaboradorId}",
                colaborador.ColIdColaborador);
            return true;
        }

        private Task InserirHistoricoLogin(HistoricoLogin historico) => _loginLegacy.InserirHistoricoLogin(historico);
    }

    /// <summary>
    /// EXACT COPY from legacy HistoricoLogin
    /// </summary>
    public class HistoricoLogin
    {
        public long col_id_colaborador { get; set; }
        public string col_nr_cpf { get; set; }
        public string col_nm_colaborador { get; set; }
        public string col_ds_email { get; set; }
        public long? obr_id_obra { get; set; }
        public string obr_ds_obra { get; set; }
        public DateTime? data_login { get; set; }
    }
}
