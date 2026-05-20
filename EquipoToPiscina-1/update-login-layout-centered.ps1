#!/usr/bin/env pwsh
# Script para atualizar layout da tela de login com campos centralizados

Write-Host "=== ATUALIZAÇÃO: Login com Campos Centralizados ===" -ForegroundColor Green
Write-Host "Aplicando melhorias no layout da tela de login" -ForegroundColor Yellow

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

Write-Host "`n=== MELHORIAS APLICADAS ===" -ForegroundColor Green
Write-Host "✓ Campos CPF e Senha centralizados" -ForegroundColor White
Write-Host "✓ Largura dos campos reduzida (280px)" -ForegroundColor White
Write-Host "✓ Checkbox 'Lembrar-me' centralizado" -ForegroundColor White
Write-Host "✓ Botão ACESSAR com mesma largura dos campos" -ForegroundColor White
Write-Host "✓ Logo maior e mais destacado (90x90px)" -ForegroundColor White
Write-Host "✓ Suporte para logo real (fallback para texto)" -ForegroundColor White
Write-Host "✓ Placeholder centralizado que move para esquerda no focus" -ForegroundColor White

Write-Host "`n=== INSTRUÇÕES ===" -ForegroundColor Cyan
Write-Host "1. Para usar o logo real:" -ForegroundColor Yellow
Write-Host "   - Salve uma das imagens do logo como 'rdo-logo.png'" -ForegroundColor White
Write-Host "   - Coloque em: RDO-NET8-Migration/RdoApp.Core/wwwroot/images/" -ForegroundColor White
Write-Host "   - Se não existir, usará o texto 'rdo' como fallback" -ForegroundColor White

Write-Host "`n2. Para testar:" -ForegroundColor Yellow
Write-Host "   - Compile no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "   - Execute com F5" -ForegroundColor White
Write-Host "   - Abra em modo incógnito" -ForegroundColor White
Write-Host "   - Veja o novo layout centralizado" -ForegroundColor White

Write-Host "`n=== CARACTERÍSTICAS DO NOVO LAYOUT ===" -ForegroundColor Cyan
Write-Host "• Campos menores e centralizados (280px)" -ForegroundColor White
Write-Host "• Texto centralizado que move para esquerda no focus" -ForegroundColor White
Write-Host "• Logo maior e mais profissional" -ForegroundColor White
Write-Host "• Checkbox 'Lembrar-me' centralizado" -ForegroundColor White
Write-Host "• Botão com mesma largura dos campos" -ForegroundColor White
Write-Host "• Design mais limpo e focado" -ForegroundColor White

Write-Host "`nAtualização concluída! Teste no Visual Studio!" -ForegroundColor Green