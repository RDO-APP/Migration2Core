using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;

namespace RdoApp.Core.Controllers
{
    /// <summary>
    /// Home Controller - Redirects to Single DNA Blazor Login
    /// </summary>
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Redirect to Blazor Login Page - Single DNA Architecture
        /// </summary>
        /// <returns>Redirect to Blazor login</returns>
        public async Task<IActionResult> RedirectToBlazorLogin()
        {
            // Clear any existing authentication to ensure clean login
            if (User.Identity?.IsAuthenticated == true)
            {
                _logger.LogInformation("Clearing existing authentication for clean Blazor login");
                await HttpContext.SignOutAsync("Cookies");
                HttpContext.Session.Clear();
            }

            _logger.LogInformation("Redirecting to Single DNA Blazor Login");
            return Redirect("/Account/Login");
        }

        /// <summary>
        /// Legacy Index action - redirects to Blazor login
        /// </summary>
        /// <returns>Redirect to Blazor login</returns>
        public async Task<IActionResult> Index()
        {
            return await RedirectToBlazorLogin();
        }

        /// <summary>
        /// Error page
        /// </summary>
        /// <returns>Error view</returns>
        public IActionResult Error()
        {
            return View();
        }
    }
}