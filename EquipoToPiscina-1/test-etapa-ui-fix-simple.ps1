Write-Host "TESTING ETAPA/TAREFA UI FIX - FINAL MIGRATION STAGE" -ForegroundColor Cyan

# Test build
Write-Host "1. TESTING BUILD..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESS" -ForegroundColor Green
} else {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}

# Check TarefaController view path
Write-Host "2. CHECKING TAREFACONTROLLER VIEW PATH..." -ForegroundColor Yellow
$tarefaContent = Get-Content "Controllers/TarefaController.cs" -Raw

if ($tarefaContent -match 'return View\("~/Views/Etapa/Cards\.cshtml"') {
    Write-Host "TAREFACONTROLLER VIEW PATH - OK" -ForegroundColor Green
} else {
    Write-Host "TAREFACONTROLLER VIEW PATH - ISSUE" -ForegroundColor Red
}

# Check Etapa/Cards layout
Write-Host "3. CHECKING ETAPA/CARDS LAYOUT..." -ForegroundColor Yellow
$etapaCardsContent = Get-Content "Views/Etapa/Cards.cshtml" -Raw

if ($etapaCardsContent -match 'Layout = "_Layout"' -and $etapaCardsContent -match '@section Styles') {
    Write-Host "ETAPA/CARDS LAYOUT AND STYLES - OK" -ForegroundColor Green
} else {
    Write-Host "ETAPA/CARDS LAYOUT OR STYLES - ISSUE" -ForegroundColor Red
}

# Check CSS file
Write-Host "4. CHECKING CSS FILE..." -ForegroundColor Yellow
if (Test-Path "wwwroot/css/task-cards-compact.css") {
    Write-Host "TASK-CARDS-COMPACT.CSS - EXISTS" -ForegroundColor Green
} else {
    Write-Host "TASK-CARDS-COMPACT.CSS - MISSING" -ForegroundColor Red
}

Write-Host "ETAPA/TAREFA UI FIX COMPLETE" -ForegroundColor Green
Set-Location "../.."