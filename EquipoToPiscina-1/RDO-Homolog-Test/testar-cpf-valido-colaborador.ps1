Write-Host "=== PROBLEMA: CPF NAO ACEITO PARA COLABORADOR ===" -ForegroundColor Yellow

Write-Host "Voce esta certo! O CPF 222.222.222-22 pode nao estar sendo aceito." -ForegroundColor Green
Write-Host "Vamos testar diferentes formatos de CPF." -ForegroundColor Yellow

Write-Host ""
Write-Host "FORMATOS DE CPF PARA TESTAR:" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. CPFS VALIDOS PARA TESTE:" -ForegroundColor Yellow
Write-Host "   - 111.111.111-11 (ou 11111111111)" -ForegroundColor White
Write-Host "   - 123.456.789-09 (ou 12345678909)" -ForegroundColor White
Write-Host "   - 987.654.321-00 (ou 98765432100)" -ForegroundColor White
Write-Host "   - 555.555.555-55 (ou 55555555555)" -ForegroundColor White

Write-Host ""
Write-Host "2. FORMATOS A TESTAR:" -ForegroundColor Yellow
Write-Host "   - COM pontos e traco: 111.111.111-11" -ForegroundColor White
Write-Host "   - SEM formatacao: 11111111111" -ForegroundColor White
Write-Host "   - Apenas numeros: 11111111111" -ForegroundColor White

Write-Host ""
Write-Host "3. VERIFICAR VALIDACAO:" -ForegroundColor Yellow
Write-Host "   - F12 > Console" -ForegroundColor White
Write-Host "   - Preencher CPF diferente" -ForegroundColor White
Write-Host "   - Clicar em Salvar" -ForegroundColor White
Write-Host "   - Ver se aparece erro de validacao" -ForegroundColor White

Write-Host ""
Write-Host "4. VERIFICAR F12 > NETWORK:" -ForegroundColor Yellow
Write-Host "   - Limpar log da aba Network" -ForegroundColor White
Write-Host "   - Tentar salvar com CPF valido" -ForegroundColor White
Write-Host "   - Ver se aparece requisicao HTTP" -ForegroundColor White
Write-Host "   - Verificar resposta do servidor" -ForegroundColor White

Write-Host ""
Write-Host "TESTE SUGERIDO:" -ForegroundColor Green
Write-Host "1. Tente CPF: 111.111.111-11" -ForegroundColor White
Write-Host "2. Nome: Usuario Teste" -ForegroundColor White
Write-Host "3. Senha: 1234" -ForegroundColor White
Write-Host "4. Preencha outros campos obrigatorios" -ForegroundColor White
Write-Host "5. Clique em Salvar" -ForegroundColor White

Write-Host ""
Write-Host "SE AINDA NAO FUNCIONAR:" -ForegroundColor Red
Write-Host "- Verificar se todos os campos obrigatorios estao preenchidos" -ForegroundColor White
Write-Host "- Verificar se ha validacao JavaScript bloqueando" -ForegroundColor White
Write-Host "- Verificar permissoes do usuario atual" -ForegroundColor White

Write-Host ""
Write-Host "TESTE AGORA COM CPF DIFERENTE!" -ForegroundColor Cyan