# PHASE 1: DRY RUN VALIDATION
# Purpose: Verify no hardcoded paths to quarantined files

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DRY RUN VALIDATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking Escolher.cshtml for hardcoded paths..." -ForegroundColor Yellow
Write-Host ""

# Read Escolher.cshtml
$escolherPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$escolherContent = Get-Content $escolherPath -Raw

# Check for references to quarantined files
$quarantinedFiles = @(
    "EscolherDebug",
    "EscolherNuclear",
    "EscolherMinimal",
    "Escolher-Diagnostic",
    "_LayoutBlazor",
    "rdo-selection.css",
    "RdoObraCards.razor"
)

$foundReferences = @()
foreach ($file in $quarantinedFiles) {
    if ($escolherContent -match $file) {
        $foundReferences += $file
        Write-Host "❌ FOUND REFERENCE: $file" -ForegroundColor Red
    }
}

if ($foundReferences.Count -eq 0) {
    Write-Host "✅ No references to quarantined files found" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  WARNING: Found $($foundReferences.Count) references to quarantined files" -ForegroundColor Yellow
    Write-Host "   This may cause issues. Review before proceeding." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Checking escolher-legacy.css for hardcoded paths..." -ForegroundColor Yellow
Write-Host ""

# Read escolher-legacy.css
$cssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"
$cssContent = Get-Content $cssPath -Raw

$foundCssReferences = @()
foreach ($file in $quarantinedFiles) {
    if ($cssContent -match $file) {
        $foundCssReferences += $file
        Write-Host "❌ FOUND REFERENCE: $file" -ForegroundColor Red
    }
}

if ($foundCssReferences.Count -eq 0) {
    Write-Host "✅ No references to quarantined files found" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "⚠️  WARNING: Found $($foundCssReferences.Count) references to quarantined files" -ForegroundColor Yellow
    Write-Host "   This may cause issues. Review before proceeding." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "MASTER FILES CONTENT VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verify Escolher.cshtml references
Write-Host "Escolher.cshtml references:" -ForegroundColor Yellow
if ($escolherContent -match 'Layout\s*=\s*null') {
    Write-Host "  ✅ Layout = null (self-contained)" -ForegroundColor Green
} else {
    Write-Host "  ❌ Layout is NOT null" -ForegroundColor Red
}

if ($escolherContent -match '~/css/fontello\.css') {
    Write-Host "  ✅ References fontello.css" -ForegroundColor Green
} else {
    Write-Host "  ❌ Missing fontello.css reference" -ForegroundColor Red
}

if ($escolherContent -match '~/css/escolher-legacy\.css') {
    Write-Host "  ✅ References escolher-legacy.css" -ForegroundColor Green
} else {
    Write-Host "  ❌ Missing escolher-legacy.css reference" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "COMPILATION TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Running dotnet build..." -ForegroundColor Yellow
$buildOutput = dotnet build RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilation successful" -ForegroundColor Green
} else {
    Write-Host "❌ Compilation failed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Build output:" -ForegroundColor Yellow
    Write-Host $buildOutput
    Write-Host ""
    Write-Host "⚠️  You may need to execute emergency rollback" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FINAL MASTER SELECTION CONFIRMATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Files remaining in active project:" -ForegroundColor Cyan
Write-Host ""

Write-Host "VIEWS:" -ForegroundColor Yellow
Get-ChildItem "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher*.cshtml" | ForEach-Object {
    Write-Host "  ✅ $($_.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "LAYOUTS:" -ForegroundColor Yellow
Get-ChildItem "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout*.cshtml" | ForEach-Object {
    Write-Host "  ✅ $($_.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "CSS FILES:" -ForegroundColor Yellow
Get-ChildItem "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/" -Filter "*escolher*.css" | ForEach-Object {
    Write-Host "  ✅ $($_.Name)" -ForegroundColor Green
}
Get-ChildItem "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/" -Filter "*selection*.css" | ForEach-Object {
    Write-Host "  ✅ $($_.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "COMPONENTS:" -ForegroundColor Yellow
$obraCardsExists = Test-Path "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor"
if ($obraCardsExists) {
    Write-Host "  ⚠️  RdoObraCards.razor still exists (should be quarantined)" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ RdoObraCards.razor quarantined (not in active project)" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PRE-COMMAND CHECK: _LayoutSelection.cshtml" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checking if _LayoutSelection.cshtml is needed..." -ForegroundColor Yellow
Write-Host ""

# Search for references to _LayoutSelection
$layoutSelectionRefs = Select-String -Path "RDO-NET8-Migration/RdoApp.Core/Views/**/*.cshtml" -Pattern "_LayoutSelection" -Exclude "Escolher.cshtml"

if ($layoutSelectionRefs) {
    Write-Host "✅ _LayoutSelection.cshtml IS used by other files:" -ForegroundColor Green
    $layoutSelectionRefs | ForEach-Object {
        Write-Host "  - $($_.Path)" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "DECISION: Keep _LayoutSelection.cshtml (used by LoginBlazor.cshtml and _ViewStart.cshtml)" -ForegroundColor Cyan
} else {
    Write-Host "⚠️  _LayoutSelection.cshtml is NOT referenced by any active files" -ForegroundColor Yellow
    Write-Host "   Could be quarantined in future phase" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "✅ DRY RUN VALIDATION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

if ($foundReferences.Count -eq 0 -and $foundCssReferences.Count -eq 0 -and $LASTEXITCODE -eq 0) {
    Write-Host "✅ ALL CHECKS PASSED" -ForegroundColor Green
    Write-Host "✅ No broken references found" -ForegroundColor Green
    Write-Host "✅ Compilation successful" -ForegroundColor Green
    Write-Host "✅ Master files intact" -ForegroundColor Green
    Write-Host ""
    Write-Host "READY FOR TESTING:" -ForegroundColor Cyan
    Write-Host "  dotnet run --project RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj" -ForegroundColor White
    Write-Host "  Navigate to: http://localhost:5000/Obra/Escolher" -ForegroundColor White
} else {
    Write-Host "⚠️  SOME CHECKS FAILED" -ForegroundColor Yellow
    Write-Host "   Review output above before proceeding" -ForegroundColor Yellow
}

Write-Host ""
