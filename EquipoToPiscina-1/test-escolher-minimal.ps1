# TEST ESCOLHER MINIMAL - Absolute simplest test
Write-Host "🔥 TESTING ESCOLHER MINIMAL VIEW" -ForegroundColor Red
Write-Host "=" * 80

Write-Host "`n📋 INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Make sure the server is running (dotnet run)" -ForegroundColor White
Write-Host "2. Open your browser" -ForegroundColor White
Write-Host "3. Go to: https://localhost:7201/Obra/EscolherMinimal" -ForegroundColor Cyan
Write-Host "`n4. You should see a YELLOW page with RED border" -ForegroundColor White
Write-Host "5. If you see the yellow page, the VIEW IS RENDERING" -ForegroundColor Green
Write-Host "6. If you see a blank page, the problem is in the BROWSER or MIDDLEWARE" -ForegroundColor Red

Write-Host "`n" + ("=" * 80)
Write-Host "🎯 WHAT TO CHECK:" -ForegroundColor Yellow
Write-Host "=" * 80

Write-Host "`nIF YOU SEE YELLOW PAGE:" -ForegroundColor Green
Write-Host "- View rendering works ✅" -ForegroundColor White
Write-Host "- Problem is in Escolher.cshtml CSS or layout" -ForegroundColor White
Write-Host "- Check F12 Console for JavaScript errors" -ForegroundColor White
Write-Host "- Check F12 Network for failed CSS loads" -ForegroundColor White

Write-Host "`nIF YOU SEE BLANK PAGE:" -ForegroundColor Red
Write-Host "- View rendering is blocked ❌" -ForegroundColor White
Write-Host "- Check F12 Console for errors" -ForegroundColor White
Write-Host "- Check F12 Network tab" -ForegroundColor White
Write-Host "- Check browser console logs" -ForegroundColor White
Write-Host "- Try different browser (Chrome, Edge, Firefox)" -ForegroundColor White

Write-Host "`n" + ("=" * 80)
Write-Host "Press any key to open browser..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Start-Process "https://localhost:7201/Obra/EscolherMinimal"
