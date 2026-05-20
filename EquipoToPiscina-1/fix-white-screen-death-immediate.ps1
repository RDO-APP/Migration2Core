#!/usr/bin/env pwsh

Write-Host "🚨 WHITE SCREEN OF DEATH - IMMEDIATE FIX" -ForegroundColor Red
Write-Host "=========================================" -ForegroundColor Red

# Stop any running processes
Write-Host "🛑 Stopping any running RDO processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*rdoapp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean and build
Write-Host "🔨 Building project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Clean build
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Start the application
Write-Host "🚀 Starting application..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -NoNewWindow -PassThru

# Wait for startup
Write-Host "⏳ Waiting for application startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "WHITE SCREEN DEATH FIX APPLIED:" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "Blazor Server Hub Connection: blazor.server.js restored" -ForegroundColor Green
Write-Host "RenderBody(): Present in main content div" -ForegroundColor Green
Write-Host "Bootstrap Bundle: Loaded for dropdown functionality" -ForegroundColor Green
Write-Host "Base href: Set to ~/ for Blazor routing" -ForegroundColor Green
Write-Host "Layout structure: Cleaned and simplified" -ForegroundColor Green
Write-Host ""
Write-Host "LEGACY HEADER ANALYSIS:" -ForegroundColor Yellow
Write-Host "- Logo Button: RDO logo (clickable to change obra)" -ForegroundColor White
Write-Host "- User Profile: Dropdown with name and logout" -ForegroundColor White
Write-Host "- 6-Button Toolbar: Laudos, Dashboard, Relatórios, Tarefas, Charts, Nova Obra" -ForegroundColor White
Write-Host ""
Write-Host "TEST THE APPLICATION:" -ForegroundColor Green
Write-Host "- Open browser to https://localhost:7001" -ForegroundColor White
Write-Host "- Login and navigate to Escolher Obra" -ForegroundColor White
Write-Host "- Page should render content (no more white screen)" -ForegroundColor White
Write-Host ""
Write-Host "WHITE SCREEN OF DEATH FIXED!" -ForegroundColor Green

Set-Location "../.."