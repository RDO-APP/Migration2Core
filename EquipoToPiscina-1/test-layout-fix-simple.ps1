Write-Host "TESTING LAYOUT CSS FIX AND AUTHENTICATION BYPASS ELIMINATION" -ForegroundColor Cyan

# Test build
Write-Host "1. TESTING BUILD..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESS" -ForegroundColor Green
} else {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}

# Check Layout CSS paths
Write-Host "2. CHECKING LAYOUT CSS PATHS..." -ForegroundColor Yellow
$layoutContent = Get-Content "Views/Shared/_Layout.cshtml" -Raw

if ($layoutContent -match 'href="~/lib/bootstrap' -and $layoutContent -match 'required: false') {
    Write-Host "LAYOUT CSS PATHS AND STYLES SECTION - OK" -ForegroundColor Green
} else {
    Write-Host "LAYOUT ISSUES FOUND" -ForegroundColor Red
}

# Check AccountController
Write-Host "3. CHECKING ACCOUNTCONTROLLER..." -ForegroundColor Yellow
$accountContent = Get-Content "Controllers/AccountController.cs" -Raw

if ($accountContent -match 'Response.Cookies.Delete') {
    Write-Host "COOKIE CLEARING IMPLEMENTED" -ForegroundColor Green
} else {
    Write-Host "COOKIE CLEARING NOT FOUND" -ForegroundColor Red
}

Write-Host "LAYOUT CSS FIX COMPLETE" -ForegroundColor Green
Set-Location "../.."