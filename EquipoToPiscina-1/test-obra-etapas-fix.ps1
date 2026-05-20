#!/usr/bin/env pwsh
# Test script to verify obra etapas database fix

Write-Host "=== TESTE: Fix Obra Etapas Database Error ===" -ForegroundColor Green
Write-Host "Testando correção do erro de coluna fantasma TarefaCodigoParalizacaoCodigoParalizacao" -ForegroundColor Yellow

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

Write-Host "`n2. Iniciando aplicação para teste..." -ForegroundColor Cyan
Write-Host "INSTRUÇÕES:" -ForegroundColor Yellow
Write-Host "1. Pressione Ctrl+Shift+B no Visual Studio para compilar" -ForegroundColor White
Write-Host "2. Pressione F5 para executar" -ForegroundColor White
Write-Host "3. Faça login com CPF: 567.065.455-20 e Senha: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host "4. Clique em uma obra para testar se o erro foi corrigido" -ForegroundColor White
Write-Host "5. Verifique se a página de etapas carrega sem erro de banco" -ForegroundColor White

Write-Host "`nSe ainda houver erro, execute este comando para ver detalhes:" -ForegroundColor Cyan
Write-Host "dotnet ef database update --verbose" -ForegroundColor White

Write-Host "`n=== CORREÇÃO APLICADA ===" -ForegroundColor Green
Write-Host "- Configuração explícita do relacionamento TarefaCodigoParalizacao" -ForegroundColor White
Write-Host "- Prevenção de geração automática de colunas fantasma" -ForegroundColor White
Write-Host "- Mapeamento correto das foreign keys" -ForegroundColor White

Write-Host "`nTeste concluído. Execute no Visual Studio agora!" -ForegroundColor Green