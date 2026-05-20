#!/usr/bin/env pwsh

Write-Host "Testing Migration Inheritance Audit Fixes" -ForegroundColor Cyan

# Test 1: Check critical files exist
Write-Host "`nChecking critical library files..." -ForegroundColor Yellow

$files = @(
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/lib/datepicker/datepicker.js",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/lib/moment/moment.min.js",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/lib/jquery.maskMoney/jquery.maskMoney.min.js",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/js/bootstrap-compatibility.js"
)

$allExist = $true
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
        $allExist = $false
    }
}

# Test 2: Check layout has new scripts
Write-Host "`nChecking _Layout.cshtml..." -ForegroundColor Yellow

$layout = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml" -Raw

if ($layout -match "moment\.min\.js") {
    Write-Host "✅ moment.js included" -ForegroundColor Green
} else {
    Write-Host "❌ moment.js missing" -ForegroundColor Red
    $allExist = $false
}

if ($layout -match "datepicker\.js") {
    Write-Host "✅ datepicker.js included" -ForegroundColor Green
} else {
    Write-Host "❌ datepicker.js missing" -ForegroundColor Red
    $allExist = $false
}

if ($layout -match "bootstrap-compatibility\.js") {
    Write-Host "✅ bootstrap-compatibility.js included" -ForegroundColor Green
} else {
    Write-Host "❌ bootstrap-compatibility.js missing" -ForegroundColor Red
    $allExist = $false
}

# Test 3: Try to build
Write-Host "`nTesting compilation..." -ForegroundColor Yellow

try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    $result = dotnet build --no-restore 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project builds successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
        $allExist = $false
    }
} finally {
    Pop-Location
}

# Results
Write-Host "`nResults:" -ForegroundColor Cyan
if ($allExist) {
    Write-Host "✅ ALL TESTS PASSED - Dependencies restored!" -ForegroundColor Green
    Write-Host "The datepicker and modal issues should now be fixed." -ForegroundColor Green
} else {
    Write-Host "❌ Some tests failed - check issues above" -ForegroundColor Red
}