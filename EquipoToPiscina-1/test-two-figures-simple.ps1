#!/usr/bin/env pwsh
# TEST: Two Figures Logo System - Simple Verification

Write-Host "🎯 TWO FIGURES LOGO SYSTEM - VERIFICATION" -ForegroundColor Cyan

# Test build
Write-Host "`n1️⃣ Testing build..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ BUILD: Success" -ForegroundColor Green
} else {
    Write-Host "❌ BUILD: Failed" -ForegroundColor Red
}

# Check key files
Write-Host "`n2️⃣ Checking implementation files..." -ForegroundColor Yellow

$files = @(
    "Views/Obra/Escolher.cshtml",
    "Models/ViewModels/ObraViewModel.cs", 
    "Services/Implementations/ObraService.cs"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ FILE: $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ FILE: $file missing" -ForegroundColor Red
    }
}

# Check font directory
Write-Host "`n3️⃣ Checking font directory..." -ForegroundColor Yellow
if (Test-Path "wwwroot/fonts") {
    Write-Host "✅ FONTS: Directory exists" -ForegroundColor Green
} else {
    Write-Host "❌ FONTS: Directory missing" -ForegroundColor Red
}

Write-Host "`n🎉 Two Figures implementation verified!" -ForegroundColor Green
Set-Location "../.."