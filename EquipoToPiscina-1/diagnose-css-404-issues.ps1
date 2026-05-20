Write-Host "DIAGNOSING CSS 404 ISSUES - DEEP ANALYSIS" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Test 1: Build
Write-Host "1. TESTING BUILD..." -ForegroundColor Yellow
$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESS" -ForegroundColor Green
} else {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}

# Test 2: Check middleware order
Write-Host "2. CHECKING MIDDLEWARE ORDER..." -ForegroundColor Yellow
$programContent = Get-Content "Program.cs" -Raw

if ($programContent -match 'app\.UseStaticFiles\(\);.*app\.UseRouting\(\);.*app\.UseAuthentication\(\);' -and
    $programContent -match 'path\?\.\StartsWith\("/css/"\)') {
    Write-Host "MIDDLEWARE ORDER - FIXED" -ForegroundColor Green
} else {
    Write-Host "MIDDLEWARE ORDER - ISSUE" -ForegroundColor Red
}

# Test 3: Check CSS file exists
Write-Host "3. CHECKING CSS FILES..." -ForegroundColor Yellow
$cssFiles = @(
    "wwwroot/css/site.css",
    "wwwroot/css/gilberto-style.css", 
    "wwwroot/css/task-cards-compact.css",
    "wwwroot/lib/bootstrap/dist/css/bootstrap.min.css"
)

foreach ($css in $cssFiles) {
    if (Test-Path $css) {
        Write-Host "  EXISTS: $css" -ForegroundColor Green
    } else {
        Write-Host "  MISSING: $css" -ForegroundColor Red
    }
}

# Test 4: Check layout force inject
Write-Host "4. CHECKING LAYOUT FORCE INJECT..." -ForegroundColor Yellow
$layoutContent = Get-Content "Views/Shared/_Layout.cshtml" -Raw

if ($layoutContent -match 'EMERGENCY CSS INJECTION' -and 
    $layoutContent -match 'test-css-loaded') {
    Write-Host "FORCE INJECT CSS - ADDED" -ForegroundColor Green
} else {
    Write-Host "FORCE INJECT CSS - MISSING" -ForegroundColor Red
}

# Test 5: Check wwwroot structure
Write-Host "5. CHECKING WWWROOT STRUCTURE..." -ForegroundColor Yellow
if (Test-Path "wwwroot") {
    Write-Host "WWWROOT EXISTS" -ForegroundColor Green
    Get-ChildItem "wwwroot" -Recurse -Directory | ForEach-Object {
        Write-Host "  DIR: $($_.FullName.Replace((Get-Location).Path, ''))" -ForegroundColor Cyan
    }
} else {
    Write-Host "WWWROOT MISSING" -ForegroundColor Red
}

Write-Host "CSS 404 DIAGNOSIS COMPLETE" -ForegroundColor Green
Write-Host "Next: Test in browser and check Network tab for 404s" -ForegroundColor Yellow

Set-Location "../.."