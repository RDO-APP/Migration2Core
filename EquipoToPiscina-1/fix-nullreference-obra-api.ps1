#!/usr/bin/env pwsh

Write-Host "=== FIXING NULL REFERENCE ERROR IN OBRA API CONTROLLER ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# Create backup of current controller
Copy-Item "Controllers/Api/ObraApiController.cs" "Controllers/Api/ObraApiController.cs.backup" -Force
Write-Host "Backup created: ObraApiController.cs.backup" -ForegroundColor Green

# Fix the null reference issues in ObraApiController
$fixedController = @'
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.Entities;
using System.Security.Claims;

namespace RdoApp.Core.Controllers.Api
{
    [ApiController]
    [Route("api/[controller]")]
    public class ObraApiController : ControllerBase
    {
        private readonly RdoContext _context;
        private readonly ILogger<ObraApiController> _logger;

        public ObraApiController(RdoContext context, ILogger<ObraApiController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpPost("ObterObras")]
        public async Task<ActionResult<List<object>>> ObterObras([FromBody] dynamic param)
        {
            try
            {
                _logger.LogInformation("Starting ObterObras request");

                // CRITICAL FIX: Add null checks for User and Claims
                if (User?.Identity == null || !User.Identity.IsAuthenticated)
                {
                    _logger.LogWarning("User is not authenticated");
                    return Unauthorized(new { error = "Usuário não autenticado" });
                }

                // Get user ID from claims with proper null checking
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);
                if (userIdClaim == null || string.IsNullOrEmpty(userIdClaim.Value))
                {
                    _logger.LogWarning("User ID claim not found");
                    return Unauthorized(new { error = "ID do usuário não encontrado" });
                }

                if (!int.TryParse(userIdClaim.Value, out int idColaborador))
                {
                    _logger.LogWarning("Invalid user ID format: {UserId}", userIdClaim.Value);
                    return Unauthorized(new { error = "ID do usuário inválido" });
                }

                _logger.LogInformation("Loading obras for colaborador ID: {ColaboradorId}", idColaborador);

                // CRITICAL FIX: Add null checks for database entities
                var obras = await _context.Obras
                    .Include(o => o.Municipio)
                        .ThenInclude(m => m != null ? m.Uf : null)
                    .Include(o => o.ObraColaboradores)
                        .ThenInclude(oc => oc != null ? oc.Grupo : null)
                    .Where(o => o.ObraColaboradores.Any(oc => oc.ColaboradorId == idColaborador))
                    .Select(o => new
                    {
                        IdObra = o.Id,
                        Descricao = o.Descricao ?? "Obra sem nome",
                        // CRITICAL FIX: Add null checks for Municipio and Uf
                        CidadeEstado = (o.Municipio != null && o.Municipio.Uf != null) 
                            ? $"{o.Municipio.Descricao}/{o.Municipio.Uf.Sigla}"
                            : "Cidade não informada",
                        // CRITICAL FIX: Add null checks for ObraColaboradores and Grupo
                        StatusBasicaGratuita = o.ObraColaboradores
                            .Where(oc => oc.ColaboradorId == idColaborador && oc.Grupo != null)
                            .Select(oc => oc.Grupo.Nome)
                            .FirstOrDefault() ?? "BÁSICA",
                        ContratanteContratada = o.ObraColaboradores
                            .Where(oc => oc.ColaboradorId == idColaborador && oc.Grupo != null)
                            .Select(oc => oc.Grupo.StatusContratante == 1 ? "contratante" : "contratada")
                            .FirstOrDefault() ?? "contratada",
                        ProgressoPorcentagem = CalcularProgressoPorcentagem(o.DataInicio, o.DataPrevisaoFim),
                        ClasseStatusCss = DeterminarClasseStatusCss(o.DataInicio, o.DataPrevisaoFim, o.DataFim),
                        DataInicio = o.DataInicio.ToString("dd/MM/yyyy"),
                        DataConclusao = o.DataFim.HasValue ? o.DataFim.Value.ToString("dd/MM/yyyy") : "",
                        ObraFinalizada = !o.DataFim.HasValue || o.DataFim == DateTime.MinValue
                    })
                    .ToListAsync();

                _logger.LogInformation("Found {Count} obras for colaborador {ColaboradorId}", obras.Count, idColaborador);

                return Ok(obras);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DETAILED ERROR in ObterObras: {Message}", ex.Message);
                _logger.LogError("Stack trace: {StackTrace}", ex.StackTrace);
                return StatusCode(500, new { 
                    error = "Erro interno do servidor", 
                    details = ex.Message,
                    type = ex.GetType().Name
                });
            }
        }

