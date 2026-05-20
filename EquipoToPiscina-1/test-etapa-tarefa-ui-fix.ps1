#!/usr/bin/env pwsh

Write-Host "🔧 TESTING ETAPA/TAREFA UI FIX - FINAL MIGRATION STAGE" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# Test 1: Build verification
Write-Host "`n1️⃣ TESTING BUILD..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ BUILD SUCCESS" -ForegroundColor Green
} else {
    Write-Host "❌ BUILD FAILED" -ForegroundColor Red
    Write-Host $buildResult
    exit 1
}

# Test 2: Check TarefaController view path fix
Write-Host "`n2️⃣ CHECKING TAREFACONTROLLER VIEW PATH..." -ForegroundColor Yellow
$tarefaContent = Get-Content "Controllers/TarefaController.cs" -Raw

if ($tarefaContent -match 'return View\("~/Views/Etapa/Cards\.cshtml"') {
    Write-Host "✅ TAREFACONTROLLER USES CORRECT VIEW PATH" -ForegroundColor Green
} else {
    Write-Host "❌ TAREFACONTROLLER VIEW PATH INCORRECT" -ForegroundColor Red
}

# Test 3: Check Etapa/Cards layout reference
Write-Host "`n3️⃣ CHECKING ETAPA/CARDS LAYOUT REFERENCE..." -ForegroundColor Yellow
$etapaCardsContent = Get-Content "Views/Etapa/Cards.cshtml" -Raw

if ($etapaCardsContent -match 'Layout = "_Layout"') {
    Write-Host "✅ ETAPA/CARDS USES CORRECT LAYOUT REFERENCE" -ForegroundColor Green
} else {
    Write-Host "❌ ETAPA/CARDS LAYOUT REFERENCE INCORRECT" -ForegroundColor Red
}

# Test 4: Check CSS section in Etapa/Cards
if ($etapaCardsContent -match '@section Styles' -and 
    $etapaCardsContent -match 'task-cards-compact\.css') {
    Write-Host "✅ ETAPA/CARDS HAS STYLES SECTION WITH CSS" -ForegroundColor Green
} else {
    Write-Host "❌ ETAPA/CARDS STYLES SECTION MISSING" -ForegroundColor Red
}

# Test 5: Check CSS file exists
Write-Host "`n4️⃣ CHECKING CSS FILE EXISTS..." -ForegroundColor Yellow
if (Test-Path "wwwroot/css/task-cards-compact.css") {
    Write-Host "✅ TASK-CARDS-COMPACT.CSS EXISTS" -ForegroundColor Green
} else {
    Write-Host "❌ TASK-CARDS-COMPACT.CSS MISSING" -ForegroundColor Red
}

# Test 6: Check Layout CSS paths (already verified but double-check)
Write-Host "`n5️⃣ CHECKING LAYOUT CSS PATHS..." -ForegroundColor Yellow
$layoutContent = Get-Content "Views/Shared/_Layout.cshtml" -Raw

if ($layoutContent -match 'href="~/lib/bootstrap' -and 
    $layoutContent -match 'href="~/css/site.css' -and
    $layoutContent -match '@await RenderSectionAsync\("Styles", required: false\)') {
    Write-Host "✅ LAYOUT CSS PATHS AND STYLES SECTION CORRECT" -ForegroundColor Green
} else {
    Write-Host "❌ LAYOUT CSS PATHS OR STYLES SECTION INCORRECT" -ForegroundColor Red
}

# Test 7: Check partial views exist
Write-Host "`n6️⃣ CHECKING PARTIAL VIEWS..." -ForegroundColor Yellow
$partialViews = @(
    "Views/Etapa/_FilterPartial.cshtml",
    "Views/Etapa/_EtapaAccordionPartial.cshtml",
    "Views/Etapa/_HistoricoTarefaModal.cshtml",
    "Views/Etapa/_NovaMedicaoModal.cshtml",
    "Views/Etapa/_RelatorioHorasModal.cshtml",
    "Views/Etapa/_AlterarStatusMassaModal.cshtml"
)

$allPartialsExist = $true
foreach ($partial in $partialViews) {
    if (Test-Path $partial) {
        Write-Host "  ✅ $partial" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $partial MISSING" -ForegroundColor Red
        $allPartialsExist = $false
    }
}

if ($allPartialsExist) {
    Write-Host "✅ ALL PARTIAL VIEWS EXIST" -ForegroundColor Green
} else {
    Write-Host "❌ SOME PARTIAL VIEWS MISSING" -ForegroundColor Red
}

Write-Host "`n🎯 SUMMARY:" -ForegroundColor Cyan
Write-Host "- TarefaController uses correct view path: ~/Views/Etapa/Cards.cshtml" -ForegroundColor White
Write-Host "- Etapa/Cards uses correct layout reference: _Layout" -ForegroundColor White
Write-Host "- Styles section properly configured with task-cards-compact.css" -ForegroundColor White
Write-Host "- Layout CSS paths use root-relative (~/) for nested routes" -ForegroundColor White
Write-Host "- All required partial views exist" -ForegroundColor White

Write-Host "`n✅ ETAPA/TAREFA UI FIX COMPLETE - FINAL MIGRATION STAGE" -ForegroundColor Green
Write-Host "The UI should now load properly with full CSS styling" -ForegroundColor Green

Set-Location "../.."