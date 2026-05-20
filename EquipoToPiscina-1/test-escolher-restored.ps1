# TEST ESCOLHER OBRA - AFTER FILE RESTORATION
# Quick verification that the fix worked

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ESCOLHER OBRA - FILE RESTORATION TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "ROOT CAUSE FOUND:" -ForegroundColor Green
Write-Host "- Escolher.cshtml was EMPTY (0 KB)" -ForegroundColor Yellow
Write-Host "- File has been RESTORED (5.12 KB)" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FILE VERIFICATION:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check all view files
$files = @(
    @{Path="RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"; Expected=5},
    @{Path="RDO-NET8-Migration/RdoApp.Core/Views/Obra/EscolherNuclear.cshtml"; Expected=4},
    @{Path="RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css"; Expected=4}
)

foreach ($file in $files) {
    if (Test-Path $file.Path) {
        $item = Get-Item $file.Path
        $sizeKB = [math]::Round($item.Length / 1KB, 2)
        
        if ($sizeKB -ge $file.Expected) {
            Write-Host "✅ $($file.Path)" -ForegroundColor Green
            Write-Host "   Size: $sizeKB KB (Expected: >= $($file.Expected) KB)" -ForegroundColor Gray
        } else {
            Write-Host "⚠️  $($file.Path)" -ForegroundColor Yellow
            Write-Host "   Size: $sizeKB KB (Expected: >= $($file.Expected) KB)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ $($file.Path) - NOT FOUND" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. START THE APPLICATION" -ForegroundColor Green
Write-Host "   - Open Visual Studio" -ForegroundColor White
Write-Host "   - Press F5 to run" -ForegroundColor White
Write-Host "   - OR run: dotnet run --project RDO-NET8-Migration/RdoApp.Core" -ForegroundColor Gray
Write-Host ""

Write-Host "2. LOGIN" -ForegroundColor Green
Write-Host "   - Navigate to: https://localhost:7201/Account/Login" -ForegroundColor White
Write-Host "   - Username: ricardo" -ForegroundColor Cyan
Write-Host "   - Password: senha123" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. TEST ESCOLHER PAGE" -ForegroundColor Green
Write-Host "   - After login, you should be redirected to /Obra/Escolher" -ForegroundColor White
Write-Host "   - OR manually navigate to: https://localhost:7201/Obra/Escolher" -ForegroundColor White
Write-Host ""

Write-Host "4. VERIFY DISPLAY" -ForegroundColor Green
Write-Host "   Expected to see:" -ForegroundColor White
Write-Host "   ✅ Yellow debug info box at top" -ForegroundColor Cyan
Write-Host "   ✅ 'Model count: 103' in debug info" -ForegroundColor Cyan
Write-Host "   ✅ Title: 'Selecione uma das unidades escolares abaixo:'" -ForegroundColor Cyan
Write-Host "   ✅ Grid of obra cards (4 per row)" -ForegroundColor Cyan
Write-Host "   ✅ Each card with icon, title, location, progress bar" -ForegroundColor Cyan
Write-Host "   ✅ Legend section at bottom" -ForegroundColor Cyan
Write-Host ""

Write-Host "5. TEST FUNCTIONALITY" -ForegroundColor Green
Write-Host "   - Click on any obra card" -ForegroundColor White
Write-Host "   - Should navigate to /Etapa/Cards" -ForegroundColor White
Write-Host "   - Should show task cards for selected obra" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TROUBLESHOOTING:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "IF PAGE IS STILL BLANK:" -ForegroundColor Yellow
Write-Host "1. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "2. Hard refresh (Ctrl+Shift+R)" -ForegroundColor White
Write-Host "3. Try incognito/private mode" -ForegroundColor White
Write-Host "4. Check F12 Console for errors" -ForegroundColor White
Write-Host "5. Check F12 Network tab for 404 errors" -ForegroundColor White
Write-Host ""

Write-Host "IF OBRA CARDS DON'T DISPLAY:" -ForegroundColor Yellow
Write-Host "1. Check backend logs for 'Filtered to X obras'" -ForegroundColor White
Write-Host "2. Verify escolher-legacy.css is loading (F12 Network tab)" -ForegroundColor White
Write-Host "3. Check if debug info shows 'Model count: 103'" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "READY TO TEST!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "The file has been restored and should now work correctly." -ForegroundColor Yellow
Write-Host "Run the application and test the page!" -ForegroundColor Yellow
Write-Host ""
