Write-Host "=== INVESTIGACAO ERRO LAUDO BACKEND ===" -ForegroundColor Red

Write-Host ""
Write-Host "ERRO IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "An error occurred while executing the command definition" -ForegroundColor Red

Write-Host ""
Write-Host "LOGS DETALHADOS ADICIONADOS:" -ForegroundColor Green
Write-Host "- System.Diagnostics.Debug.WriteLine para parametros" -ForegroundColor White
Write-Host "- Log da excecao completa (Message + InnerException)" -ForegroundColor White
Write-Host "- Log do stack trace completo" -ForegroundColor White
Write-Host "- Log de cada etapa do salvamento" -ForegroundColor White

Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. RECOMPILAR O PROJETO:" -ForegroundColor Yellow
Write-Host "   - Pressione Ctrl+Shift+B no Visual Studio" -ForegroundColor White

Write-Host ""
Write-Host "2. VERIFICAR OUTPUT WINDOW:" -ForegroundColor Yellow
Write-Host "   - No Visual Studio: View > Output" -ForegroundColor White
Write-Host "   - Selecione Debug no dropdown" -ForegroundColor White
Write-Host "   - Limpe a janela (botao Clear)" -ForegroundColor White

Write-Host ""
Write-Host "3. TESTAR LAUDO NOVAMENTE:" -ForegroundColor Yellow
Write-Host "   - Atualize o navegador (Ctrl+F5)" -ForegroundColor White
Write-Host "   - Preencha dados do laudo" -ForegroundColor White
Write-Host "   - Clique em Salvar" -ForegroundColor White

Write-Host ""
Write-Host "4. VERIFICAR LOGS DETALHADOS:" -ForegroundColor Yellow
Write-Host "   - Output Window do Visual Studio" -ForegroundColor White
Write-Host "   - Procure por DEBUG SALVAR LAUDO" -ForegroundColor White
Write-Host "   - Veja a excecao completa" -ForegroundColor White

Write-Host ""
Write-Host "EXECUTE OS PASSOS E ME INFORME:" -ForegroundColor Green
Write-Host "A. Qual e a excecao completa no Output Window?" -ForegroundColor White
Write-Host "B. Qual e a InnerException?" -ForegroundColor White
Write-Host "C. A tabela laudo existe no banco?" -ForegroundColor White

Write-Host ""
Write-Host "COM ESSES LOGS VAMOS IDENTIFICAR A CAUSA EXATA!" -ForegroundColor Cyan