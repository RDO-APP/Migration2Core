#!/usr/bin/env pwsh

Write-Host "=== TESTE LOGIN PÁGINA ATUAL ===" -ForegroundColor Green
Write-Host ""

# Verificar se aplicação está rodando
Write-Host "1. Verificando se aplicação está rodando..." -ForegroundColor Yellow
$process = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" }
if ($process) {
    Write-Host "✅ Aplicação está rodando" -ForegroundColor Green
} else {
    Write-Host "❌ Aplicação não está rodando" -ForegroundColor Red
    Write-Host "Execute: dotnet run no diretório RDO-NET8-Migration/RdoApp.Core" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "2. URLs disponíveis:" -ForegroundColor Yellow
Write-Host "   HTTP:  http://localhost:5031" -ForegroundColor Cyan
Write-Host "   HTTPS: https://localhost:7201" -ForegroundColor Cyan
Write-Host ""

Write-Host "3. Para testar login:" -ForegroundColor Yellow
Write-Host "   CPF: 567.065.455-20" -ForegroundColor Cyan
Write-Host "   Senha: RXL8DjdYj6Y=" -ForegroundColor Cyan
Write-Host ""

Write-Host "4. Abrindo browser na página de login..." -ForegroundColor Yellow
try {
    Start-Process "https://localhost:7201/Auth/Login"
    Write-Host "✅ Browser aberto com sucesso" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro ao abrir browser: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Abra manualmente: https://localhost:7201/Auth/Login" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== INSTRUÇÕES ===" -ForegroundColor Magenta
Write-Host "1. Teste a página de login no browser" -ForegroundColor White
Write-Host "2. Verifique se o design está exatamente como a produção" -ForegroundColor White
Write-Host "3. Teste o login com as credenciais acima" -ForegroundColor White
Write-Host "4. Verifique se o checkbox 'Lembrar-me' está funcionando" -ForegroundColor White
Write-Host ""
Write-Host "Se houver problemas visuais, informe para ajustarmos!" -ForegroundColor Green