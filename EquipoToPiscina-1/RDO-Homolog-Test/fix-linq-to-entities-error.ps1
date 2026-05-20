Write-Host "=== CORRIGINDO ERRO LINQ TO ENTITIES ===" -ForegroundColor Green

Write-Host "PROBLEMA IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "- Erro: 'The specified type member Date is not supported in LINQ to Entities'" -ForegroundColor Red
Write-Host "- Causa: Uso de .Date em query LINQ to Entities" -ForegroundColor Red
Write-Host "- Local: Metodo SalvarLaudo em TarefaModel.cs" -ForegroundColor Red

Write-Host ""
Write-Host "SOLUCAO APLICADA:" -ForegroundColor Yellow
Write-Host "✓ Substituido x.lau_dt_laudo.Date == dataLaudo.Date" -ForegroundColor Green
Write-Host "✓ Por: DbFunctions.TruncateTime(x.lau_dt_laudo) == dataLaudo" -ForegroundColor Green
Write-Host "✓ Movido .Date para fora da query (dataLaudo = dataLaudo.Date)" -ForegroundColor Green

Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. Recompilar a aplicacao no Visual Studio" -ForegroundColor White
Write-Host "2. Testar novamente o salvamento do laudo" -ForegroundColor White
Write-Host "3. Verificar se o erro desapareceu no console F12" -ForegroundColor White

Write-Host ""
Write-Host "COMO TESTAR:" -ForegroundColor Yellow
Write-Host "1. Abrir F12 > Console" -ForegroundColor White
Write-Host "2. Preencher formulario de laudo" -ForegroundColor White
Write-Host "3. Clicar em Salvar" -ForegroundColor White
Write-Host "4. Verificar se aparece Laudo salvo com sucesso sem erros" -ForegroundColor White