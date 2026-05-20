Write-Host "=== INVESTIGACAO DETALHADA DO ERRO DE LAUDO ===" -ForegroundColor Yellow

Write-Host "Os erros que voce viu sao de extensoes do navegador (normais)." -ForegroundColor Green
Write-Host "Precisamos ver erros especificos do laudo." -ForegroundColor Yellow

Write-Host ""
Write-Host "INVESTIGACAO MAIS PROFUNDA:" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. VERIFICAR ABA NETWORK (REDE):" -ForegroundColor Yellow
Write-Host "   - F12 > Network (ou Rede)" -ForegroundColor White
Write-Host "   - Limpar o log (botao clear)" -ForegroundColor White
Write-Host "   - Preencher formulario de laudo" -ForegroundColor White
Write-Host "   - Clicar em Salvar" -ForegroundColor White
Write-Host "   - Procurar por requisicao 'SalvarLaudo'" -ForegroundColor White
Write-Host "   - Ver se aparece erro 500, 404 ou outro" -ForegroundColor White

Write-Host ""
Write-Host "2. VERIFICAR SE O BOTAO ESTA FUNCIONANDO:" -ForegroundColor Yellow
Write-Host "   - F12 > Console" -ForegroundColor White
Write-Host "   - Digitar: console.log('teste')" -ForegroundColor White
Write-Host "   - Pressionar Enter (deve aparecer 'teste')" -ForegroundColor White
Write-Host "   - Clicar no botao Salvar" -ForegroundColor White
Write-Host "   - Ver se aparece alguma mensagem nova" -ForegroundColor White

Write-Host ""
Write-Host "3. VERIFICAR SE A APLICACAO FOI RECOMPILADA:" -ForegroundColor Red
Write-Host "   - CRITICO: A correcao LINQ to Entities precisa ser compilada!" -ForegroundColor Red
Write-Host "   - Abrir Visual Studio como Administrador" -ForegroundColor White
Write-Host "   - Build > Clean Solution" -ForegroundColor White
Write-Host "   - Build > Rebuild Solution" -ForegroundColor White
Write-Host "   - F5 para executar" -ForegroundColor White

Write-Host ""
Write-Host "4. TESTAR EM MODO INCOGNITO:" -ForegroundColor Yellow
Write-Host "   - Ctrl+Shift+N (Chrome)" -ForegroundColor White
Write-Host "   - Fazer login novamente" -ForegroundColor White
Write-Host "   - Testar salvamento" -ForegroundColor White

Write-Host ""
Write-Host "PERGUNTAS ESPECIFICAS:" -ForegroundColor Cyan
Write-Host "A. Quando clica em Salvar, o botao fica desabilitado?" -ForegroundColor White
Write-Host "B. Aparece algum loading ou indicacao visual?" -ForegroundColor White
Write-Host "C. Na aba Network, aparece alguma requisicao?" -ForegroundColor White
Write-Host "D. A aplicacao foi recompilada apos as correcoes?" -ForegroundColor White

Write-Host ""
Write-Host "RESPONDA ESSAS PERGUNTAS PARA EU AJUDAR MELHOR!" -ForegroundColor Green