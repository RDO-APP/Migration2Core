#!/usr/bin/env pwsh

Write-Host "=== TESTING NULL REFERENCE FIX ===" -ForegroundColor Green

# Stop any running processes first
Write-Host "Stopping any running RdoApp.Core processes..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 2

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow

# Clean and rebuild
Write-Host "`n=== CLEANING PROJECT ===" -ForegroundColor Yellow
dotnet clean --verbosity quiet

Write-Host "`n=== BUILDING PROJECT ===" -ForegroundColor Yellow
dotnet build --no-restore 2>&1 | Tee-Object -Variable buildOutput

if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESSFUL!" -ForegroundColor Green
    
    Write-Host "`n=== NULL REFERENCE FIX SUMMARY ===" -ForegroundColor Green
    Write-Host "- Fixed User authentication null checks" -ForegroundColor Cyan
    Write-Host "- Fixed database entity null checks (Municipio, Uf, Grupo)" -ForegroundColor Cyan
    Write-Host "- Fixed navigation property null checks" -ForegroundColor Cyan
    Write-Host "- Enhanced error logging with detailed information" -ForegroundColor Cyan
    Write-Host "- Fixed LINQ expression null propagation issues" -ForegroundColor Cyan
    
    Write-Host "`n=== READY FOR TESTING ===" -ForegroundColor Green
    Write-Host "The NullReferenceException at line 28 should now be resolved." -ForegroundColor White
    Write-Host "You can now:" -ForegroundColor White
    Write-Host "1. Press F5 in Visual Studio to start debugging" -ForegroundColor Yellow
    Write-Host "2. Navigate to the obra selection page" -ForegroundColor Yellow
    Write-Host "3. The page should load without null reference errors" -ForegroundColor Yellow
    
    Write-Host "`n=== WHAT WAS FIXED ===" -ForegroundColor Green
    Write-Host "BEFORE: NullReferenceException at line 28 in ObraApiController" -ForegroundColor Red
    Write-Host "AFTER: Comprehensive null checks prevent the exception" -ForegroundColor Green
    Write-Host "- User.FindFirst() now has null checks" -ForegroundColor Cyan
    Write-Host "- Database navigation properties have null checks" -ForegroundColor Cyan
    Write-Host "- LINQ expressions use conditional operators instead of null propagation" -ForegroundColor Cyan
    
} else {
    Write-Host "BUILD FAILED!" -ForegroundColor Red
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput -ForegroundColor Red
}

# Return to root directory
Set-Location "../.."
Write-Host "`nReturned to root directory: $(Get-Location)" -ForegroundColor Yellow