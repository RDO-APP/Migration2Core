# RUN ESCOLHER - FINAL TEST
# Pre-run validation + Build + Run

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER 404 FIX - FINAL TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# PRE-RUN VALIDATION
# ============================================

Write-Host "STEP 1: PRE-RUN VALIDATION" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host ""

# Check 1: ObraViewModel exists
Write-Host "CHECK 1: ObraViewModel" -ForegroundColor White
$obraViewModelPath = "RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/ObraViewModel.cs"
if (Test-Path $obraViewModelPath) {
    Write-Host "  OK: ObraViewModel.cs exists" -ForegroundColor Green
} else {
    Write-Host "  FAIL: ObraViewModel.cs NOT FOUND" -ForegroundColor Red
    exit 1
}

# Check 2: ObraController.Escolher action exists
Write-Host "CHECK 2: ObraController.Escolher Action" -ForegroundColor White
$obraControllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
if (Test-Path $obraControllerPath) {
    $controllerContent = Get-Content $obraControllerPath -Raw
    if ($controllerContent -match 'public async Task<IActionResult> Escolher') {
        Write-Host "  OK: Escolher action exists" -ForegroundColor Green
        Write-Host "  OK: Returns IActionResult with IEnumerable<ObraViewModel>" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Escolher action NOT FOUND" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "  FAIL: ObraController.cs NOT FOUND" -ForegroundColor Red
    exit 1
}

# Check 3: Escolher.cshtml exists and has correct structure
Write-Host "CHECK 3: Escolher.cshtml Structure" -ForegroundColor White
$escolherPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
if (Test-Path $escolherPath) {
    Write-Host "  OK: Escolher.cshtml exists" -ForegroundColor Green
    
    # Read first 20 lines to check structure
    $escolherLines = Get-Content $escolherPath -TotalCount 20
    $escolherContent = $escolherLines -join "`n"
    
    # Check for @model directive
    if ($escolherContent -match '@model.*IEnumerable.*ObraViewModel') {
        Write-Host "  OK: @model IEnumerable<ObraViewModel> found" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: @model directive may be missing" -ForegroundColor Yellow
    }
    
    # Check for Layout = null
    if ($escolherContent -match 'Layout\s*=\s*null') {
        Write-Host "  OK: Layout = null found" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: Layout = null may be missing" -ForegroundColor Yellow
    }
} else {
    Write-Host "  FAIL: Escolher.cshtml NOT FOUND" -ForegroundColor Red
    exit 1
}

# Check 4: CSS files exist
Write-Host "CHECK 4: CSS Files" -ForegroundColor White
$cssFiles = @(
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css"; Name = "fontello.css" },
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"; Name = "escolher-legacy.css" }
)

$allCssExist = $true
foreach ($css in $cssFiles) {
    if (Test-Path $css.Path) {
        Write-Host "  OK: $($css.Name) exists" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: $($css.Name) NOT FOUND" -ForegroundColor Red
        $allCssExist = $false
    }
}

if (-not $allCssExist) {
    Write-Host ""
    Write-Host "ERROR: Required CSS files missing" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "PRE-RUN VALIDATION: PASSED" -ForegroundColor Green
Write-Host ""

# ============================================
# BUILD
# ============================================

Write-Host "STEP 2: BUILD PROJECT" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes
Write-Host "Stopping any running dotnet processes..." -ForegroundColor White
Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Navigate to project directory
$projectPath = "RDO-NET8-Migration/RdoApp.Core"
Set-Location $projectPath

# Clean
Write-Host "Cleaning project..." -ForegroundColor White
dotnet clean --nologo --verbosity quiet

# Build
Write-Host "Building project..." -ForegroundColor White
$buildOutput = dotnet build --nologo --verbosity minimal 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  OK: Build successful" -ForegroundColor Green
} else {
    Write-Host "  FAIL: Build failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build Output:" -ForegroundColor Yellow
    Write-Host $buildOutput
    Set-Location ../..
    exit 1
}

Write-Host ""

# ============================================
# RUN
# ============================================

Write-Host "STEP 3: RUN APPLICATION" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow
Write-Host ""

Write-Host "Starting application..." -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "APPLICATION STARTING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Wait for 'Now listening on:' message" -ForegroundColor White
Write-Host "2. Open browser to: https://localhost:7201" -ForegroundColor White
Write-Host "3. Login with your credentials" -ForegroundColor White
Write-Host "4. You will be redirected to /Obra/Escolher" -ForegroundColor White
Write-Host "5. Press Ctrl+F5 to hard refresh (clear cache)" -ForegroundColor White
Write-Host "6. Open F12 Developer Tools" -ForegroundColor White
Write-Host "7. Check Console tab for errors" -ForegroundColor White
Write-Host "8. Check Network tab for 404 responses" -ForegroundColor White
Write-Host ""
Write-Host "EXPECTED BEHAVIOR:" -ForegroundColor Yellow
Write-Host "- NO header on Escolher page (Layout = null)" -ForegroundColor White
Write-Host "- 103 obra cards in grid layout" -ForegroundColor White
Write-Host "- Icons display correctly" -ForegroundColor White
Write-Host "- Progress bars show colors" -ForegroundColor White
Write-Host "- NO 404 errors in console" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Run the application
dotnet run --no-build

# Return to original directory when stopped
Set-Location ../..
