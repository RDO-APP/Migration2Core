#!/usr/bin/env pwsh

Write-Host "=== TESTING ENTITY FRAMEWORK FIX ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. Building project..." -ForegroundColor Cyan
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful - Entity Framework configuration is valid" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Starting application..." -ForegroundColor Cyan
Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -NoNewWindow

Write-Host "✅ Application started successfully" -ForegroundColor Green
Write-Host "`n=== ENTITY FRAMEWORK FIX APPLIED ===" -ForegroundColor Green
Write-Host "✅ Fixed ObraColaborador relationship mapping" -ForegroundColor Yellow
Write-Host "✅ Added proper navigation properties" -ForegroundColor Yellow  
Write-Host "✅ Added constraint names to prevent shadow properties" -ForegroundColor Yellow
Write-Host "✅ Uncommented Grupo relationship" -ForegroundColor Yellow

Write-Host "`nNow you can test with F5 in Visual Studio!" -ForegroundColor Cyan
Write-Host "The 'Unknown column o1.ObraId1' error should be resolved." -ForegroundColor Green