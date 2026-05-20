#!/usr/bin/env pwsh

Write-Host "=== RESTORING WORKING STATE ===" -ForegroundColor Green

# Stop any running processes
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# 1. RESTORE ORIGINAL WORKING FILES FROM BACKUPS
Write-Host "`n=== RESTORING ORIGINAL WORKING FILES ===" -ForegroundColor Yellow

if (Test-Path "Views/Obra/Escolher.cshtml.backup") {
    Copy-Item "Views/Obra/Escolher.cshtml.backup" "Views/Obra/Escolher.cshtml" -Force
    Write-Host "✓ Restored original Escolher.cshtml" -ForegroundColor Green
} else {
    Write-Host "❌ Backup file not found: Views/Obra/Escolher.cshtml.backup" -ForegroundColor Red
}

if (Test-Path "Controllers/Api/ObraApiController.cs.backup") {
    Copy-Item "Controllers/Api/ObraApiController.cs.backup" "Controllers/Api/ObraApiController.cs" -Force
    Write-Host "✓ Restored original ObraApiController.cs" -ForegroundColor Green
} else {
    Write-Host "❌ Backup file not found: Controllers/Api/ObraApiController.cs.backup" -ForegroundColor Red
}

# 2. BUILD PROJECT
Write-Host "`n=== BUILDING PROJECT ===" -ForegroundColor Yellow
$buildResult = dotnet build --no-restore 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ BUILD SUCCESSFUL!" -ForegroundColor Green
    
    # 3. START APPLICATION
    Write-Host "`n=== STARTING APPLICATION ===" -ForegroundColor Green
    
    # Start in background
    Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory (Get-Location) -WindowStyle Hidden
    
    Write-Host "Application starting..." -ForegroundColor Yellow
    Start-Sleep -Seconds 8
    
    Write-Host "`n=== READY FOR USE ===" -ForegroundColor Green
    Write-Host "Login page: https://localhost:7139/Auth/Login" -ForegroundColor Cyan
    Write-Host "Credentials: ricardo / 123456" -ForegroundColor Yellow
    Write-Host "`nAfter login, you will be redirected to obra selection page" -ForegroundColor White
    
    # Open browser
    Start-Sleep -Seconds 2
    Start-Process "https://localhost:7139/Auth/Login"
    
    Write-Host "`n✓ Browser opened to login page" -ForegroundColor Green
    Write-Host "✓ Both login and obra escolher pages should now work" -ForegroundColor Green
    
} else {
    Write-Host "❌ BUILD FAILED!" -ForegroundColor Red
    Write-Host "Build errors:" -ForegroundColor Yellow
    Write-Host $buildResult -ForegroundColor Red
}

# Return to root directory
Set-Location "../.."
Write-Host "`nReturned to root directory: $(Get-Location)" -ForegroundColor Yellow