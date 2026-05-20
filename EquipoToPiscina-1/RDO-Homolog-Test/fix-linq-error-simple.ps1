Write-Host "=== ERRO LINQ TO ENTITIES CORRIGIDO ===" -ForegroundColor Green

Write-Host "PROBLEMA:" -ForegroundColor Yellow
Write-Host "- Erro: The specified type member Date is not supported in LINQ to Entities" -ForegroundColor Red

Write-Host "SOLUCAO:" -ForegroundColor Yellow  
Write-Host "- Substituido .Date por DbFunctions.TruncateTime" -ForegroundColor Green
Write-Host "- Arquivo: TarefaModel.cs metodo SalvarLaudo" -ForegroundColor Green

Write-Host "TESTE AGORA:" -ForegroundColor Cyan
Write-Host "1. Recompilar no Visual Studio" -ForegroundColor White
Write-Host "2. Testar salvamento do laudo" -ForegroundColor White
Write-Host "3. Verificar console F12 sem erros" -ForegroundColor White