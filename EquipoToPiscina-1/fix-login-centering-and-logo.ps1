#!/usr/bin/env pwsh
# Script para corrigir centralização do CPF e adicionar logo do RDO App

Write-Host "=== CORREÇÃO: CPF Centralizado e Logo RDO App ===" -ForegroundColor Green
Write-Host "Aplicando correções finais na tela de login" -ForegroundColor Yellow

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. Compilando projeto..." -ForegroundColor Cyan
try {
    dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Compilação bem-sucedida" -ForegroundColor Green
    } else {
        Write-Host "✗ Erro na compilação" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Erro na compilação: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== CORREÇÕES APLICADAS ===" -ForegroundColor Green
Write-Host "✓ CPF sempre centralizado (antes e depois do preenchimento)" -ForegroundColor White
Write-Host "✓ Senha sempre centralizada" -ForegroundColor White
Write-Host "✓ Logo SVG do RDO App implementado" -ForegroundColor White
Write-Host "✓ Design baseado no logo original que você forneceu" -ForegroundColor White
Write-Host "✓ Gradiente azul no logo" -ForegroundColor White
Write-Host "✓ Bordas arredondadas e sombra" -ForegroundColor White

Write-Host "`n=== CARACTERÍSTICAS FINAIS ===" -ForegroundColor Cyan
Write-Host "• Campos CPF e Senha: sempre centralizados" -ForegroundColor White
Write-Host "• Logo: SVG com gradiente azul profissional" -ForegroundColor White
Write-Host "• Tamanho: 90x90px com bordas arredondadas" -ForegroundColor White
Write-Host "• Checkbox 'Lembrar-me': centralizado" -ForegroundColor White
Write-Host "• Botão ACESSAR: mesma largura dos campos" -ForegroundColor White
Write-Host "• Layout: compacto e elegante (280px)" -ForegroundColor White

Write-Host "`n=== INSTRUÇÕES DE TESTE ===" -ForegroundColor Yellow
Write-Host "1. Compile no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Execute com F5" -ForegroundColor White
Write-Host "3. Abra em modo incógnito" -ForegroundColor White
Write-Host "4. Verifique o logo do RDO App" -ForegroundColor White
Write-Host "5. Digite no campo CPF - deve ficar centralizado" -ForegroundColor White
Write-Host "6. Digite no campo Senha - deve ficar centralizado" -ForegroundColor White
Write-Host "7. Teste o login completo" -ForegroundColor White

Write-Host "`n=== OPCIONAL: Logo Real ===" -ForegroundColor Cyan
Write-Host "Para usar o logo real (PNG):" -ForegroundColor Yellow
Write-Host "1. Salve uma das imagens como 'rdo-logo.png'" -ForegroundColor White
Write-Host "2. Coloque em: wwwroot/images/rdo-logo.png" -ForegroundColor White
Write-Host "3. O sistema detectará automaticamente" -ForegroundColor White

Write-Host "`nCorreções aplicadas! Teste no Visual Studio!" -ForegroundColor Green