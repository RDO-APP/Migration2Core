Write-Host "=== EXCECAO IDENTIFICADA: EntityCommandExecutionException ===" -ForegroundColor Red

Write-Host ""
Write-Host "EXCECOES ENCONTRADAS NO VS OUTPUT:" -ForegroundColor Yellow
Write-Host "1. System.Data.Entity.Core.EntityCommandExecutionException" -ForegroundColor Red
Write-Host "2. System.Exception em rdoappProject.dll" -ForegroundColor Red

Write-Host ""
Write-Host "CAUSA PROVAVEL:" -ForegroundColor Cyan
Write-Host "- Campo inexistente na tabela laudo" -ForegroundColor White
Write-Host "- Tipo de dados incompativel" -ForegroundColor White
Write-Host "- Constraint violation (chave estrangeira)" -ForegroundColor White
Write-Host "- Sintaxe SQL gerada incorretamente" -ForegroundColor White

Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Green

Write-Host ""
Write-Host "1. VERIFICAR LOGS DEBUG:" -ForegroundColor Yellow
Write-Host "   - No VS Output Window, procure por:" -ForegroundColor White
Write-Host "   - === DEBUG SALVAR LAUDO ===" -ForegroundColor White
Write-Host "   - Se nao aparecer, a funcao nao esta sendo chamada" -ForegroundColor White

Write-Host ""
Write-Host "2. VERIFICAR ESTRUTURA DA TABELA:" -ForegroundColor Yellow
Write-Host "   - Execute: verificar-estrutura-tabela-laudo.sql" -ForegroundColor White
Write-Host "   - Confirme se todos os campos existem" -ForegroundColor White
Write-Host "   - Verifique tipos de dados" -ForegroundColor White

Write-Host ""
Write-Host "3. TESTAR INSERT MANUAL:" -ForegroundColor Yellow
Write-Host "   - Teste INSERT direto no banco" -ForegroundColor White
Write-Host "   - Identifique qual campo esta causando erro" -ForegroundColor White

Write-Host ""
Write-Host "EXECUTE OS PASSOS E ME INFORME:" -ForegroundColor Green
Write-Host "A. Aparece === DEBUG SALVAR LAUDO === no Output?" -ForegroundColor White
Write-Host "B. Qual e a estrutura da tabela laudo?" -ForegroundColor White
Write-Host "C. O INSERT manual funciona?" -ForegroundColor White

Write-Host ""
Write-Host "AGORA SABEMOS A CAUSA - VAMOS IDENTIFICAR O CAMPO ESPECIFICO!" -ForegroundColor Cyan