        [HttpGet("Etapas/{obraId}")]
        public async Task<ActionResult<List<object>>> ObterEtapas(int obraId)
        {
            try
            {
                _logger.LogInformation("Loading etapas for obra {ObraId}", obraId);

                // CRITICAL FIX: Add null checks for database context
                if (_context?.Etapas == null)
                {
                    _logger.LogError("Database context or Etapas DbSet is null");
                    return StatusCode(500, new { error = "Erro de configuração do banco de dados" });
                }

                var etapas = await _context.Etapas
                    .Include(e => e.Tarefas)
                        .ThenInclude(t => t != null ? t.Status : null)
                    .Where(e => e.ObraId == obraId)
                    .Select(e => new
                    {
                        Id = e.Id,
                        Titulo = e.Descricao ?? "Etapa sem nome",
                        IdObra = e.ObraId,
                        Tarefas = e.Tarefas != null ? e.Tarefas.Select(t => new
                        {
                            Id = t.Id,
                            Descricao = t.Descricao ?? "Tarefa sem nome",
                            DataInicio = t.DataInicio,
                            DataPrevisaoFim = t.DataPrevisaoFim,
                            DataFim = t.DataFim,
                            DataMedicao = t.DataMedicao,
                            QuantidadeConstruida = t.QuantidadeConstruida,
                            StatusDescricao = t.Status?.Descricao ?? "Planejada"
                        }).ToList() : new List<object>()
                    })
                    .ToListAsync();

                _logger.LogInformation("Found {Count} etapas for obra {ObraId}", etapas.Count, obraId);

                return Ok(etapas);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "DETAILED ERROR loading etapas for obra {ObraId}: {Message}", obraId, ex.Message);
                _logger.LogError("Stack trace: {StackTrace}", ex.StackTrace);
                return StatusCode(500, new { 
                    error = "Erro ao carregar etapas", 
                    details = ex.Message,
                    obraId = obraId,
                    type = ex.GetType().Name
                });
            }
        }

        private static int CalcularProgressoPorcentagem(DateTime dataInicio, DateTime? dataPrevisaoFim)
        {
            try
            {
                if (!dataPrevisaoFim.HasValue) return 0;

                DateTime inicio = dataInicio;
                DateTime fim = dataPrevisaoFim.Value;
                DateTime atual = DateTime.Now;

                double total = fim.Subtract(inicio).Days;
                double decorrido = atual.Subtract(inicio).Days;

                if (atual >= fim)
                {
                    return 100;
                }
                else if (atual < inicio)
                {
                    return 0;
                }

                int result = Convert.ToInt32(Math.Round(100 / total * decorrido, 2));
                return Math.Max(0, Math.Min(100, result)); // Ensure result is between 0-100
            }
            catch (Exception)
            {
                return 0; // Return 0 if calculation fails
            }
        }

        private static string DeterminarClasseStatusCss(DateTime dataInicio, DateTime? dataPrevisaoFim, DateTime? dataFim)
        {
            try
            {
                int progresso = CalcularProgressoPorcentagem(dataInicio, dataPrevisaoFim);

                if (progresso == 100)
                {
                    if (dataFim.HasValue && dataPrevisaoFim.HasValue)
                    {
                        if (dataFim.Value > dataPrevisaoFim.Value)
                        {
                            return "bg-vermelho";
                        }
                        return "bg-verde";
                    }

                    if (!dataFim.HasValue && dataPrevisaoFim.HasValue && DateTime.Now > dataPrevisaoFim.Value)
                    {
                        return "bg-vermelho";
                    }

                    return "bg-verde";
                }

                return "bg-cinza";
            }
            catch (Exception)
            {
                return "bg-cinza"; // Default status if calculation fails
            }
        }
    }
}
'@

# Write the fixed controller
$fixedController | Out-File -FilePath "Controllers/Api/ObraApiController.cs" -Encoding UTF8 -Force

Write-Host "Fixed ObraApiController.cs with comprehensive null checks" -ForegroundColor Green

# Compile to check for errors
Write-Host "`n=== COMPILING PROJECT ===" -ForegroundColor Yellow
dotnet build --no-restore 2>&1 | Tee-Object -Variable buildOutput

if ($LASTEXITCODE -eq 0) {
    Write-Host "COMPILATION SUCCESSFUL!" -ForegroundColor Green
    Write-Host "`n=== NULL REFERENCE FIX APPLIED SUCCESSFULLY ===" -ForegroundColor Green
    Write-Host "- Added comprehensive null checks for User authentication" -ForegroundColor Cyan
    Write-Host "- Added null checks for database entities (Municipio, Uf, Grupo)" -ForegroundColor Cyan
    Write-Host "- Added null checks for navigation properties" -ForegroundColor Cyan
    Write-Host "- Enhanced error logging with detailed information" -ForegroundColor Cyan
    Write-Host "- Added safe calculation methods with exception handling" -ForegroundColor Cyan
    Write-Host "`nREADY FOR TESTING: Press F5 in Visual Studio" -ForegroundColor Green
} else {
    Write-Host "COMPILATION FAILED!" -ForegroundColor Red
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Red
}

# Return to root directory
Set-Location "../.."
Write-Host "Returned to root directory: $(Get-Location)" -ForegroundColor Yellow