#!/usr/bin/env pwsh

# Diagnóstico para página vazia de Etapas e Tarefas
# Investiga por que não estão aparecendo registros

Write-Host "🔍 Diagnóstico: Página Etapas/Tarefas Vazia" -ForegroundColor Yellow
Write-Host "=" * 60

# Teste 1: Verificar se há dados no banco
Write-Host "`n📋 Teste 1: Verificando dados no banco" -ForegroundColor Cyan

$sqlScript = @"
-- Verificar se existem etapas no banco
SELECT COUNT(*) as TotalEtapas FROM etapa;

-- Verificar etapas por obra
SELECT eta_id_obra as ObraId, COUNT(*) as QtdEtapas 
FROM etapa 
GROUP BY eta_id_obra 
ORDER BY eta_id_obra;

-- Verificar se existem tarefas no banco
SELECT COUNT(*) as TotalTarefas FROM tarefa;

-- Verificar tarefas por etapa
SELECT tar_id_etapa as EtapaId, COUNT(*) as QtdTarefas 
FROM tarefa 
GROUP BY tar_id_etapa 
ORDER BY tar_id_etapa;

-- Verificar dados de uma obra específica (obra 1)
SELECT e.eta_id_etapa, e.eta_ds_etapa, COUNT(t.tar_id_tarefa) as QtdTarefas
FROM etapa e
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
WHERE e.eta_id_obra = 1
GROUP BY e.eta_id_etapa, e.eta_ds_etapa
ORDER BY e.eta_id_etapa;
"@

Write-Output $sqlScript | Out-File -FilePath "verify-etapa-tarefa-data.sql" -Encoding UTF8
Write-Host "✅ Script SQL criado: verify-etapa-tarefa-data.sql" -ForegroundColor Green
Write-Host "Execute este script no DBeaver para verificar os dados" -ForegroundColor Yellow

# Teste 2: Verificar logs do controller
Write-Host "`n📋 Teste 2: Verificando implementação do Controller" -ForegroundColor Cyan

