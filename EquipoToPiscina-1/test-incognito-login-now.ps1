#!/usr/bin/env pwsh

Write-Host "=== TESTE LOGIN INCOGNITO ===" -ForegroundColor Green

# Parar processos
Get-Process -Name "RdoApp.Core", "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Compilar
Write-Host "Compilando..." -ForegroundColor Yellow
dotnet build --verbosity quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro de compilacao" -ForegroundColor Red
    exit 1
}

# Iniciar aplicacao
Write-Host "Iniciando aplicacao..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --urls http://localhost:5031;https://localhost:7201" -PassThru -WindowStyle Normal

# Aguardar
Start-Sleep -Seconds 6

# Testar conectividade
Write-Host "Testando conectividade..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 10 -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Tamanho: $($response.Content.Length) bytes" -ForegroundColor Green
    
    if ($response.Content.Length -lt 500) {
        Write-Host "CONTEUDO MUITO PEQUENO - POSSIVEL PROBLEMA:" -ForegroundColor Red
        Write-Host $response.Content -ForegroundColor White
    } else {
        Write-Host "Conteudo parece OK" -ForegroundColor Green
    }
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTE MANUAL:" -ForegroundColor Cyan
Write-Host "1. Abra janela incognita" -ForegroundColor White
Write-Host "2. Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "3. Se branco, pressione F12 e veja Console/Network" -ForegroundColor White
Write-Host ""
Write-Host "Pressione ENTER para parar..." -ForegroundColor Yellow
Read-Host

$process.Kill() -ErrorAction SilentlyContinue