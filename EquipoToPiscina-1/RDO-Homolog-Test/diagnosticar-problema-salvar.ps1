Write-Host "=== DIAGNOSTICO: BOTAO SALVAR NAO FUNCIONA ===" -ForegroundColor Red

Write-Host "Vamos investigar por que o laudo nao esta salvando..." -ForegroundColor Yellow

Write-Host ""
Write-Host "VERIFICACOES NECESSARIAS:" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. VERIFICAR CONSOLE F12:" -ForegroundColor Yellow
Write-Host "   - Pressione F12 no navegador" -ForegroundColor White
Write-Host "   - Va na aba Console" -ForegroundColor White
Write-Host "   - Tente salvar novamente" -ForegroundColor White
Write-Host "   - Veja se aparece algum erro em vermelho" -ForegroundColor White

Write-Host ""
Write-Host "2. VERIFICAR SE A APLICACAO FOI RECOMPILADA:" -ForegroundColor Yellow
Write-Host "   - A correcao do LINQ to Entities precisa ser compilada" -ForegroundColor White
Write-Host "   - Abrir Visual Studio como Administrador" -ForegroundColor White
Write-Host "   - Build > Clean Solution" -ForegroundColor White
Write-Host "   - Build > Rebuild Solution" -ForegroundColor White

Write-Host ""
Write-Host "3. VERIFICAR REDE/BACKEND:" -ForegroundColor Yellow
Write-Host "   - F12 > Network (Rede)" -ForegroundColor White
Write-Host "   - Tentar salvar novamente" -ForegroundColor White
Write-Host "   - Ver se aparece requisicao para /api/tarefa/SalvarLaudo" -ForegroundColor White
Write-Host "   - Verificar se retorna erro 500 ou outro codigo" -ForegroundColor White

Write-Host ""
Write-Host "4. TESTAR EM MODO INCOGNITO:" -ForegroundColor Yellow
Write-Host "   - Ctrl+Shift+N (Chrome) ou Ctrl+Shift+P (Firefox)" -ForegroundColor White
Write-Host "   - Fazer login novamente" -ForegroundColor White
Write-Host "   - Testar salvamento (elimina cache)" -ForegroundColor White

Write-Host ""
Write-Host "POSSIVEIS CAUSAS:" -ForegroundColor Red
Write-Host "- Aplicacao nao foi recompilada apos correcoes" -ForegroundColor White
Write-Host "- Erro JavaScript no frontend" -ForegroundColor White
Write-Host "- Erro no backend (LINQ to Entities ainda presente)" -ForegroundColor White
Write-Host "- Cache do navegador" -ForegroundColor White
Write-Host "- Problema de permissao do usuario criado" -ForegroundColor White

Write-Host ""
Write-Host "EXECUTE ESTAS VERIFICACOES E ME INFORME O RESULTADO!" -ForegroundColor Cyan