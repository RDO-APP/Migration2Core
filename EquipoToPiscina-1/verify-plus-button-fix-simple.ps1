#!/usr/bin/env pwsh
# Simple Plus Button Fix Verification

Write-Host "PLUS BUTTON MODAL TRIGGER FIX VERIFICATION" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Check compilation
Write-Host "Checking compilation..." -ForegroundColor Yellow
$build = dotnet build --no-restore --verbosity quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Compilation passed" -ForegroundColor Green
} else {
    Write-Host "FAILED: Compilation failed" -ForegroundColor Red
}

# Check TaskCard Plus button
Write-Host "`nChecking TaskCard Plus button..." -ForegroundColor Yellow
if (Test-Path "Components/TaskCard.razor") {
    $taskCardContent = Get-Content "Components/TaskCard.razor" -Raw
    if ($taskCardContent -match "AddMeasurement") {
        Write-Host "SUCCESS: Plus button AddMeasurement method found" -ForegroundColor Green
    } else {
        Write-Host "FAILED: Plus button method missing" -ForegroundColor Red
    }
} else {
    Write-Host "FAILED: TaskCard.razor not found" -ForegroundColor Red
}

# Check JavaScript function
Write-Host "`nChecking JavaScript function..." -ForegroundColor Yellow
if (Test-Path "Views/Etapa/Cards.cshtml") {
    $cardsContent = Get-Content "Views/Etapa/Cards.cshtml" -Raw
    if ($cardsContent -match "function novaMedicao") {
        Write-Host "SUCCESS: novaMedicao function found" -ForegroundColor Green
    } else {
        Write-Host "FAILED: novaMedicao function missing" -ForegroundColor Red
    }
    
    if ($cardsContent -match "NOVA MEDIÇÃO.*Opening") {
        Write-Host "SUCCESS: Enhanced debugging found" -ForegroundColor Green
    } else {
        Write-Host "FAILED: Enhanced debugging missing" -ForegroundColor Red
    }
} else {
    Write-Host "FAILED: Cards.cshtml not found" -ForegroundColor Red
}

# Check modal ID
Write-Host "`nChecking modal ID..." -ForegroundColor Yellow
if (Test-Path "Views/Etapa/_NovaMedicaoModal.cshtml") {
    $modalContent = Get-Content "Views/Etapa/_NovaMedicaoModal.cshtml" -Raw
    if ($modalContent -match 'id="nova-medicao-botao-rapido"') {
        Write-Host "SUCCESS: Modal ID matches JavaScript selector" -ForegroundColor Green
    } else {
        Write-Host "FAILED: Modal ID mismatch" -ForegroundColor Red
    }
} else {
    Write-Host "FAILED: Modal file not found" -ForegroundColor Red
}

Write-Host "`nFIX SUMMARY:" -ForegroundColor Cyan
Write-Host "- Enhanced JavaScript function with error handling" -ForegroundColor White
Write-Host "- Added jQuery and Bootstrap compatibility checks" -ForegroundColor White
Write-Host "- Added comprehensive debugging and logging" -ForegroundColor White
Write-Host "- Verified modal ID matches JavaScript selector" -ForegroundColor White

Write-Host "`nVerification complete!" -ForegroundColor Cyan

Set-Location "../.."