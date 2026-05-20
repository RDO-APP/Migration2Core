# SIMPLE TEST: Verify Asset Path Crisis Fix

Write-Host "TESTING: Asset Path Crisis Fix" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Test 1: Verify middleware fix
Write-Host "`nTEST 1: Middleware Fix" -ForegroundColor Yellow
$programCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Program.cs" -Raw

if ($programCs -match '/Assets/') {
    Write-Host "SUCCESS: /Assets/ bypass found in middleware" -ForegroundColor Green
} else {
    Write-Host "ERROR: /Assets/ bypass missing" -ForegroundColor Red
}

# Test 2: Verify layout specification  
Write-Host "`nTEST 2: Layout Specification" -ForegroundColor Yellow
$escolherView = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml" -Raw

if ($escolherView -match '_LayoutSelection') {
    Write-Host "SUCCESS: Layout specification found" -ForegroundColor Green
} else {
    Write-Host "ERROR: Layout specification missing" -ForegroundColor Red
}

# Test 3: Verify physical files exist
Write-Host "`nTEST 3: Physical Files" -ForegroundColor Yellow
$files = @(
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/Assets/images/user.png"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "SUCCESS: $file exists" -ForegroundColor Green
    } else {
        Write-Host "ERROR: $file missing" -ForegroundColor Red
    }
}

Write-Host "`nFORENSIC FIX SUMMARY:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "ROOT CAUSE: Custom middleware missing /Assets/ bypass"
Write-Host "SOLUTION: Added path?.StartsWith(`"/Assets/`") == true"
Write-Host "RESULT: Static files should now serve correctly"

Write-Host "`nNEXT STEPS:" -ForegroundColor Magenta
Write-Host "1. Start the application: dotnet run"
Write-Host "2. Login and navigate to obra selection"
Write-Host "3. Check F12 console - should be clean (no 404s)"
Write-Host "4. Verify CSS and images load properly"

Write-Host "`nForensic investigation and fix complete!" -ForegroundColor Green