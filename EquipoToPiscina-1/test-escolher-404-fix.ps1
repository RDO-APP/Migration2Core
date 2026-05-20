# TEST ESCOLHER 404 FIX
# Verifies that all asset files exist and Escolher.cshtml is clean

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER 404 FIX - VERIFICATION TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verify Asset Files Exist
Write-Host "TEST 1: Asset Files Verification" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

$assets = @(
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css"; Name = "fontello.css" },
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"; Name = "escolher-legacy.css" },
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff2"; Name = "fontello.woff2" },
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.woff"; Name = "fontello.woff" },
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/fonts/fontello.ttf"; Name = "fontello.ttf" },
    @{ Path = "RDO-NET8-Migration/RdoApp.Core/wwwroot/Assets/images/user.png"; Name = "user.png" }
)

$allAssetsExist = $true
foreach ($asset in $assets) {
    if (Test-Path $asset.Path) {
        $size = (Get-Item $asset.Path).Length
        Write-Host "  OK: $($asset.Name) ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: $($asset.Name) NOT FOUND" -ForegroundColor Red
        $allAssetsExist = $false
    }
}

Write-Host ""

# Test 2: Verify Escolher.cshtml Structure
Write-Host "TEST 2: Escolher.cshtml Structure" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

$escolherPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
if (Test-Path $escolherPath) {
    $content = Get-Content $escolherPath -Raw
    
    # Check for Layout = null
    if ($content -match 'Layout\s*=\s*null') {
        Write-Host "  OK: Layout = null (No layout inheritance)" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: Layout = null NOT FOUND" -ForegroundColor Red
    }
    
    # Check for asp-append-version on fontello.css
    if ($content -match 'fontello\.css.*asp-append-version="true"') {
        Write-Host "  OK: fontello.css has asp-append-version" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: fontello.css missing asp-append-version" -ForegroundColor Red
    }
    
    # Check for asp-append-version on escolher-legacy.css
    if ($content -match 'escolher-legacy\.css.*asp-append-version="true"') {
        Write-Host "  OK: escolher-legacy.css has asp-append-version" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: escolher-legacy.css missing asp-append-version" -ForegroundColor Red
    }
    
    # Check for AntiForgeryToken
    if ($content -match '@Html\.AntiForgeryToken\(\)') {
        Write-Host "  OK: @Html.AntiForgeryToken() present" -ForegroundColor Green
    } else {
        Write-Host "  FAIL: @Html.AntiForgeryToken() missing" -ForegroundColor Red
    }
    
    # Check that UnifiedRdoHeader is NOT present
    if ($content -match 'UnifiedRdoHeader') {
        Write-Host "  FAIL: UnifiedRdoHeader component found (should NOT be present)" -ForegroundColor Red
    } else {
        Write-Host "  OK: NO UnifiedRdoHeader component (clean)" -ForegroundColor Green
    }
    
    # Check that rdo-unified-theme.css is NOT present
    if ($content -match 'rdo-unified-theme\.css') {
        Write-Host "  FAIL: rdo-unified-theme.css found (should NOT be present)" -ForegroundColor Red
    } else {
        Write-Host "  OK: NO rdo-unified-theme.css (clean)" -ForegroundColor Green
    }
    
} else {
    Write-Host "  FAIL: Escolher.cshtml NOT FOUND" -ForegroundColor Red
}

Write-Host ""

# Test 3: Verify Quarantine Folder
Write-Host "TEST 3: Quarantine Folder Verification" -ForegroundColor Yellow
Write-Host "-----------------------------------" -ForegroundColor Yellow

$backupFolder = "RDO-NET8-Migration/RdoApp.Core/_BACKUP_ESCOLHER_CONSOLIDATION_20260118-220352"
if (Test-Path $backupFolder) {
    Write-Host "  OK: Quarantine folder exists" -ForegroundColor Green
    
    $quarantinedFiles = Get-ChildItem $backupFolder -File
    Write-Host "  OK: $($quarantinedFiles.Count) files quarantined" -ForegroundColor Green
    
    # List quarantined files
    foreach ($file in $quarantinedFiles) {
        Write-Host "    - $($file.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "  FAIL: Quarantine folder NOT FOUND" -ForegroundColor Red
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($allAssetsExist) {
    Write-Host "All asset files exist - NO 404 errors expected" -ForegroundColor Green
} else {
    Write-Host "Some asset files missing - 404 errors will occur" -ForegroundColor Red
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "2. Hard refresh (Ctrl+F5)" -ForegroundColor White
Write-Host "3. Navigate to /Obra/Escolher" -ForegroundColor White
Write-Host "4. Open F12 Console and check for errors" -ForegroundColor White
Write-Host "5. Open F12 Network tab and verify CSS files load (Status 200)" -ForegroundColor White
Write-Host ""
Write-Host "EXPECTED BEHAVIOR:" -ForegroundColor Yellow
Write-Host "- NO header on Escolher page (Layout = null)" -ForegroundColor White
Write-Host "- 103 obra cards in grid layout" -ForegroundColor White
Write-Host "- Icons display correctly" -ForegroundColor White
Write-Host "- Progress bars show colors" -ForegroundColor White
Write-Host "- NO 404 errors in console" -ForegroundColor White
Write-Host ""
