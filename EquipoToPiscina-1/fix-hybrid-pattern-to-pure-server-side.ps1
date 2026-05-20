# FIX HYBRID PATTERN TO PURE SERVER-SIDE MVC
# This script fixes the incompatible hybrid pattern by converting to pure server-side MVC

Write-Host "🔧 FIXING HYBRID PATTERN TO PURE SERVER-SIDE MVC" -ForegroundColor Yellow
Write-Host "=============================================" -ForegroundColor Yellow

# Stop any running processes first
Write-Host "1. Stopping any running processes..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" -and $_.MainWindowTitle -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "2. Creating PURE SERVER-SIDE MVC implementation..." -ForegroundColor Cyan

# Create the fixed Escolher.cshtml (Pure Server-Side MVC)
Write-Host "   - Creating pure server-side Escolher.cshtml..." -ForegroundColor Green

$escolherContent = @'
@model IEnumerable<dynamic>
@{
    ViewData["Title"] = "Selecionar Obra";
    Layout = "~/Views/Shared/_Layout.cshtml";
}

<div class="container-fluid">
    <div class="row mb-4">
        <div class="col-12">
            <h2 class="text-primary mb-4">Selecione uma das unidades escolares abaixo:</h2>
        </div>
    </div>

    <!-- PURE SERVER-SIDE FILTERS -->
    <div class="row mb-4">
        <div class="col-12">
            <form method="get" asp-action="Escolher" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">Filtrar por Unidade Escolar:</label>
                    <input type="text" name="filtroUnidade" class="form-control" 
                           placeholder="Digite o nome da unidade..." 
                           value="`@ViewBag.FiltroUnidade" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">Filtrar por Município:</label>
                    <input type="text" name="filtroMunicipio" class="form-control" 
                           placeholder="Digite o município..." 
                           value="`@ViewBag.FiltroMunicipio" />
                </div>
                <div class="col-md-4 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary me-2">
                        <i class="fas fa-search"></i> Filtrar
                    </button>
                    <a href="`@Url.Action(`"Escolher`")" class="btn btn-secondary">
                        <i class="fas fa-times"></i> Limpar
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- PURE SERVER-SIDE OBRA CARDS -->
    <div class="row">
        `@if (Model != null && Model.Any())
        {
            `@foreach (var obra in Model)
            {
                <div class="col-xl-2 col-lg-3 col-md-4 col-sm-6 col-12 mb-4">
                    <div class="card h-100 obra-card">
                        <div class="card-body text-center d-flex flex-column">
                            <!-- PURE SERVER-SIDE NAVIGATION -->
                            <form method="post" asp-action="EscolherObra" class="mb-3">
                                <input type="hidden" name="obraId" value="`@obra.IdObra" />
                                <button type="submit" class="btn btn-link p-0 border-0">
                                    <i class="fas fa-building fa-3x text-primary"></i>
                                </button>
                            </form>
                            
                            <h5 class="card-title">`@obra.Descricao</h5>
                            <p class="card-text">`@obra.CidadeEstado</p>
                            <small class="text-muted">(`@obra.StatusBasicaGratuita)</small>
                            
                            <div class="mt-auto">
                                <div class="progress mb-2">
                                    <div class="progress-bar `@(obra.ClasseStatusCss == `"bg-verde`" ? `"bg-success`" : 
                                                              obra.ClasseStatusCss == `"bg-vermelho`" ? `"bg-danger`" : `"bg-secondary`")" 
                                         style="width: `@obra.ProgressoPorcentagem%">
                                        `@obra.ProgressoPorcentagem%
                                    </div>
                                </div>
                                
                                <!-- PURE SERVER-SIDE FORM SUBMISSION -->
                                <form method="post" asp-action="EscolherObra">
                                    <input type="hidden" name="obraId" value="`@obra.IdObra" />
                                    <button type="submit" class="btn btn-primary btn-sm w-100">
                                        <i class="fas fa-arrow-right"></i> Selecionar
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            }
        }
        else
        {
            <div class="col-12">
                <div class="alert alert-info text-center">
                    <i class="fas fa-info-circle me-2"></i>
                    `@if (!string.IsNullOrEmpty(ViewBag.FiltroUnidade?.ToString()) || !string.IsNullOrEmpty(ViewBag.FiltroMunicipio?.ToString()))
                    {
                        <span>Nenhuma obra encontrada com os filtros aplicados.</span>
                    }
                    else
                    {
                        <span>Você deve cadastrar uma unidade escolar para começar a usar o sistema.</span>
                    }
                </div>
            </div>
        }
    </div>

    <!-- LEGEND -->
    `@if (Model != null && Model.Any())
    {
        <div class="row mt-4">
            <div class="col-12">
                <div class="card">
                    <div class="card-body">
                        <h6 class="card-title">Legenda - Barra de Progresso:</h6>
                        <div class="row">
                            <div class="col-md-4">
                                <span class="badge bg-success me-2">Verde</span>
                                Prazo estimado atingido
                            </div>
                            <div class="col-md-4">
                                <span class="badge bg-danger me-2">Vermelho</span>
                                Prazo estimado ultrapassado
                            </div>
                            <div class="col-md-4">
                                <span class="badge bg-secondary me-2">Cinza</span>
                                Em andamento
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    }
</div>

<style>
.obra-card {
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.obra-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 25px rgba(0,0,0,0.15);
}
</style>
'@

Set-Content -Path "Views/Obra/Escolher.cshtml" -Value $escolherContent -Encoding UTF8

Write-Host "3. Updating ObraController for pure server-side..." -ForegroundColor Cyan

# Update ObraController.cs for pure server-side MVC
$controllerContent = @'
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using RdoApp.Core.Controllers.Api;

namespace RdoApp.Core.Controllers
{
    [Authorize]
    public class ObraController : Controller
    {
        private readonly ILogger<ObraController> _logger;
        private readonly ObraApiController _obraApiController;

        public ObraController(ILogger<ObraController> logger, ObraApiController obraApiController)
        {
            _logger = logger;
            _obraApiController = obraApiController;
        }

        // PURE SERVER-SIDE ACTION WITH FILTERING
        public async Task<IActionResult> Escolher(string filtroUnidade = "", string filtroMunicipio = "")
        {
            try
            {
                ViewBag.UsuarioNome = User.Identity?.Name ?? "Usuário";
                ViewBag.FiltroUnidade = filtroUnidade;
                ViewBag.FiltroMunicipio = filtroMunicipio;
                
                _logger.LogInformation("Loading obras for user: {UserName}", ViewBag.UsuarioNome);
                
                // Get all obras from API
                var apiResult = await _obraApiController.ObterObras(new { });
                
                if (apiResult is OkObjectResult okResult)
                {
                    var obras = okResult.Value as List<object>;
                    
                    if (obras != null)
                    {
                        // PURE SERVER-SIDE FILTERING
                        var filteredObras = obras.AsEnumerable();
                        
                        if (!string.IsNullOrEmpty(filtroUnidade))
                        {
                            filteredObras = filteredObras.Where(o => 
                            {
                                var descricao = GetPropertyValue(o, "Descricao")?.ToString() ?? "";
                                return descricao.Contains(filtroUnidade, StringComparison.OrdinalIgnoreCase);
                            });
                        }
                        
                        if (!string.IsNullOrEmpty(filtroMunicipio))
                        {
                            filteredObras = filteredObras.Where(o => 
                            {
                                var cidadeEstado = GetPropertyValue(o, "CidadeEstado")?.ToString() ?? "";
                                return cidadeEstado.Contains(filtroMunicipio, StringComparison.OrdinalIgnoreCase);
                            });
                        }
                        
                        _logger.LogInformation("Filtered to {Count} obras", filteredObras.Count());
                        return View(filteredObras.ToList());
                    }
                }
                
                return View(new List<object>());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao carregar lista de obras");
                return View(new List<object>());
            }
        }

        // PURE SERVER-SIDE OBRA SELECTION
        [HttpPost]
        public async Task<IActionResult> EscolherObra(int obraId)
        {
            try
            {
                _logger.LogInformation("User selecting obra {ObraId}", obraId);
                
                // Store selected obra in session
                HttpContext.Session.SetInt32("ObraId", obraId);
                
                // PURE SERVER-SIDE REDIRECT
                return RedirectToAction("Etapas", new { obraId });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao escolher obra {ObraId}", obraId);
                TempData["ErrorMessage"] = "Erro ao selecionar obra. Tente novamente.";
                return RedirectToAction("Escolher");
            }
        }

        public async Task<IActionResult> Etapas(int? obraId)
        {
            // Keep existing Etapas implementation
            try
            {
                ViewBag.UsuarioNome = User.Identity?.Name ?? "Usuário";
                
                if (!obraId.HasValue)
                {
                    obraId = HttpContext.Session.GetInt32("ObraId") ?? 1;
                }
                
                _logger.LogInformation("Loading etapas for obra {ObraId}", obraId.Value);
                
                var apiResult = await _obraApiController.ObterEtapas(obraId.Value);
                
                if (apiResult is OkObjectResult okResult)
                {
                    var etapasData = okResult.Value as List<object>;
                    ViewBag.ObraId = obraId.Value;
                    ViewBag.ObraNome = $"Obra {obraId.Value}";
                    
                    return View(etapasData ?? new List<object>());
                }
                
                ViewBag.ErrorMessage = "Erro ao carregar etapas";
                return View(new List<object>());
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Erro ao carregar etapas para obra {ObraId}", obraId);
                ViewBag.ErrorMessage = $"Erro ao carregar etapas: {ex.Message}";
                return View("Error");
            }
        }

        // Helper method to get property values from dynamic objects
        private static object? GetPropertyValue(object obj, string propertyName)
        {
            try
            {
                var type = obj.GetType();
                var property = type.GetProperty(propertyName);
                return property?.GetValue(obj);
            }
            catch
            {
                return null;
            }
        }
    }
}
'@

Set-Content -Path "Controllers/ObraController.cs" -Value $controllerContent -Encoding UTF8

Write-Host "4. Building project..." -ForegroundColor Cyan
dotnet build --no-restore

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ SUCCESS: Pure Server-Side MVC implementation complete!" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
    Write-Host "🎯 CHANGES MADE:" -ForegroundColor Yellow
    Write-Host "   ✅ Removed ALL AJAX calls" -ForegroundColor Green
    Write-Host "   ✅ Removed ALL client-side JavaScript" -ForegroundColor Green
    Write-Host "   ✅ Fixed Razor templating with proper @Model" -ForegroundColor Green
    Write-Host "   ✅ Added server-side filtering" -ForegroundColor Green
    Write-Host "   ✅ Added pure server-side navigation" -ForegroundColor Green
    Write-Host "   ✅ Used Bootstrap 5 cards for modern UI" -ForegroundColor Green
    Write-Host "" -ForegroundColor White
    Write-Host "🚀 READY TO TEST:" -ForegroundColor Cyan
    Write-Host "   1. Press F5 in Visual Studio" -ForegroundColor White
    Write-Host "   2. Navigate to /Obra/Escolher" -ForegroundColor White
    Write-Host "   3. Test filtering and obra selection" -ForegroundColor White
} else {
    Write-Host "❌ Build failed. Check errors above." -ForegroundColor Red
}

Write-Host "" -ForegroundColor White
Write-Host "📋 ARCHITECTURE FIXED:" -ForegroundColor Yellow
Write-Host "   ❌ OLD: Hybrid (Server + Client)" -ForegroundColor Red
Write-Host "   ✅ NEW: Pure Server-Side MVC" -ForegroundColor Green