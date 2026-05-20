#!/usr/bin/env pwsh
# Simple High-Fidelity Login Test

Write-Host "TESTING HIGH-FIDELITY LOGIN IMPLEMENTATION" -ForegroundColor Cyan
Write-Host "=" * 50

# Test Build
Write-Host "`nTesting build compilation..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"
$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "BUILD: FAILED" -ForegroundColor Red
    exit 1
}

# Test Login File
Write-Host "`nTesting login file implementation..." -ForegroundColor Yellow
$loginFile = "Views/Account/Login.cshtml"

if (Test-Path $loginFile) {
    $content = Get-Content $loginFile -Raw
    
    # Check key implementations
    $checks = @{
        "Layout = null" = ($content -match 'Layout = null')
        "mix-blend-mode" = ($content -match 'mix-blend-mode: multiply')
        "password-toggle" = ($content -match 'password-toggle')
        "Bootstrap centering" = ($content -match 'd-flex justify-content-center')
        "No debug overlays" = ($content -notmatch 'Nuclear 2026 Active')
        "No AngularJS" = ($content -notmatch 'ng-')
    }
    
    foreach ($check in $checks.GetEnumerator()) {
        if ($check.Value) {
            Write-Host "PASS: $($check.Key)" -ForegroundColor Green
        } else {
            Write-Host "FAIL: $($check.Key)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "LOGIN FILE NOT FOUND" -ForegroundColor Red
    exit 1
}

# Test Logo
Write-Host "`nTesting logo file..." -ForegroundColor Yellow
$logoFile = "wwwroot/images/logo.jpg"
if (Test-Path $logoFile) {
    Write-Host "LOGO: Found" -ForegroundColor Green
} else {
    Write-Host "LOGO: Missing" -ForegroundColor Red
}

Write-Host "`n" + "=" * 50
Write-Host "HIGH-FIDELITY LOGIN TEST COMPLETE" -ForegroundColor Green
Write-Host "Open browser to: http://localhost:5031/Account/Login"