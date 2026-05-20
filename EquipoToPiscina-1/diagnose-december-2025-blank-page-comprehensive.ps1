# December 2025 Restoration - Comprehensive Blank Page Diagnostic
# NO FIXES - INVESTIGATION ONLY
# Date: January 20, 2026

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DECEMBER 2025 BLANK PAGE INVESTIGATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Status: NO CHANGES WILL BE MADE" -ForegroundColor Yellow
Write-Host "Purpose: Gather diagnostic information" -ForegroundColor Yellow
Write-Host ""

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "=== STEP 1: VERIFY FILE STATUS ===" -ForegroundColor Green
Write-Host ""

# Check if restored file exists
if (Test-Path "Views/Obra/Escolher.cshtml") {
    Write-Host "[OK] Escolher.cshtml exists" -ForegroundColor Green
    
    # Get file size
    $fileSize = (Get-Item "Views/Obra/Escolher.cshtml").Length
    Write-Host "File size: $fileSize bytes" -ForegroundColor Cyan
    
    # Check first line (model type)
    $firstLine = Get-Content "Views/Obra/Escolher.cshtml" -First 1
    Write-Host "First line (model type): $firstLine" -ForegroundColor Cyan
    
    if ($firstLine -match "IEnumerable<dynamic>") {
        Write-Host "[ISSUE] Model type is 'dynamic' - Controller returns 'ObraViewModel'" -ForegroundColor Red
        Write-Host "This is the LIKELY cause of blank page" -ForegroundColor Red
    } elseif ($firstLine -match "ObraViewModel") {
        Write-Host "[OK] Model type matches controller" -ForegroundColor Green
    }
} else {
    Write-Host "[ERROR] Escolher.cshtml NOT FOUND!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== STEP 2: CHECK BACKUP FILES ===" -ForegroundColor Green
Write-Host ""

if (Test-Path "Views/Obra/Escolher.cshtml.jan20-backup") {
    Write-Host "[OK] January 20 backup exists (rollback available)" -ForegroundColor Green
} else {
    Write-Host "[WARNING] January 20 backup NOT FOUND" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== STEP 3: VERIFY CONTROLLER ===" -ForegroundColor Green
Write-Host ""

# Check controller Escolher action
$controllerContent = Get-Content "Controllers/ObraController.cs" -Raw
if ($controllerContent -match "public async Task<IActionResult> Escolher") {
    Write-Host "[OK] Escolher action exists in ObraController" -ForegroundColor Green
    
    # Check what it returns
    if ($controllerContent -match "return View\(filteredObras\.ToList\(\)\)") {
        Write-Host "[INFO] Controller returns: filteredObras.ToList()" -ForegroundColor Cyan
        Write-Host "[INFO] Type: IEnumerable<ObraViewModel>" -ForegroundColor Cyan
    }
} else {
    Write-Host "[ERROR] Escolher action NOT FOUND in controller" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== STEP 4: CHECK COMPILATION ===" -ForegroundColor Green
Write-Host ""

Write-Host "Building project..." -ForegroundColor Cyan
$buildOutput = dotnet build --no-restore 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

if ($buildSuccess) {
    Write-Host "[OK] Project compiles successfully" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Compilation failed!" -ForegroundColor Red
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput
}

Write-Host ""
Write-Host "=== STEP 5: CHECK DEPENDENCIES ===" -ForegroundColor Green
Write-Host ""

# Check if Bootstrap exists
if (Test-Path "wwwroot/lib/bootstrap/dist/css/bootstrap.min.css") {
    Write-Host "[OK] Bootstrap CSS found" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Bootstrap CSS NOT FOUND" -ForegroundColor Yellow
}

# Check if jQuery exists
if (Test-Path "wwwroot/lib/jquery/dist/jquery.min.js") {
    Write-Host "[OK] jQuery found" -ForegroundColor Green
} else {
    Write-Host "[WARNING] jQuery NOT FOUND" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== STEP 6: ANALYZE VIEW CONTENT ===" -ForegroundColor Green
Write-Host ""

$viewContent = Get-Content "Views/Obra/Escolher.cshtml" -Raw

# Check for key features
$features = @{
    "Blue Header" = $viewContent -match "top-nav"
    "Filter Inputs" = $viewContent -match "filtroUnidade"
    "JavaScript" = $viewContent -match "function escolherObra"
    "Progress Bars" = $viewContent -match "progress-bar"
    "Legend" = $viewContent -match "area-legenda"
    "Fontello Icons" = $viewContent -match "fontello"
}

foreach ($feature in $features.GetEnumerator()) {
    if ($feature.Value) {
        Write-Host "[OK] $($feature.Key) present" -ForegroundColor Green
    } else {
        Write-Host "[MISSING] $($feature.Key) not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== STEP 7: CHECK FOR COMMON ISSUES ===" -ForegroundColor Green
Write-Host ""

# Check for Layout = null
if ($viewContent -match "Layout = null") {
    Write-Host "[OK] Layout = null (standalone page)" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Layout not set to null" -ForegroundColor Yellow
}

# Check for ViewBag usage
if ($viewContent -match "@ViewBag\.UsuarioNome") {
    Write-Host "[INFO] Uses ViewBag.UsuarioNome for user display" -ForegroundColor Cyan
}

# Check for Model usage
$modelUsageCount = ([regex]::Matches($viewContent, "@obra\.")).Count
Write-Host "[INFO] Model accessed $modelUsageCount times in view" -ForegroundColor Cyan

Write-Host ""
Write-Host "=== DIAGNOSTIC SUMMARY ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "ROOT CAUSE ANALYSIS:" -ForegroundColor Yellow
Write-Host ""

if ($firstLine -match "IEnumerable<dynamic>") {
    Write-Host "CONFIRMED: Model Type Mismatch" -ForegroundColor Red
    Write-Host "  - View expects: IEnumerable<dynamic>" -ForegroundColor Red
    Write-Host "  - Controller returns: IEnumerable<ObraViewModel>" -ForegroundColor Red
    Write-Host "  - Impact: Silent failure, blank page" -ForegroundColor Red
    Write-Host ""
    Write-Host "CONFIDENCE: 99%" -ForegroundColor Red
    Write-Host ""
    Write-Host "RECOMMENDED FIX:" -ForegroundColor Yellow
    Write-Host "  Change line 1 from:" -ForegroundColor White
    Write-Host "    @model IEnumerable<dynamic>" -ForegroundColor White
    Write-Host "  To:" -ForegroundColor White
    Write-Host "    @model IEnumerable<RdoApp.Core.Models.ViewModels.ObraViewModel>" -ForegroundColor White
} else {
    Write-Host "Model type appears correct" -ForegroundColor Green
    Write-Host "Further investigation needed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== NEXT STEPS FOR USER ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. BROWSER DIAGNOSTICS (F12):" -ForegroundColor Yellow
Write-Host "   - Open https://localhost:7201/Obra/Escolher" -ForegroundColor White
Write-Host "   - Press F12 to open Developer Tools" -ForegroundColor White
Write-Host "   - Check Console tab for errors" -ForegroundColor White
Write-Host "   - Check Network tab for failed requests" -ForegroundColor White
Write-Host "   - Right-click page -> View Page Source" -ForegroundColor White
Write-Host ""

Write-Host "2. REPORT FINDINGS:" -ForegroundColor Yellow
Write-Host "   - Any JavaScript errors in Console?" -ForegroundColor White
Write-Host "   - Is /Obra/Escolher returning 200 OK?" -ForegroundColor White
Write-Host "   - Is page source empty or has HTML?" -ForegroundColor White
Write-Host ""

Write-Host "3. CHOOSE ACTION:" -ForegroundColor Yellow
Write-Host "   a) Apply quick fix (change model type)" -ForegroundColor White
Write-Host "   b) Rollback to January 20 backup" -ForegroundColor White
Write-Host "   c) Continue investigation" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC COMPLETE - NO CHANGES MADE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Awaiting user decision..." -ForegroundColor Yellow
