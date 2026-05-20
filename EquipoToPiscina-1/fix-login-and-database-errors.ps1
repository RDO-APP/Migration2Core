#!/usr/bin/env pwsh
# Fix auto-login and database errors

Write-Host "=== CORRIGINDO LOGIN AUTOMÁTICO E ERROS DE BANCO ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. Limpando cookies e cache..." -ForegroundColor Cyan
Write-Host "INSTRUÇÕES PARA LIMPAR LOGIN AUTOMÁTICO:" -ForegroundColor Yellow
Write-Host "1. Abra o navegador em modo incógnito (Ctrl+Shift+N)" -ForegroundColor White
Write-Host "2. Ou limpe os cookies do site localhost" -ForegroundColor White
Write-Host "3. Ou feche todos os navegadores e reabra" -ForegroundColor White

Write-Host "`n2. Verificando configuração de autenticação..." -ForegroundColor Cyan
$programCs = Get-Content "Program.cs" -Raw
if ($programCs -match 'LoginPath = "/Auth/Login"') {
    Write-Host "✓ LoginPath configurado corretamente" -ForegroundColor Green
} else {
    Write-Host "✗ Problema na configuração de login" -ForegroundColor Red
}

Write-Host "`n3. Compilando projeto..." -ForegroundColor Cyan
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

Write-Host "`n4. Verificando logs de erro..." -ForegroundColor Cyan
Write-Host "Para ver o erro detalhado quando clicar na obra:" -ForegroundColor Yellow
Write-Host "1. Abra o Visual Studio" -ForegroundColor White
Write-Host "2. Vá em View > Output" -ForegroundColor White
Write-Host "3. Selecione 'Debug' no dropdown" -ForegroundColor White
Write-Host "4. Execute com F5 e clique na obra" -ForegroundColor White
Write-Host "5. Veja o erro detalhado no Output" -ForegroundColor White

Write-Host "`n=== PRÓXIMOS PASSOS ===" -ForegroundColor Green
Write-Host "1. Feche TODOS os navegadores" -ForegroundColor White
Write-Host "2. Abra Visual Studio" -ForegroundColor White
Write-Host "3. Compile com Ctrl+Shift+B" -ForegroundColor White
Write-Host "4. Execute com F5" -ForegroundColor White
Write-Host "5. Abra navegador em modo incógnito" -ForegroundColor White
Write-Host "6. Vá para localhost:porta" -ForegroundColor White
Write-Host "7. Deve aparecer a tela de login" -ForegroundColor White
Write-Host "8. Faça login e teste clicar na obra" -ForegroundColor White
Write-Host "9. Se der erro, veja o Output do Visual Studio" -ForegroundColor White

Write-Host "`nScript concluído!" -ForegroundColor Green