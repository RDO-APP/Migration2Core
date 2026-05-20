#!/usr/bin/env pwsh
# LEGACY STANDARD COMPLETE TEST - 300x130px with Internal Row Fixes
# Tests both Null Safety Fix and Grid Layout Fix

Write-Host "=== LEGACY STANDARD COMPLETE TEST ===" -ForegroundColor Green
Write-Host "Testing: 300px x 130px cards with internal row containment" -ForegroundColor Yellow
Write-Host "Features: Null Safety + CSS Grid Layout" -ForegroundColor Yellow

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. COMPILATION TEST..." -ForegroundColor Cyan
$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ BUILD SUCCESS" -ForegroundColor Green
} else {
    Write-Host "❌ BUILD FAILED" -ForegroundColor Red
    Write-Host $buildResult
    exit 1
}

Write-Host "`n2. VERIFYING CSS GRID LAYOUT..." -ForegroundColor Cyan
$gridCss = Get-Content "wwwroot/css/task-cards-compact.css" -Raw
if ($gridCss -match "grid-template-columns: repeat\(auto-fill, 300px\)") {
    Write-Host "✅ CSS Grid: 300px columns configured" -ForegroundColor Green
} else {
    Write-Host "❌ CSS Grid: 300px columns NOT found" -ForegroundColor Red
}

if ($gridCss -match "gap: 15px") {
    Write-Host "✅ CSS Grid: 15px gap configured" -ForegroundColor Green
} else {
    Write-Host "❌ CSS Grid: 15px gap NOT found" -ForegroundColor Red
}

if ($gridCss -match "justify-content: center") {
    Write-Host "✅ CSS Grid: Center alignment configured" -ForegroundColor Green
} else {
    Write-Host "❌ CSS Grid: Center alignment NOT found" -ForegroundColor Red
}

Write-Host "`n3. VERIFYING LEGACY STANDARD DIMENSIONS..." -ForegroundColor Cyan
$cardCss = Get-Content "Components/TaskCard.razor.css" -Raw
if ($cardCss -match "width: 300px !important") {
    Write-Host "✅ TaskCard: 300px width locked" -ForegroundColor Green
} else {
    Write-Host "❌ TaskCard: 300px width NOT locked" -ForegroundColor Red
}

if ($cardCss -match "height: 130px !important") {
    Write-Host "✅ TaskCard: 130px height locked" -ForegroundColor Green
} else {
    Write-Host "❌ TaskCard: 130px height NOT locked" -ForegroundColor Red
}

Write-Host "`n4. VERIFYING INTERNAL ROW CONTAINMENT..." -ForegroundColor Cyan
if ($cardCss -match "max-width: 284px !important") {
    Write-Host "✅ Internal Rows: 284px max-width containment" -ForegroundColor Green
} else {
    Write-Host "❌ Internal Rows: 284px containment NOT found" -ForegroundColor Red
}

if ($cardCss -match "max-width: 268px !important") {
    Write-Host "✅ Progress Bar: 268px max-width containment" -ForegroundColor Green
} else {
    Write-Host "❌ Progress Bar: 268px containment NOT found" -ForegroundColor Red
}

Write-Host "`n5. VERIFYING NULL SAFETY IMPLEMENTATION..." -ForegroundColor Cyan
$viewModel = Get-Content "Models/ViewModels/EtapaViewModel.cs" -Raw
if ($viewModel -match "ValidTarefas") {
    Write-Host "✅ EtapaViewModel: ValidTarefas property implemented" -ForegroundColor Green
} else {
    Write-Host "❌ EtapaViewModel: ValidTarefas property NOT found" -ForegroundColor Red
}

$accordionView = Get-Content "Views/Etapa/_EtapaAccordionPartial.cshtml" -Raw
if ($accordionView -match "Model\.ValidTarefas") {
    Write-Host "✅ Accordion View: Using ValidTarefas for null-safe iteration" -ForegroundColor Green
} else {
    Write-Host "❌ Accordion View: ValidTarefas NOT being used" -ForegroundColor Red
}

Write-Host "`n6. STARTING APPLICATION..." -ForegroundColor Cyan
Write-Host "Starting server on https://localhost:5001" -ForegroundColor Yellow
Write-Host "Test URL: https://localhost:5001/Etapa/Cards" -ForegroundColor Yellow
Write-Host "" -ForegroundColor Yellow
Write-Host "EXPECTED RESULTS:" -ForegroundColor Magenta
Write-Host "- Cards should be exactly 300px x 130px" -ForegroundColor White
Write-Host "- Cards should be arranged in CSS Grid with 15px gaps" -ForegroundColor White
Write-Host "- Cards should be centered on the page" -ForegroundColor White
Write-Host "- No content should leak outside card boundaries" -ForegroundColor White
Write-Host "- No null reference errors in browser console" -ForegroundColor White
Write-Host "- Progress bars should stay within card width" -ForegroundColor White

# Start the application
dotnet run --urls="https://localhost:5001"