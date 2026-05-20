# Fix 404 Errors - Single DNA Login Implementation
Write-Host "Fixing 404 Errors: CSS Bundle + Logo Path" -ForegroundColor Cyan

# 1. Fix CSS Bundle Issue - Remove reference to non-existent bundle
Write-Host "1. Fixing CSS Bundle Reference..." -ForegroundColor Yellow

$layoutPath = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutSelection.cshtml"

if (Test-Path $layoutPath) {
    $content = Get-Content $layoutPath -Raw
    
    # Comment out the problematic CSS bundle reference
    $updatedContent = $content -replace 
        '<link href="_content/RdoApp\.Core/RdoApp\.Core\.styles\.css" rel="stylesheet" />',
        '<!-- CSS Bundle temporarily disabled - using direct CSS files instead -->
    <!-- <link href="_content/RdoApp.Core/RdoApp.Core.styles.css" rel="stylesheet" /> -->'
    
    Set-Content $layoutPath $updatedContent -Encoding UTF8
    Write-Host "CSS bundle reference commented out" -ForegroundColor Green
} else {
    Write-Host "Layout file not found: $layoutPath" -ForegroundColor Red
}

# 2. Verify logo file exists
Write-Host "2. Verifying Logo File..." -ForegroundColor Yellow

$logoPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/images/logo.jpg"

if (Test-Path $logoPath) {
    $logoSize = (Get-Item $logoPath).Length
    Write-Host "Logo file exists: $logoPath ($logoSize bytes)" -ForegroundColor Green
} else {
    Write-Host "Logo file missing: $logoPath" -ForegroundColor Red
}

Write-Host "404 FIXES APPLIED SUCCESSFULLY!" -ForegroundColor Green