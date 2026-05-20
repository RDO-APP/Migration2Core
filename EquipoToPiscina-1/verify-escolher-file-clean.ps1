# Verify Escolher.cshtml is clean (no debug box)

$file = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VERIFYING ESCOLHER.CSHTML FILE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if file exists
if (-not (Test-Path $file)) {
    Write-Host "✗ ERROR: File not found!" -ForegroundColor Red
    Write-Host "Path: $file" -ForegroundColor Red
    exit 1
}

Write-Host "✓ File exists" -ForegroundColor Green
Write-Host ""

# Read file content
$content = Get-Content $file -Raw

# Check for debug box indicators
$debugPatterns = @(
    "DEBUG INFO",
    "debug-info",
    "Model count:",
    "View rendering:",
    "Layout = null"
)

$foundIssues = @()

foreach ($pattern in $debugPatterns) {
    if ($content -match [regex]::Escape($pattern)) {
        $foundIssues += $pattern
    }
}

if ($foundIssues.Count -gt 0) {
    Write-Host "✗ PROBLEM FOUND: File contains debug code!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Found these patterns:" -ForegroundColor Yellow
    foreach ($issue in $foundIssues) {
        Write-Host "  - $issue" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "The file needs to be fixed again!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✓ File is CLEAN (no debug box)" -ForegroundColor Green
    Write-Host ""
    Write-Host "File should contain:" -ForegroundColor White
    Write-Host "  - Layout = '~/Views/Shared/_Layout.cshtml'" -ForegroundColor Gray
    Write-Host "  - ViewBag.IsObraSelection = true" -ForegroundColor Gray
    Write-Host "  - Obra cards rendering" -ForegroundColor Gray
    Write-Host "  - Legend section" -ForegroundColor Gray
    Write-Host ""
    
    # Verify correct layout
    if ($content -match "Layout = `"~/Views/Shared/_Layout.cshtml`"") {
        Write-Host "✓ Correct layout specified" -ForegroundColor Green
    } else {
        Write-Host "✗ WARNING: Layout may not be correct" -ForegroundColor Yellow
    }
    
    # Verify ViewBag flags
    if ($content -match "ViewBag.IsObraSelection") {
        Write-Host "✓ ViewBag.IsObraSelection flag present" -ForegroundColor Green
    } else {
        Write-Host "✗ WARNING: ViewBag.IsObraSelection flag missing" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "FILE IS READY!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next step: Run FORCE-REBUILD-ESCOLHER-FIX.ps1" -ForegroundColor Yellow
}
