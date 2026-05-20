using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Interfaces;
using System.Security.Claims;

namespace RdoApp.Core.Controllers
{
    /// <summary>
    /// Account Controller - Replaces AngularJS login routing
    /// Serves login functionality at /Account/Login to break legacy routing
    /// </summary>
    public class AccountController : Controller
    {
        private readonly IAuthService _authService;
        private readonly ILogger<AccountController> _logger;

        public AccountController(IAuthService authService, ILogger<AccountController> logger)
        {
            _authService = authService;
            _logger = logger;
        }

        /// <summary>
        /// GET: /Account/Login
        /// Displays the Blazor login component hosted in MVC view
        /// </summary>
        /// <param name="returnUrl">URL to redirect after successful login</param>
        /// <returns>Login view with Blazor component</returns>
        [HttpGet]
        [AllowAnonymous]
        [Route("Account/Login")]
        public async Task<IActionResult> Login(string? returnUrl = null, bool forceLogout = false)
        {
            // ONLY force logout if explicitly requested via forceLogout parameter
            if (forceLogout && User.Identity?.IsAuthenticated == true)
            {
                _logger.LogInformation("Explicit force logout requested for user {UserName}", User.Identity.Name);
                
                // Clear authentication cookie
                await HttpContext.SignOutAsync("Cookies");
                
                // Clear session data
                HttpContext.Session.Clear();
                
                // Clear all cookies to ensure complete logout
                foreach (var cookie in Request.Cookies.Keys)
                {
                    Response.Cookies.Delete(cookie);
                }
                
                // Force redirect to prevent authentication bypass
                return RedirectToAction("Login", "Account");
            }

            // If user is already authenticated and accessing login page normally, redirect to obra selection
            if (User.Identity?.IsAuthenticated == true && !forceLogout)
            {
                _logger.LogInformation("User {UserName} already authenticated, redirecting to obra selection", User.Identity.Name);
                return RedirectToAction("Escolher", "Obra");
            }

            ViewData["ReturnUrl"] = returnUrl;
            ViewData["Title"] = "Login - RDO App Piscinas";
            
            _logger.LogInformation("Displaying pure HTML login view at /Account/Login");
            
            return View("Login");
        }

        /// <summary>
        /// POST: /Account/Login
        /// Processes login form submission (standard HTML form, no AJAX)
        /// </summary>
        /// <param name="model">Login credentials</param>
        /// <param name="returnUrl">URL to redirect after successful login</param>
        /// <returns>Redirect on success, view with errors on failure</returns>
        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        [Route("Account/Login")]
        public async Task<IActionResult> Login(LoginDto model, string? returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            ViewData["Title"] = "Login - RDO App Piscinas";

            _logger.LogInformation("Processing login attempt for CPF: {Cpf}", model.Cpf?.Substring(0, 3) + "***");

            if (!ModelState.IsValid)
            {
                _logger.LogWarning("Login form validation failed");
                return View(model);
            }

            try
            {
                var resultado = await _authService.LoginAsync(model);

                if (!resultado.Sucesso)
                {
                    _logger.LogWarning("Login failed for CPF {Cpf}: {Message}", 
                        model.Cpf?.Substring(0, 3) + "***", resultado.Mensagem);
                    
                    ModelState.AddModelError(string.Empty, resultado.Mensagem);
                    return View(model);
                }

                // Create user claims
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.NameIdentifier, resultado.Usuario!.Id.ToString()),
                    new Claim(ClaimTypes.Name, resultado.Usuario.Nome),
                    new Claim("cpf", resultado.Usuario.Cpf),
                    new Claim(ClaimTypes.Email, resultado.Usuario.Email ?? ""),
                    new Claim("telefone", resultado.Usuario.Telefone ?? ""),
                    new Claim("ativo", resultado.Usuario.Ativo.ToString()),
                    new Claim("loginMethod", "NativePost") // Track that this came from native HTML POST
                };

                var claimsIdentity = new ClaimsIdentity(claims, "Cookies");
                var claimsPrincipal = new ClaimsPrincipal(claimsIdentity);

                var authProperties = new AuthenticationProperties
                {
                    IsPersistent = model.LembrarMe,
                    ExpiresUtc = model.LembrarMe ? DateTimeOffset.UtcNow.AddDays(30) : DateTimeOffset.UtcNow.AddHours(8)
                };

                await HttpContext.SignInAsync("Cookies", claimsPrincipal, authProperties);

                _logger.LogInformation("User {Nome} ({Cpf}) logged in successfully via AccountController", 
                    resultado.Usuario.Nome, resultado.Usuario.Cpf?.Substring(0, 3) + "***");

                // Redirect to return URL or obra selection (not Home)
                if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
                {
                    _logger.LogInformation("Redirecting to return URL: {ReturnUrl}", returnUrl);
                    return Redirect(returnUrl);
                }

                _logger.LogInformation("Redirecting to obra selection");
                return RedirectToAction("Escolher", "Obra");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error during login for CPF {Cpf}", 
                    model.Cpf?.Substring(0, 3) + "***");
                
                ModelState.AddModelError(string.Empty, "Erro interno do sistema. Tente novamente.");
                return View(model);
            }
        }

        /// <summary>
        /// POST: /Account/Logout
        /// Logs out the current user
        /// </summary>
        /// <returns>Redirect to login page</returns>
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        [Route("Account/Logout")]
        public async Task<IActionResult> Logout()
        {
            var userName = User.Identity?.Name ?? "Unknown User";
            
            try
            {
                await HttpContext.SignOutAsync("Cookies");
                HttpContext.Session.Clear(); // Clear session data on logout
                _logger.LogInformation("User {UserName} logged out successfully", userName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during logout for user {UserName}", userName);
            }
            
            return RedirectToAction("Login");
        }

        /// <summary>
        /// GET: /Account/AccessDenied
        /// Displays access denied page
        /// </summary>
        /// <returns>Access denied view</returns>
        [HttpGet]
        [AllowAnonymous]
        [Route("Account/AccessDenied")]
        public IActionResult AccessDenied()
        {
            _logger.LogWarning("Access denied for user {UserName}", User.Identity?.Name ?? "Anonymous");
            return View();
        }

        /// <summary>
        /// GET: /Account/Profile
        /// Displays user profile (future implementation)
        /// </summary>
        /// <returns>Profile view</returns>
        [HttpGet]
        [Authorize]
        [Route("Account/Profile")]
        public IActionResult Profile()
        {
            return View();
        }

        /// <summary>
        /// GET: /Account/ForceLogout
        /// Forces logout and redirects to clean login page (for testing)
        /// </summary>
        /// <returns>Redirect to login</returns>
        [HttpGet]
        [AllowAnonymous]
        [Route("Account/ForceLogout")]
        public async Task<IActionResult> ForceLogout()
        {
            var userName = User.Identity?.Name ?? "Anonymous";
            _logger.LogInformation("Force logout requested for user {UserName}", userName);
            
            try
            {
                await HttpContext.SignOutAsync("Cookies");
                HttpContext.Session.Clear();
                _logger.LogInformation("Force logout completed for user {UserName}", userName);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during force logout for user {UserName}", userName);
            }
            
            return RedirectToAction("Login");
        }
    }
}