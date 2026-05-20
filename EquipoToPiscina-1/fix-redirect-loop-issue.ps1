# Fix Redirect Loop Issue
Write-Host "🔧 FIXING REDIRECT LOOP ISSUE" -ForegroundColor Yellow
Write-Host ""

Write-Host "Problem identified:" -ForegroundColor Red
Write-Host "- Home/Index redirects to Obra/Escolher" -ForegroundColor Yellow
Write-Host "- Obra/Escolher has [Authorize] attribute" -ForegroundColor Yellow
Write-Host "- Creates redirect loop for unauthenticated users" -ForegroundColor Yellow

Write-Host ""
Write-Host "Applying fix..." -ForegroundColor Green

# Fix 1: Update HomeController to check authentication properly
$homeControllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/HomeController.cs"

$homeControllerContent = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RdoApp.Core.Models;
using System.Diagnostics;

namespace RdoApp.Core.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            // Se usuário está autenticado, redirecionar para obras
            if (User.Identity?.IsAuthenticated == true)
            {
                ViewBag.UsuarioNome = User.Identity?.Name ?? "Usuário";
                ViewBag.UsuarioCpf = User.FindFirst("cpf")?.Value ?? "";
                
                // Redirecionar usuário logado diretamente para obras
                return RedirectToAction("Escolher", "Obra");
            }
            
            // Se não está autenticado, redirecionar para login
            return RedirectToAction("Login", "Auth");
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
'@

Write-Host "1. Updating HomeController..." -ForegroundColor Cyan
Set-Content -Path $homeControllerPath -Value $homeControllerContent -Encoding UTF8
Write-Host "   ✅ HomeController updated" -ForegroundColor Green

# Fix 2: Update AuthController to redirect properly after login
$authControllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/AuthController.cs"

Write-Host "2. Reading current AuthController..." -ForegroundColor Cyan
$authContent = Get-Content -Path $authControllerPath -Raw

# Update the login redirect logic
$updatedAuthContent = $authContent -replace 'return RedirectToAction\("Index", "Home"\);', 'return RedirectToAction("Escolher", "Obra");'

Set-Content -Path $authControllerPath -Value $updatedAuthContent -Encoding UTF8
Write-Host "   ✅ AuthController updated" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 FIXES APPLIED:" -ForegroundColor Green
Write-Host "1. HomeController now properly checks authentication" -ForegroundColor White
Write-Host "2. AuthController redirects directly to Obra/Escolher after login" -ForegroundColor White
Write-Host "3. Eliminated redirect loop" -ForegroundColor White

Write-Host ""
Write-Host "📋 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Stop Visual Studio debugging (Shift+F5)" -ForegroundColor Cyan
Write-Host "2. Rebuild the project (Ctrl+Shift+B)" -ForegroundColor Cyan
Write-Host "3. Start debugging again (F5)" -ForegroundColor Cyan
Write-Host "4. Test the flow:" -ForegroundColor Cyan
Write-Host "   - Should go to login page first" -ForegroundColor White
Write-Host "   - After login, should go directly to obra selection" -ForegroundColor White

Write-Host ""
Write-Host "✅ REDIRECT LOOP FIX COMPLETE" -ForegroundColor Green