#!/usr/bin/env pwsh

Write-Host "=== TESTE LOGIN APOS CORRECAO ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Verificando arquivo Login.cshtml..." -ForegroundColor Yellow
$loginFile = "RDO-NET8-Migration/RdoApp.Core/Views/Auth/Login.cshtml"
if (Test-Path $loginFile) {
    $size = (Get-Item $loginFile).Length
    Write-Host "   Login.cshtml: $size bytes" -ForegroundColor Green
    
    if ($size -gt 1000) {
        Write-Host "   Arquivo parece estar OK!" -ForegroundColor Green
    } else {
        Write-Host "   AVISO: Arquivo muito pequeno!" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ERRO: Arquivo nao encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host ""

Write-Host "2. Testando login page..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing -TimeoutSec 10
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Content Length: $($response.Content.Length) bytes" -ForegroundColor Gray
    
    # Verificar elementos do login
    if ($response.Content -match "CPF") {
        Write-Host "   CPF field: ENCONTRADO!" -ForegroundColor Green
    } else {
        Write-Host "   CPF field: NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "Senha") {
        Write-Host "   Senha field: ENCONTRADO!" -ForegroundColor Green
    } else {
        Write-Host "   Senha field: NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "Lembrar-me") {
        Write-Host "   Lembrar-me checkbox: ENCONTRADO!" -ForegroundColor Green
    } else {
        Write-Host "   Lembrar-me checkbox: NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "ACESSAR") {
        Write-Host "   Botao ACESSAR: ENCONTRADO!" -ForegroundColor Green
    } else {
        Write-Host "   Botao ACESSAR: NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "RDO App Piscinas") {
        Write-Host "   Titulo: ENCONTRADO!" -ForegroundColor Green
    } else {
        Write-Host "   Titulo: NAO ENCONTRADO" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ERRO: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

Write-Host "3. Abrindo browser..." -ForegroundColor Yellow
try {
    Start-Process "https://localhost:7201/Auth/Login"
    Write-Host "   Browser aberto: https://localhost:7201/Auth/Login" -ForegroundColor Green
} catch {
    Write-Host "   Erro HTTPS, tentando HTTP..." -ForegroundColor Yellow
    try {
        Start-Process "http://localhost:5031/Auth/Login"
        Write-Host "   Browser aberto: http://localhost:5031/Auth/Login" -ForegroundColor Green
    } catch {
        Write-Host "   Erro ao abrir browser: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== RESULTADO ===" -ForegroundColor Magenta
Write-Host "Se todos os elementos foram encontrados," -ForegroundColor White
Write-Host "a pagina de login deve estar funcionando!" -ForegroundColor White
Write-Host ""
Write-Host "Credenciais para teste:" -ForegroundColor Yellow
Write-Host "CPF: 567.065.455-20" -ForegroundColor Gray
Write-Host "Senha: RXL8DjdYj6Y=" -ForegroundColor Gray