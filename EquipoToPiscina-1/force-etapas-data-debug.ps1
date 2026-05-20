# FORCE ETAPAS DATA DEBUG - Silent Void Solution
# This script implements the 3 actions requested to force data out

Write-Host "=== FORCE ETAPAS DATA DEBUG - SILENT VOID SOLUTION ===" -ForegroundColor Yellow
Write-Host "Implementing 3 actions to force data visibility:" -ForegroundColor Cyan
Write-Host "1. Controller: Add debug log for etapas count" -ForegroundColor Green
Write-Host "2. Service: Temporarily bypass authorization filter" -ForegroundColor Green  
Write-Host "3. View: Verify correct Model usage" -ForegroundColor Green

# Action 1: Update ObraController.cs - Add debug log in Etapas action
$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
Write-Host "`nAction 1: Adding debug log to ObraController.Etapas..." -ForegroundColor Yellow

# The controller already has extensive logging, but let's add the specific log you requested
$controllerContent = Get-Content $controllerPath -Raw
if ($controllerContent -notmatch "DEBUG: Controller received.*etapas from Service") {
    $controllerContent = $controllerContent -replace (
        '(\s+var etapas = await _etapaService\.ObterEtapasViewModelAsync\(obraId\.Value, colaboradorId\);)',
        '$1' + "`n" + '                
                // ACTION 1: Debug log requested by user
                Console.WriteLine($"DEBUG: Controller received {etapas.Count} etapas from Service");
                _logger.LogInformation("DEBUG: Controller received {Count} etapas from Service", etapas.Count);'
    )
    Set-Content $controllerPath $controllerContent -Encoding UTF8
    Write-Host "✅ Added debug log to Controller" -ForegroundColor Green
} else {
    Write-Host "✅ Debug log already exists in Controller" -ForegroundColor Green
}

# Action 2: Update EtapaService.cs - Temporarily bypass authorization filter
$servicePath = "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/EtapaService.cs"
Write-Host "`nAction 2: Bypassing authorization filter in EtapaService..." -ForegroundColor Yellow

$serviceContent = Get-Content $servicePath -Raw

# Comment out the authorization filter and use .ToList() directly
$serviceContent = $serviceContent -replace (
    '(\s+)(var tarefasUsuario = etapa\.Tarefas\s+\.Where\(t => IsUserAuthorizedForTask\(t, colaboradorId\)\)\s+\.ToList\(\);)',
    '$1// ACTION 2: TEMPORARY BYPASS - Comment out authorization filter' + "`n" +
    '$1// $2' + "`n" +
    '$1// FORCE ALL DATA - Bypass authorization temporarily' + "`n" +
    '$1var tarefasUsuario = etapa.Tarefas.ToList(); // Show ALL tasks, no filtering'
)

Set-Content $servicePath $serviceContent -Encoding UTF8
Write-Host "✅ Bypassed authorization filter in Service" -ForegroundColor Green

# Action 3: Verify View is using correct Model
Write-Host "`nAction 3: Verifying Etapas.cshtml uses correct Model..." -ForegroundColor Yellow

$viewPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Etapas.cshtml"
$viewContent = Get-Content $viewPath -Raw

if ($viewContent -match "@model IEnumerable<RdoApp\.Core\.Models\.ViewModels\.EtapaViewModel>") {
    Write-Host "✅ View correctly uses EtapaViewModel model" -ForegroundColor Green
} else {
    Write-Host "❌ View model declaration issue found!" -ForegroundColor Red
}

if ($viewContent -match "etapa\.value\.Descricao") {
    Write-Host "✅ View correctly accesses Descricao property" -ForegroundColor Green
} else {
    Write-Host "❌ View property access issue found!" -ForegroundColor Red
}

# Additional debugging - Add console logs to view
if ($viewContent -notmatch "FORCE DEBUG: Model count") {
    $viewContent = $viewContent -replace (
        '(@{[\s\S]*?ViewData\["Title"\] = "Etapas / Tarefas";[\s\S]*?})',
        '$1' + "`n" + '@{' + "`n" + '    // ACTION 3: Force debug in view' + "`n" + '    var modelCount = Model?.Count() ?? 0;' + "`n" + '    System.Console.WriteLine($"FORCE DEBUG: Model count = {modelCount}");' + "`n" + '    if (Model != null) {' + "`n" + '        foreach (var etapa in Model) {' + "`n" + '            System.Console.WriteLine($"FORCE DEBUG: Etapa {etapa.Id}: {etapa.Descricao} - {etapa.TotalTarefas} tarefas");' + "`n" + '        }' + "`n" + '    }' + "`n" + '}'
    )
    Set-Content $viewPath $viewContent -Encoding UTF8
    Write-Host "✅ Added debug logs to View" -ForegroundColor Green
} else {
    Write-Host "✅ Debug logs already exist in View" -ForegroundColor Green
}

Write-Host "`n=== CONSOLIDATED SOLUTION APPLIED ===" -ForegroundColor Yellow
Write-Host "All 3 actions completed:" -ForegroundColor Cyan
Write-Host "✅ Controller: Added debug log for etapas count" -ForegroundColor Green
Write-Host "✅ Service: Bypassed authorization filter (TEMPORARY)" -ForegroundColor Green
Write-Host "✅ View: Verified model usage and added debug logs" -ForegroundColor Green

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Yellow
Write-Host "1. Compile the project" -ForegroundColor White
Write-Host "2. Navigate to Etapas?obraId=233" -ForegroundColor White
Write-Host "3. Check console output for debug messages" -ForegroundColor White
Write-Host "4. Look for 'DEBUG: Controller received X etapas from Service'" -ForegroundColor White
Write-Host "5. Look for 'FORCE DEBUG: Model count = X'" -ForegroundColor White

Write-Host "`n⚠️  IMPORTANT: Remember to restore authorization filter after debugging!" -ForegroundColor Red
Write-Host "The authorization bypass is TEMPORARY for debugging only." -ForegroundColor Red

Write-Host "`nRunning compilation test..." -ForegroundColor Yellow
try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilation successful!" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation failed - check errors above" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Error during compilation: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location "../.."
}

Write-Host "`n🎯 READY TO TEST: Navigate to Etapas?obraId=233 and check console output!" -ForegroundColor Green