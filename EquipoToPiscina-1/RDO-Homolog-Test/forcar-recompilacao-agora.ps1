Write-Host "=== FORCANDO RECOMPILACAO DA APLICACAO ===" -ForegroundColor Green

Write-Host "A correcao do LINQ to Entities precisa ser compilada!" -ForegroundColor Yellow

Write-Host ""
Write-Host "PASSOS PARA RECOMPILAR:" -ForegroundColor Cyan

Write-Host ""
Write-Host "1. ABRIR VISUAL STUDIO COMO ADMINISTRADOR:" -ForegroundColor Yellow
Write-Host "   - Fechar Visual Studio se estiver aberto" -ForegroundColor White
Write-Host "   - Clicar com botao direito no Visual Studio" -ForegroundColor White
Write-Host "   - Selecionar 'Executar como administrador'" -ForegroundColor White

Write-Host ""
Write-Host "2. ABRIR O PROJETO:" -ForegroundColor Yellow
Write-Host "   - File > Open > Project/Solution" -ForegroundColor White
Write-Host "   - Navegar ate: RDO-Homolog-Test/rdoappProject/" -ForegroundColor White
Write-Host "   - Abrir: rdoappProject.sln" -ForegroundColor White

Write-Host ""
Write-Host "3. LIMPAR E RECOMPILAR:" -ForegroundColor Yellow
Write-Host "   - Build > Clean Solution (aguardar terminar)" -ForegroundColor White
Write-Host "   - Build > Rebuild Solution (aguardar terminar)" -ForegroundColor White
Write-Host "   - Verificar se nao ha erros na janela Output" -ForegroundColor White

Write-Host ""
Write-Host "4. EXECUTAR A APLICACAO:" -ForegroundColor Yellow
Write-Host "   - Pressionar F5 ou Debug > Start Debugging" -ForegroundColor White
Write-Host "   - Aguardar aplicacao abrir no navegador" -ForegroundColor White

Write-Host ""
Write-Host "5. TESTAR NOVAMENTE:" -ForegroundColor Yellow
Write-Host "   - Fazer login com o novo usuario" -ForegroundColor White
Write-Host "   - Preencher formulario de laudo" -ForegroundColor White
Write-Host "   - Clicar em Salvar" -ForegroundColor White
Write-Host "   - Verificar F12 > Console para mensagens" -ForegroundColor White

Write-Host ""
Write-Host "IMPORTANTE:" -ForegroundColor Red
Write-Host "- Visual Studio DEVE estar como Administrador" -ForegroundColor White
Write-Host "- Aguardar Clean e Rebuild terminarem completamente" -ForegroundColor White
Write-Host "- Verificar se nao ha erros de compilacao" -ForegroundColor White

Write-Host ""
Write-Host "Execute estes passos e teste novamente!" -ForegroundColor Cyan