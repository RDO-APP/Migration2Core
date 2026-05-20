Write-Host "=== DETECTAR E CRIAR USUARIO PARA OBRA DE TESTE ===" -ForegroundColor Green

Write-Host "Este script vai:" -ForegroundColor Yellow
Write-Host "1. Detectar qual obra voce esta usando para testes" -ForegroundColor White
Write-Host "2. Criar automaticamente um usuario dedicado para essa obra" -ForegroundColor White
Write-Host "3. Acelerar seus testes futuros" -ForegroundColor White

Write-Host ""
Write-Host "ARQUIVOS CRIADOS:" -ForegroundColor Cyan
Write-Host "- detectar-obra-teste-atual.sql (analise detalhada)" -ForegroundColor White
Write-Host "- criar-usuario-automatico-obra-teste.sql (criacao automatica)" -ForegroundColor White

Write-Host ""
Write-Host "COMO USAR:" -ForegroundColor Yellow
Write-Host "OPCAO 1 - Deteccao Manual:" -ForegroundColor Cyan
Write-Host "1. Execute: detectar-obra-teste-atual.sql no DBeaver" -ForegroundColor White
Write-Host "2. Veja qual obra tem mais atividade recente" -ForegroundColor White
Write-Host "3. Anote o ID da obra" -ForegroundColor White

Write-Host ""
Write-Host "OPCAO 2 - Criacao Automatica (Recomendado):" -ForegroundColor Cyan
Write-Host "1. Execute: criar-usuario-automatico-obra-teste.sql no DBeaver" -ForegroundColor White
Write-Host "2. O script detecta automaticamente a obra mais usada" -ForegroundColor White
Write-Host "3. Cria o usuario dedicado para essa obra" -ForegroundColor White

Write-Host ""
Write-Host "CREDENCIAIS DO USUARIO AUTOMATICO:" -ForegroundColor Green
Write-Host "CPF: 999.999.999-99 (ou 99999999999)" -ForegroundColor White
Write-Host "Senha: 1234" -ForegroundColor White
Write-Host "Nome: Teste Rapido Obra" -ForegroundColor White

Write-Host ""
Write-Host "APOS EXECUTAR:" -ForegroundColor Yellow
Write-Host "1. Fazer logout do usuario atual" -ForegroundColor White
Write-Host "2. Login com: 999.999.999-99 / 1234" -ForegroundColor White
Write-Host "3. Verificar carregamento rapido (apenas uma obra)" -ForegroundColor White
Write-Host "4. Testar funcionalidade de laudo" -ForegroundColor White

Write-Host ""
Write-Host "VANTAGENS:" -ForegroundColor Green
Write-Host "- Login 10x mais rapido" -ForegroundColor White
Write-Host "- Carrega apenas a obra que voce esta testando" -ForegroundColor White
Write-Host "- Deteccao automatica da obra mais ativa" -ForegroundColor White
Write-Host "- Ideal para desenvolvimento e testes" -ForegroundColor White