#!/usr/bin/env pwsh

Write-Host "=== RESTORING WORKING ETAPA TAREFA PAGE - IMMEDIATE ACCESS ===" -ForegroundColor Green

# Stop any running processes
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# Restore the original working view from backup
if (Test-Path "Views/Obra/Escolher.cshtml.backup") {
    Copy-Item "Views/Obra/Escolher.cshtml.backup" "Views/Obra/Escolher.cshtml" -Force
    Write-Host "✓ Restored original working Escolher.cshtml from backup" -ForegroundColor Green
} else {
    Write-Host "⚠ No backup found, using current implementation" -ForegroundColor Yellow
}

# Build the project
Write-Host "`n=== BUILDING PROJECT ===" -ForegroundColor Yellow
dotnet build --no-restore 2>&1 | Tee-Object -Variable buildOutput

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ BUILD SUCCESSFUL!" -ForegroundColor Green
    
    # Start the application
    Write-Host "`n=== STARTING APPLICATION ===" -ForegroundColor Green
    Write-Host "Starting RdoApp.Core..." -ForegroundColor Yellow
    
    Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory (Get-Location) -WindowStyle Normal
    
    Start-Sleep -Seconds 5
    
    Write-Host "`n=== DIRECT ACCESS TO ETAPA TAREFA ===" -ForegroundColor Green
    Write-Host "Application is starting..." -ForegroundColor White
    Write-Host "`nTo access Etapa Tarefa page directly:" -ForegroundColor White
    Write-Host "1. Login with: ricardo / 123456" -ForegroundColor Yellow
    Write-Host "2. Go directly to: https://localhost:7139/Obra/Etapas/1" -ForegroundColor Yellow
    Write-Host "   (or any obra ID that exists in your database)" -ForegroundColor Yellow
    Write-Host "`nAlternatively:" -ForegroundColor White
    Write-Host "1. Login: https://localhost:7139/Auth/Login" -ForegroundColor Cyan
    Write-Host "2. Select any obra from the list" -ForegroundColor Cyan
    Write-Host "3. You'll be taken to Etapas/Tarefas page" -ForegroundColor Cyan
    
    Write-Host "`n=== OPENING BROWSER ===" -ForegroundColor Green
    Start-Sleep -Seconds 3
    Start-Process "https://localhost:7139/Auth/Login"
    
} else {
    Write-Host "❌ BUILD FAILED!" -ForegroundColor Red
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Red
}

# Return to root directory
Set-Location "../.."
Write-Host "`nReturned to root directory: $(Get-Location)" -ForegroundColor Yellow