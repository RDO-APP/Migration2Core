#!/usr/bin/env pwsh

Write-Host "=== DIAGNOSTICANDO PÁGINA LOGIN EM BRANCO ===" -ForegroundColor Green

# Parar processos existentes
Write-Host "Parando processos..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core", "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Limpar cookies/cache do navegador primeiro
Write-Host "IMPORTANTE: Limpe os cookies do navegador para http://localhost:5031" -ForegroundColor Red

# Iniciar aplicação
Write-Host "Iniciando aplicação..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --urls `"http://localhost:5031;https://localhost:7201`"" -PassThru -WindowStyle Normal

# Aguardar inicialização
Write-Host "Aguardando inicialização..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Testar se está rodando
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10
    Write-Host "✅ Aplicação respondendo: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Aplicação não está respondendo" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

# Testar rota de login especificamente
try {
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10
    Write-Host "✅ Rota Login respondendo: $($loginResponse.StatusCode)" -ForegroundColor Green
    
    # Verificar se contém HTML da página de login
    if ($loginResponse.Content -like "*login*" -or $loginResponse.Content -like "*CPF*") {
        Write-Host "✅ Página de login contém conteúdo esperado" -ForegroundColor Green
    } else {
        Write-Host "❌ Página de login não contém conteúdo esperado" -ForegroundColor Red
        Write-Host "Conteúdo recebido (primeiros 200 chars):" -ForegroundColor Yellow
        Write-Host $loginResponse.Content.Substring(0, [Math]::Min(200, $loginResponse.Content.Length))
    }
} catch {
    Write-Host "❌ Rota Login não está respondendo" -ForegroundColor Red
    Write-Host "Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "DIAGNÓSTICO:" -ForegroundColor Cyan
Write-Host "1. Se aplicação está rodando mas login em branco:" -ForegroundColor White
Write-Host "   - Limpe cookies do navegador" -ForegroundColor White
Write-Host "   - Use modo incógnito" -ForegroundColor White
Write-Host "   - Verifique console do navegador (F12)" -ForegroundColor White
Write-Host ""
Write-Host "2. URLs para testar:" -ForegroundColor White
Write-Host "   - http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "   - https://localhost:7201/Auth/Login" -ForegroundColor White
Write-Host ""
Write-Host "3. Para forçar logout e ver login:" -ForegroundColor White
Write-Host "   - Acesse: http://localhost:5031/Auth/Logout" -ForegroundColor White

# Manter processo rodando
Write-Host ""
Write-Host "Aplicação rodando. Pressione Ctrl+C para parar." -ForegroundColor Green
try {
    $process.WaitForExit()
} catch {
    Write-Host "Processo finalizado." -ForegroundColor Yellow
}