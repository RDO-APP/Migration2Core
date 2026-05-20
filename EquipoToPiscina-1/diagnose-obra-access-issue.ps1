# DIAGNÓSTICO - PROBLEMA ACESSO ÀS OBRAS
# Usuário consegue fazer login mas não acessa as obras

Write-Host "=== DIAGNÓSTICO ACESSO ÀS OBRAS ===" -ForegroundColor Cyan
Write-Host "Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor Gray
Write-Host ""

Write-Host "SITUAÇÃO ATUAL:" -ForegroundColor Yellow
Write-Host "✅ Login funcionando no browser normal" -ForegroundColor Green
Write-Host "❌ Não consegue acessar obras após login" -ForegroundColor Red
Write-Host "❌ Problema persiste em browser normal e anônimo" -ForegroundColor Red
Write-Host ""

Write-Host "POSSÍVEIS CAUSAS:" -ForegroundColor Yellow
Write-Host "1. Erro na query de obras do usuário" -ForegroundColor White
Write-Host "2. Problema nos relacionamentos ObraColaborador" -ForegroundColor White
Write-Host "3. Usuário não tem obras associadas no banco" -ForegroundColor White
Write-Host "4. Erro na autenticação/claims do usuário" -ForegroundColor White
Write-Host "5. Problema na navegação após login" -ForegroundColor White
Write-Host ""

Write-Host "PRÓXIMOS PASSOS DE DIAGNÓSTICO:" -ForegroundColor Magenta
Write-Host "1. Verificar logs do Visual Studio" -ForegroundColor White
Write-Host "2. Testar endpoint /Obra/Escolher diretamente" -ForegroundColor White
Write-Host "3. Verificar se usuário tem obras no banco" -ForegroundColor White
Write-Host "4. Verificar claims do usuário após login" -ForegroundColor White
Write-Host ""

Write-Host "EXECUTE ESTES COMANDOS:" -ForegroundColor Magenta
Write-Host ".\debug-obra-access-detailed.ps1" -ForegroundColor Yellow
Write-Host ".\verify-user-obras-database.ps1" -ForegroundColor Yellow