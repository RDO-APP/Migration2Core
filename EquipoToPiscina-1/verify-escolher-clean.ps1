# Verify Escolher.cshtml is Clean
# Quick verification that the debug box is not in the source file

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER.CSHTML FILE VERIFICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$filePath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"

# Check if file exists
if (-not (Test-Path $filePath)) {
    Write-Host "✗ ERROR: File not found!" -ForegroundColor Red
    Write-Host "Path: $filePath" -ForegroundColor Red
    exit 1
}

Write-Host "✓ File exists" -ForegroundColor Green
Write-Host ""

# Read file content
$content = Get-Content $filePath -Raw

# Check for debug box indicators
$debugPatterns = @(
    "DEBUG INFO",
    "debug-info",
    "Model count:",
    "View rendering:",
    "Layout = null"
)

$foundIssues = $false

Write-Host "Checking for debug box patterns..." -ForegroundColor Yellow
Write-Host ""

foreach ($pattern in $debugPatterns) {
    $escapedPattern = [regex]::Escape($pattern)
    if ($content -match $escapedPattern) {
        Write-Host "X FOUND: '$pattern'" -ForegroundColor Red
        $foundIssues = $true
    } else {
        Write-Host "OK Clean: '$pattern' not found" -ForegroundColor Green
    }
}

Write-Host ""

# Check for correct layout
if ($content -match 'Layout = "~/Views/Shared/_Layout.cshtml"') {
    Write-Host "✓ Correct layout specified" -ForegroundColor Green
} else {
    Write-Host "✗ WARNING: Layout not correctly specified" -ForegroundColor Yellow
}

Write-Host ""

# Final verdict
if ($foundIssues) {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "✗ FILE HAS ISSUES - DEBUG BOX FOUND!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
} else {
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ FILE IS CLEAN - NO DEBUG BOX!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "The file is correct. If you still see the debug box," -ForegroundColor White
    Write-Host "it's a caching issue. Make sure to:" -ForegroundColor White
    Write-Host "1. Use INCOGNITO browser mode" -ForegroundColor Yellow
    Write-Host "2. Press Ctrl+F5 to force refresh" -ForegroundColor Yellow
    Write-Host "3. Check you're on http://localhost:5031" -ForegroundColor Yellow
}
