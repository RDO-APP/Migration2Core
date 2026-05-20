# Test EtapaService with detailed debug logs
Write-Host "=== TESTING ETAPA SERVICE WITH DEBUG LOGS ===" -ForegroundColor Yellow

# Compile the project first
Write-Host "Compiling project..." -ForegroundColor Green
Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet build --no-restore

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilation successful!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "=== NEXT STEPS ===" -ForegroundColor Yellow
    Write-Host "1. Start the application (F5 in Visual Studio or 'dotnet run')" -ForegroundColor White
    Write-Host "2. Navigate to the etapas page" -ForegroundColor White
    Write-Host "3. Check the Console Output window in Visual Studio" -ForegroundColor White
    Write-Host "4. Look for [DEBUG] messages to see what's happening" -ForegroundColor White
    Write-Host ""
    Write-Host "Expected debug output:" -ForegroundColor Cyan
    Write-Host "- [DEBUG] Iniciando processamento de X etapas" -ForegroundColor Gray
    Write-Host "- [DEBUG] Processando Etapa ID: X, Descrição: Y" -ForegroundColor Gray
    Write-Host "- [DEBUG] Quantidade de tarefas na etapa: X" -ForegroundColor Gray
    Write-Host "- [DEBUG] Tarefas autorizadas para o usuário: X" -ForegroundColor Gray
    Write-Host "- [DEBUG] RESULTADO FINAL: X etapas no ViewModel" -ForegroundColor Gray
}
else {
    Write-Host "❌ Compilation failed!" -ForegroundColor Red
}

Set-Location "../.."

Write-Host ""
Write-Host "=== WHAT TO LOOK FOR ===" -ForegroundColor Yellow
Write-Host "If you see:" -ForegroundColor White
Write-Host "- 'Quantidade de tarefas na etapa: 0' -> Problem: No tasks loaded from database" -ForegroundColor Red
Write-Host "- 'Tarefas autorizadas para o usuário: 0' -> Problem: Authorization filtering too strict" -ForegroundColor Red
Write-Host "- 'RESULTADO FINAL: 0 etapas' -> Problem: No etapas being added to ViewModel" -ForegroundColor Red