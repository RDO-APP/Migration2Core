using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Interfaces;
using System.Security.Claims;

namespace RdoApp.Core.Controllers
{
    public class AuthController : Controller
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AuthController> _logger;

        public AuthController(IAuthService authService, ILogger<AuthController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult Login(string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginDto model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var resultado = await _authService.LoginAsync(model);

            if (!resultado.Sucesso)
            {
                ModelState.AddModelError(string.Empty, resultado.Mensagem);
                return View(model);
            }

            // Criar claims do usuário
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, resultado.Usuario!.Id.ToString()),
                new Claim(ClaimTypes.Name, resultado.Usuario.Nome),
                new Claim("cpf", resultado.Usuario.Cpf),
                new Claim(ClaimTypes.Email, resultado.Usuario.Email ?? ""),
                new Claim("telefone", resultado.Usuario.Telefone ?? "")
            };

            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            var authProperties = new AuthenticationProperties
            {
                IsPersistent = model.LembrarMe,
                ExpiresUtc = model.LembrarMe ? DateTimeOffset.UtcNow.AddDays(30) : DateTimeOffset.UtcNow.AddHours(8)
            };

            await HttpContext.SignInAsync("Cookies", claimsPrincipal, authProperties);

            _logger.LogInformation("Usuário {Nome} ({Cpf}) fez login com sucesso", resultado.Usuario.Nome, resultado.Usuario.Cpf);

            // Redirecionar para URL de retorno ou dashboard
            if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
            {
                return Redirect(returnUrl);
            }

            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            var userName = User.Identity?.Name ?? "Usuário desconhecido";
            await HttpContext.SignOutAsync("Cookies");
            
            _logger.LogInformation("Usuário {UserName} fez logout", userName);
            
            return RedirectToAction("Login");
        }

        [HttpGet]
        [AllowAnonymous]
        public IActionResult AccessDenied()
        {
            return View();
        }

        // API endpoints para login via AJAX
        [HttpPost]
        [Route("api/auth/login")]
        [AllowAnonymous]
        public async Task<IActionResult> LoginApi([FromBody] LoginDto model)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new { sucesso = false, mensagem = "Dados inválidos", erros = ModelState });
            }

            var resultado = await _authService.LoginAsync(model);

            if (!resultado.Sucesso)
            {
                return BadRequest(new { sucesso = false, mensagem = resultado.Mensagem });
            }

            // Criar claims do usuário
            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.NameIdentifier, resultado.Usuario!.Id.ToString()),
                new Claim(ClaimTypes.Name, resultado.Usuario.Nome),
                new Claim("cpf", resultado.Usuario.Cpf),
                new Claim(ClaimTypes.Email, resultado.Usuario.Email ?? ""),
                new Claim("telefone", resultado.Usuario.Telefone ?? "")
            };

            var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
            var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

            var authProperties = new AuthenticationProperties
            {
                IsPersistent = model.LembrarMe,
                ExpiresUtc = model.LembrarMe ? DateTimeOffset.UtcNow.AddDays(30) : DateTimeOffset.UtcNow.AddHours(8)
            };

            await HttpContext.SignInAsync("Cookies", claimsPrincipal, authProperties);

            return Ok(new { 
                sucesso = true, 
                mensagem = resultado.Mensagem,
                usuario = resultado.Usuario
            });
        }

        [HttpPost]
        [Route("api/auth/logout")]
        [Authorize]
        public async Task<IActionResult> LogoutApi()
        {
            await HttpContext.SignOutAsync("Cookies");
            return Ok(new { sucesso = true, mensagem = "Logout realizado com sucesso" });
        }

        [HttpGet]
        [Route("api/auth/user")]
        [Authorize]
        public async Task<IActionResult> GetCurrentUser()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            
            if (string.IsNullOrEmpty(userId) || !int.TryParse(userId, out int id))
            {
                return Unauthorized();
            }

            var usuario = await _authService.GetUsuarioByIdAsync(id);
            
            if (usuario == null)
            {
                return NotFound();
            }

            return Ok(usuario);
        }
    }
}