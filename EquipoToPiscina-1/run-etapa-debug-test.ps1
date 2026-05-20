# Run Etapa Debug Test - Simple Version
Write-Host "🔍 ETAPA DEBUG TEST - FINDING THE ISSUE" -ForegroundColor Yellow
Write-Host "=========================================" -ForegroundColor Yellow

Write-Host ""
Write-Host "📊 PROBLEM SUMMARY:" -ForegroundColor Cyan
Write-Host "- DBeaver shows: 4 etapas" -ForegroundColor White
Write-Host "- Website shows: 0 etapas" -ForegroundColor White
Write-Host "- Gemini sees: !e.Ativo filter on line 43" -ForegroundColor White
Write-Host "- Current code: NO !e.Ativo filter" -ForegroundColor White

Write-Host ""
Write-Host "🎯 WHAT WE'RE TESTING:" -ForegroundColor Green
Write-Host "1. How many etapas are found in database query" -ForegroundColor White
Write-Host "2. How many tasks each etapa has" -ForegroundColor White
Write-Host "3. How many tasks pass authorization filter" -ForegroundColor White
Write-Host "4. Final count in ViewModel" -ForegroundColor White

Write-Host ""
Write-Host "🚀 INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. I'll compile the project with debug logs" -ForegroundColor White
Write-Host "2. You need to:" -ForegroundColor White
Write-Host "   - Start Visual Studio" -ForegroundColor Gray
Write-Host "   - Press F5 to run the application" -ForegroundColor Gray
Write-Host "   - Login and navigate to an obra" -ForegroundColor Gray
Write-Host "   - Click on 'Etapas' or 'Etapas/Tarefas'" -ForegroundColor Gray
Write-Host "   - Check the Console Output in Visual Studio" -ForegroundColor Gray

Write-Host ""
Write-Host "📝 LOOK FOR THESE DEBUG MESSAGES:" -ForegroundColor Cyan
Write-Host "=== DEBUG EtapaService.ObterEtapasViewModelAsync ===" -ForegroundColor Gray
Write-Host "ObraId recebido: X" -ForegroundColor Gray
Write-Host "ColaboradorId recebido: X" -ForegroundColor Gray
Write-Host "Etapas encontradas no banco: X" -ForegroundColor Gray
Write-Host "=== RESULTADO FINAL: X etapas no ViewModel ===" -ForegroundColor Gray

Write-Host ""
Write-Host "Compiling project with debug logs..." -ForegroundColor Green
Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet build --no-restore

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilation successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 NOW RUN THE APPLICATION:" -ForegroundColor Yellow
    Write-Host "1. Open Visual Studio" -ForegroundColor White
    Write-Host "2. Open the RdoApp.Core project" -ForegroundColor White
    Write-Host "3. Press F5 to run" -ForegroundColor White
    Write-Host "4. Navigate to etapas page" -ForegroundColor White
    Write-Host "5. Check Console Output for debug messages" -ForegroundColor White
    Write-Host ""
    Write-Host "📋 REPORT BACK:" -ForegroundColor Cyan
    Write-Host "Tell me what you see in the debug output!" -ForegroundColor White
} else {
    Write-Host "❌ Compilation failed!" -ForegroundColor Red
}

Set-Location "../.."