$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
if (Test-Path $controllerPath) {
    $controllerContent = Get-Content $controllerPath -Raw
    
    if ($controllerContent -match "_etapaService\.ObterEtapasViewModelAsync") {
        Write-Host "✅ Controller usa o novo método ObterEtapasViewModelAsync" -ForegroundColor Green
    } else {
        Write-Host "❌ Controller NÃO usa o novo método" -ForegroundColor Red
        Write-Host "Problema: Controller ainda pode estar usando método antigo" -ForegroundColor Yellow
    }
    
    if ($controllerContent -match "User\.FindFirst\(ClaimTypes\.NameIdentifier\)") {
        Write-Host "✅ Claims authentication implementada" -ForegroundColor Green
    } else {
        Write-Host "❌ Claims authentication ausente" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Controller não encontrado" -ForegroundColor Red
}

# Teste 3: Verificar se o serviço está funcionando
Write-Host "`n📋 Teste 3: Verificando implementação do EtapaService" -ForegroundColor Cyan

$servicePath = "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/EtapaService.cs"
if (Test-Path $servicePath) {
    $serviceContent = Get-Content $servicePath -Raw
    
    if ($serviceContent -match "ObterEtapasViewModelAsync.*int obraId.*int colaboradorId") {
        Write-Host "✅ Método ObterEtapasViewModelAsync implementado" -ForegroundColor Green
    } else {
        Write-Host "❌ Método ObterEtapasViewModelAsync ausente ou incorreto" -ForegroundColor Red
    }
    
    if ($serviceContent -match "MapTarefaToViewModel") {
        Write-Host "✅ Método MapTarefaToViewModel implementado" -ForegroundColor Green
    } else {
        Write-Host "❌ Método MapTarefaToViewModel ausente" -ForegroundColor Red
    }
} else {
    Write-Host "❌ EtapaService não encontrado" -ForegroundColor Red
}

# Teste 4: Verificar ViewModels
Write-Host "`n📋 Teste 4: Verificando ViewModels" -ForegroundColor Cyan

$etapaViewModelPath = "RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/EtapaViewModel.cs"
$tarefaViewModelPath = "RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/TarefaViewModel.cs"

if (Test-Path $etapaViewModelPath) {
    Write-Host "✅ EtapaViewModel existe" -ForegroundColor Green
} else {
    Write-Host "❌ EtapaViewModel não encontrado" -ForegroundColor Red
}

if (Test-Path $tarefaViewModelPath) {
    Write-Host "✅ TarefaViewModel existe" -ForegroundColor Green
} else {
    Write-Host "❌ TarefaViewModel não encontrado" -ForegroundColor Red
}

# Teste 5: Verificar View
Write-Host "`n📋 Teste 5: Verificando View" -ForegroundColor Cyan

$viewPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Etapas.cshtml"
if (Test-Path $viewPath) {
    $viewContent = Get-Content $viewPath -Raw
    
    if ($viewContent -match "@model.*EtapaViewModel") {
        Write-Host "✅ View usa EtapaViewModel" -ForegroundColor Green
    } else {
        Write-Host "❌ View NÃO usa EtapaViewModel" -ForegroundColor Red
        Write-Host "Problema: View ainda pode estar usando entidades" -ForegroundColor Yellow
    }
    
    if ($viewContent -match "etapa\.value\.Tarefas") {
        Write-Host "✅ View acessa propriedade Tarefas do ViewModel" -ForegroundColor Green
    } else {
        Write-Host "❌ View NÃO acessa propriedade Tarefas" -ForegroundColor Red
    }
} else {
    Write-Host "❌ View não encontrada" -ForegroundColor Red
}

# Teste 6: Criar script de teste direto
Write-Host "`n📋 Teste 6: Criando teste direto do serviço" -ForegroundColor Cyan

$testScript = @"
using Microsoft.Extensions.DependencyInjection;
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Services.Interfaces;
using RdoApp.Core.Services.Implementations;

// Teste direto do EtapaService
var services = new ServiceCollection();

// Configurar DbContext
var connectionString = "Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa;Uid=rdoadmin;Pwd=rdoapp2018aws;CharSet=utf8mb4;";
services.AddDbContext<RdoContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// Registrar serviços
services.AddScoped<IEtapaService, EtapaService>();
services.AddScoped<ITarefaService, TarefaService>();

var serviceProvider = services.BuildServiceProvider();

// Testar o serviço
using var scope = serviceProvider.CreateScope();
var etapaService = scope.ServiceProvider.GetRequiredService<IEtapaService>();

try 
{
    Console.WriteLine("Testando ObterEtapasViewModelAsync...");
    var etapas = await etapaService.ObterEtapasViewModelAsync(1, 1); // obra 1, colaborador 1
    
    Console.WriteLine($"Resultado: {etapas.Count} etapas encontradas");
    
    foreach (var etapa in etapas)
    {
        Console.WriteLine($"Etapa {etapa.Id}: {etapa.Descricao} - {etapa.TotalTarefas} tarefas");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"ERRO: {ex.Message}");
    Console.WriteLine($"Stack: {ex.StackTrace}");
}
"@

Write-Output $testScript | Out-File -FilePath "test-etapa-service-direct.cs" -Encoding UTF8
Write-Host "✅ Teste direto criado: test-etapa-service-direct.cs" -ForegroundColor Green

# Teste 7: Verificar possíveis problemas comuns
Write-Host "`n📋 Teste 7: Verificando problemas comuns" -ForegroundColor Cyan

Write-Host "Possíveis causas da página vazia:" -ForegroundColor Yellow
Write-Host "1. 🔍 Dados não existem no banco para a obra selecionada" -ForegroundColor White
Write-Host "2. 🔍 Problema na autenticação - colaboradorId inválido" -ForegroundColor White
Write-Host "3. 🔍 Erro na query do Entity Framework" -ForegroundColor White
Write-Host "4. 🔍 Problema no mapeamento Entity -> ViewModel" -ForegroundColor White
Write-Host "5. 🔍 Erro na View ao renderizar os dados" -ForegroundColor White
Write-Host "6. 🔍 Exceção silenciosa no controller" -ForegroundColor White

# Teste 8: Criar script de debug para controller
Write-Host "`n📋 Teste 8: Criando versão debug do controller" -ForegroundColor Cyan

$debugControllerMethod = @"
public async Task<IActionResult> Etapas(int? obraId)
{
    try
    {
        // DEBUG: Log início
        _logger.LogInformation("=== INÍCIO DEBUG ETAPAS ===");
        
        // IMPROVEMENT 3: Claims-based authentication
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        _logger.LogInformation("UserIdClaim: {UserIdClaim}", userIdClaim ?? "NULL");
        
        if (string.IsNullOrEmpty(userIdClaim) || !int.TryParse(userIdClaim, out int colaboradorId))
        {
            _logger.LogWarning("Invalid or missing user ID claim for Etapas access");
            return RedirectToAction("Login", "Auth");
        }
        
        _logger.LogInformation("ColaboradorId extraído: {ColaboradorId}", colaboradorId);

        if (!obraId.HasValue)
        {
            obraId = HttpContext.Session.GetInt32("ObraId") ?? 1;
        }
        
        _logger.LogInformation("ObraId: {ObraId}", obraId.Value);

        // DEBUG: Testar conexão com banco
        var totalEtapas = await _context.Etapas.CountAsync();
        _logger.LogInformation("Total de etapas no banco: {TotalEtapas}", totalEtapas);
        
        var etapasObra = await _context.Etapas.Where(e => e.ObraId == obraId.Value).CountAsync();
        _logger.LogInformation("Etapas para obra {ObraId}: {EtapasObra}", obraId.Value, etapasObra);

        // IMPROVEMENT 2: Use dedicated EtapaService with strongly-typed ViewModels
        _logger.LogInformation("Chamando ObterEtapasViewModelAsync...");
        var etapas = await _etapaService.ObterEtapasViewModelAsync(obraId.Value, colaboradorId);
        
        _logger.LogInformation("Resultado: {Count} etapas retornadas", etapas.Count);
        
        foreach (var etapa in etapas)
        {
            _logger.LogInformation("Etapa {Id}: {Descricao} - {TotalTarefas} tarefas", 
                etapa.Id, etapa.Descricao, etapa.TotalTarefas);
        }

        ViewBag.ObraId = obraId.Value;
        ViewBag.ObraNome = $"Obra {obraId.Value}";
        ViewBag.UsuarioNome = User.Identity?.Name ?? "Usuário";

        _logger.LogInformation("=== FIM DEBUG ETAPAS ===");

        // IMPROVEMENT 1: Return strongly-typed ViewModels
        return View(etapas);
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "ERRO COMPLETO ao carregar etapas para obra {ObraId}", obraId);
        ViewBag.ErrorMessage = "Erro ao carregar etapas. Tente novamente.";
        return View(new List<EtapaViewModel>());
    }
}
"@

Write-Output $debugControllerMethod | Out-File -FilePath "debug-controller-method.cs" -Encoding UTF8
Write-Host "✅ Método debug criado: debug-controller-method.cs" -ForegroundColor Green

Write-Host "`n🎯 PRÓXIMOS PASSOS PARA DIAGNÓSTICO:" -ForegroundColor Green
Write-Host "1. Execute verify-etapa-tarefa-data.sql no DBeaver para verificar dados" -ForegroundColor Yellow
Write-Host "2. Substitua temporariamente o método Etapas() pelo debug version" -ForegroundColor Yellow
Write-Host "3. Execute a aplicação e verifique os logs no console" -ForegroundColor Yellow
Write-Host "4. Verifique se há exceções no Visual Studio Output" -ForegroundColor Yellow

Write-Host "`n📊 DIAGNÓSTICO COMPLETO!" -ForegroundColor Green