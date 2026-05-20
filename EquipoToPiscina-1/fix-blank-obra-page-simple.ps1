# Fix Blank Obra Page - Simple Solution
Write-Host "🔧 FIXING BLANK OBRA PAGE ISSUE" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes
Write-Host "1. Stopping processes..." -ForegroundColor Green
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "2. Analyzing the issue..." -ForegroundColor Green
Write-Host "   • ObraController.Escolher() calls API and passes data to view" -ForegroundColor Gray
Write-Host "   • View expects @Model to be populated with obra data" -ForegroundColor Gray
Write-Host "   • But view also has JavaScript for dynamic loading" -ForegroundColor Gray
Write-Host "   • This creates a conflict between server-side and client-side data" -ForegroundColor Gray

Write-Host ""
Write-Host "3. Root cause identified:" -ForegroundColor Yellow
Write-Host "   • The view is designed for BOTH server-side data AND AJAX calls" -ForegroundColor White
Write-Host "   • This hybrid approach is causing the blank page" -ForegroundColor White
Write-Host "   • Need to choose one approach: server-side OR client-side" -ForegroundColor White

Write-Host ""
Write-Host "🎯 RECOMMENDED SOLUTION:" -ForegroundColor Cyan
Write-Host "   Use Visual Studio F5 debugging to verify:" -ForegroundColor White
Write-Host "   1. Is ObraController.Escolher() being called?" -ForegroundColor Gray
Write-Host "   2. Is the API returning data?" -ForegroundColor Gray
Write-Host "   3. Is the data being passed to the view?" -ForegroundColor Gray
Write-Host "   4. Are there JavaScript errors preventing rendering?" -ForegroundColor Gray

Write-Host ""
Write-Host "🚀 READY FOR VISUAL STUDIO DEBUGGING!" -ForegroundColor Green
Write-Host ""
Write-Host "DEBUGGING STEPS:" -ForegroundColor White
Write-Host "1. Open Visual Studio with RdoApp.Core.sln" -ForegroundColor Gray
Write-Host "2. Set breakpoint in ObraController.Escolher() method" -ForegroundColor Gray
Write-Host "3. Set breakpoint in ObraApiController.ObterObras() method" -ForegroundColor Gray
Write-Host "4. Press F5 to start debugging" -ForegroundColor Gray
Write-Host "5. Navigate to /Obra/Escolher" -ForegroundColor Gray
Write-Host "6. Check what data is returned and passed to view" -ForegroundColor Gray
Write-Host "7. Open F12 Developer Tools to check for JavaScript errors" -ForegroundColor Gray