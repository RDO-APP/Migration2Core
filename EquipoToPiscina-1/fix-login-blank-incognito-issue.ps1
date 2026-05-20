#!/usr/bin/env pwsh

Write-Host "=== CORRIGINDO LOGIN EM BRANCO - MODO INCÓGNITO ===" -ForegroundColor Green

# Parar processos existentes
Write-Host "Parando processos..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core", "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Verificando arquivos de view..." -ForegroundColor Yellow

# Verificar se Login.cshtml existe
if (Test-Path "Views/Auth/Login.cshtml") {
    Write-Host "✅ Login.cshtml existe" -ForegroundColor Green
} else {
    Write-Host "❌ Login.cshtml NÃO existe" -ForegroundColor Red
}

# Verificar se _Layout.cshtml existe
if (Test-Path "Views/Shared/_Layout.cshtml") {
    Write-Host "✅ _Layout.cshtml existe" -ForegroundColor Green
} else {
    Write-Host "❌ _Layout.cshtml NÃO existe" -ForegroundColor Red
}

# Verificar se AuthController existe
if (Test-Path "Controllers/AuthController.cs") {
    Write-Host "✅ AuthController.cs existe" -ForegroundColor Green
} else {
    Write-Host "❌ AuthController.cs NÃO existe" -ForegroundColor Red
}

Write-Host "Iniciando aplicação com logs detalhados..." -ForegroundColor Yellow

# Iniciar aplicação com logs detalhados
$env:ASPNETCORE_ENVIRONMENT = "Development"
$env:Logging__LogLevel__Default = "Information"
$env:Logging__LogLevel__Microsoft = "Information"

Start-Process -FilePath "dotnet" -ArgumentList "run --urls `"http://localhost:5031;https://localhost:7201`"" -WindowStyle Normal

Write-Host ""
Write-Host "INSTRUÇÕES PARA TESTE:" -ForegroundColor Cyan
Write-Host "1. Aguarde 5 segundos para aplicação iniciar" -ForegroundColor White
Write-Host "2. Abra janela anônima/incógnito" -ForegroundColor White
Write-Host "3. Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "4. Se ainda estiver em branco:" -ForegroundColor White
Write-Host "   - Pressione F12 (Developer Tools)" -ForegroundColor White
Write-Host "   - Vá na aba Console" -ForegroundColor White
Write-Host "   - Vá na aba Network" -ForegroundColor White
Write-Host "   - Recarregue a página (F5)" -ForegroundColor White
Write-Host "   - Verifique se há erros 404, 500, etc." -ForegroundColor White
Write-Host ""
Write-Host "5. Teste também: https://localhost:7201/Auth/Login" -ForegroundColor White
Write-Host ""
Write-Host "CREDENCIAIS PARA TESTE:" -ForegroundColor Cyan
Write-Host "CPF: 567.065.455-20" -ForegroundColor White
Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor White