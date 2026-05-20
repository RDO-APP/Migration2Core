Write-Host "=== INVESTIGAÇÃO: ERRO LAUDO BACKEND DETALHADO ===" -ForegroundColor Red

Write-Host ""
Write-Host "ERRO IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "An error occurred while executing the command definition" -ForegroundColor Red
Write-Host "Este é um erro genérico de banco de dados." -ForegroundColor Red

Write-Host ""
Write-Host "LOGS DETALHADOS ADICIONADOS:" -ForegroundColor Green
Write-Host "✅ System.Diagnostics.Debug.WriteLine para parâmetros" -ForegroundColor White
Write-Host "✅ Log da exceção completa (Message + InnerException)" -ForegroundColor White
Write-Host "✅ Log do stack trace completo" -ForegroundColor White
Write-Host "✅ Log de cada etapa do salvamento" -ForegroundColor White

Write-Host ""
Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. RECOMPILAR O PROJETO:" -ForegroundColor Yellow
Write-Host "   - Pressione Ctrl+Shift+B no Visual Studio" -ForegroundColor White
Write-Host "   - Aguarde compilação completa" -ForegroundColor White

Write-Host ""
Write-Host "2. VERIFICAR OUTPUT WINDOW:" -ForegroundColor Yellow
Write-Host "   - No Visual Studio: View > Output" -ForegroundColor White
Write-Host "   - Selecione 'Debug' no dropdown" -ForegroundColor White
Write-Host "   - Limpe a janela (botão Clear)" -ForegroundColor White

Write-Host ""
Write-Host "3. TESTAR LAUDO NOVAMENTE:" -ForegroundColor Yellow
Write-Host "   - Atualize o navegador (Ctrl+F5)" -ForegroundColor White
Write-Host "   - Preencha dados do laudo" -ForegroundColor White
Write-Host "   - Clique em Salvar" -ForegroundColor White

Write-Host ""
Write-Host "4. VERIFICAR LOGS DETALHADOS:" -ForegroundColor Yellow
Write-Host "   - Output Window do Visual Studio" -ForegroundColor White
Write-Host "   - Procure por 'DEBUG SALVAR LAUDO'" -ForegroundColor White
Write-Host "   - Veja a exceção completa" -ForegroundColor White

Write-Host ""
Write-Host "5. VERIFICAR ESTRUTURA DO BANCO:" -ForegroundColor Yellow
Write-Host "   - Execute: verificar-estrutura-tabela-laudo.sql" -ForegroundColor White
Write-Host "   - Confirme se tabela laudo existe" -ForegroundColor White
Write-Host "   - Verifique se todos os campos existem" -ForegroundColor White

Write-Host ""
Write-Host "EXECUTE OS PASSOS E ME INFORME:" -ForegroundColor Green
Write-Host "A. Qual é a exceção completa no Output Window?" -ForegroundColor White
Write-Host "B. Qual é a InnerException?" -ForegroundColor White
Write-Host "C. A tabela laudo existe no banco?" -ForegroundColor White

Write-Host ""
Write-Host "COM ESSES LOGS VAMOS IDENTIFICAR A CAUSA EXATA!" -ForegroundColor Cyan