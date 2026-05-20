#!/usr/bin/env pwsh

Write-Host "=== VALIDACAO PAGINA LOGIN ===" -ForegroundColor Green
Write-Host ""

# Verificar se aplicacao esta rodando
Write-Host "1. Verificando aplicacao..." -ForegroundColor Yellow
$process = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" }
if ($process) {
    Write-Host "   Aplicacao rodando (PID: $($process.Id))" -ForegroundColor Green
} else {
    Write-Host "   Aplicacao NAO esta rodando" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Testar URLs
Write-Host "2. Testando URLs..." -ForegroundColor Yellow

# Testar HTTP
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing -TimeoutSec 10
    Write-Host "   HTTP (5031): Status $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   HTTP (5031): Erro - $($_.Exception.Message)" -ForegroundColor Red
}

# Testar HTTPS
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -UseBasicParsing -TimeoutSec 10 -SkipCertificateCheck
    Write-Host "   HTTPS (7201): Status $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   HTTPS (7201): Erro - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Verificar redirecionamento
Write-Host "3. Testando redirecionamento..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/" -UseBasicParsing -TimeoutSec 10
    Write-Host "   Root HTTP: Status $($response.StatusCode)" -ForegroundColor Green
    
    if ($response.Headers.Location) {
        Write-Host "   Redirecionamento para: $($response.Headers.Location)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   Root HTTP: Erro - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Verificar configuracao HTTPS
Write-Host "4. Verificando configuracao HTTPS..." -ForegroundColor Yellow

$programFile = "RDO-NET8-Migration/RdoApp.Core/Program.cs"
if (Test-Path $programFile) {
    $content = Get-Content $programFile -Raw
    
    if ($content -match "UseHttpsRedirection") {
        Write-Host "   UseHttpsRedirection: PRESENTE" -ForegroundColor Green
    } else {
        Write-Host "   UseHttpsRedirection: AUSENTE" -ForegroundColor Red
    }
    
    if ($content -match "UseHsts") {
        Write-Host "   UseHsts: PRESENTE" -ForegroundColor Green
    } else {
        Write-Host "   UseHsts: AUSENTE" -ForegroundColor Yellow
    }
} else {
    Write-Host "   Program.cs nao encontrado" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== INSTRUCOES ===" -ForegroundColor Magenta
Write-Host "1. Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "2. Ou acesse: https://localhost:7201/Auth/Login" -ForegroundColor White
Write-Host "3. Use CPF: 567.065.455-20" -ForegroundColor White
Write-Host "4. Use Senha: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host ""