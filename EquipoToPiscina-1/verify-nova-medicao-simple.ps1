#!/usr/bin/env pwsh
# Simple Nova Medição verification

Write-Host "NOVA MEDICAO VERIFICATION" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Check compilation
Write-Host "Checking compilation..." -ForegroundColor Yellow
$build = dotnet build --no-restore --verbosity quiet
if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS: Compilation passed" -ForegroundColor Green
} else {
    Write-Host "FAILED: Compilation failed" -ForegroundColor Red
}

# Check key files
Write-Host "`nChecking key files..." -ForegroundColor Yellow

if (Test-Path "Views/Etapa/Cards.cshtml") {
    Write-Host "SUCCESS: Cards.cshtml exists" -ForegroundColor Green
} else {
    Write-Host "FAILED: Cards.cshtml missing" -ForegroundColor Red
}

if (Test-Path "Views/Etapa/_NovaMedicaoModal.cshtml") {
    Write-Host "SUCCESS: NovaMedicaoModal exists" -ForegroundColor Green
} else {
    Write-Host "FAILED: NovaMedicaoModal missing" -ForegroundColor Red
}

if (Test-Path "Components/TaskCard.razor") {
    Write-Host "SUCCESS: TaskCard.razor exists" -ForegroundColor Green
} else {
    Write-Host "FAILED: TaskCard.razor missing" -ForegroundColor Red
}

if (Test-Path "Controllers/TarefaController.cs") {
    Write-Host "SUCCESS: TarefaController exists" -ForegroundColor Green
} else {
    Write-Host "FAILED: TarefaController missing" -ForegroundColor Red
}

if (Test-Path "Models/ViewModels/NovaMedicaoViewModel.cs") {
    Write-Host "SUCCESS: NovaMedicaoViewModel exists" -ForegroundColor Green
} else {
    Write-Host "FAILED: NovaMedicaoViewModel missing" -ForegroundColor Red
}

Write-Host "`nVerification complete!" -ForegroundColor Cyan

Set-Location "../.."