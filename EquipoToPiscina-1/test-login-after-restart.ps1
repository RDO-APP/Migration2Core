#!/usr/bin/env pwsh

Write-Host "=== TESTE LOGIN APOS RESTART ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Testando HTTP login..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing -TimeoutSec 10
    Write-Host "   HTTP Login: Status $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Content Length: $($response.Content.Length) bytes" -ForegroundColor Gray
    
    if ($response.Content -match "CPF" -and $response.Content -match "Senha") {
        Write-Host "   Login Form: ELEMENTOS ENCONTRADOS!" -ForegroundColor Green
    } else {
        Write-Host "   Login Form: Elementos nao encontrados" -ForegroundColor Red
    }
    
    if ($response.Content -match "Lembrar-me") {
        Write-Host "   Checkbox: 'Lembrar-me' encontrado" -ForegroundColor Green
    }
    
    if ($response.Content -match "RDO") {
        Write-Host "   Logo: RDO presente" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   HTTP Login: ERRO - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

Write-Host "2. Testando HTTPS login..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -UseBasicParsing -TimeoutSec 10
    Write-Host "   HTTPS Login: Status $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Content Length: $($response.Content.Length) bytes" -ForegroundColor Gray
    
    if ($response.Content -match "CPF" -and $response.Content -match "Senha") {
        Write-Host "   Login Form: ELEMENTOS ENCONTRADOS!" -ForegroundColor Green
    } else {
        Write-Host "   Login Form: Elementos nao encontrados" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   HTTPS Login: ERRO - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

Write-Host "3. Abrindo browser..." -ForegroundColor Yellow
try {
    Start-Process "https://localhost:7201/Auth/Login"
    Write-Host "   Browser aberto: https://localhost:7201/Auth/Login" -ForegroundColor Green
} catch {
    Write-Host "   Erro ao abrir browser: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Tentando HTTP..." -ForegroundColor Yellow
    try {
        Start-Process "http://localhost:5031/Auth/Login"
        Write-Host "   Browser aberto: http://localhost:5031/Auth/Login" -ForegroundColor Green
    } catch {
        Write-Host "   Erro ao abrir HTTP: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== INSTRUCOES ===" -ForegroundColor Magenta
Write-Host "1. Se a pagina ainda estiver em branco:" -ForegroundColor White
Write-Host "   - Pressione F5 para atualizar" -ForegroundColor Gray
Write-Host "   - Ou pressione Ctrl+F5 (hard refresh)" -ForegroundColor Gray
Write-Host "   - Ou abra modo incognito" -ForegroundColor Gray
Write-Host ""
Write-Host "2. URLs para testar:" -ForegroundColor White
Write-Host "   - https://localhost:7201/Auth/Login" -ForegroundColor Gray
Write-Host "   - http://localhost:5031/Auth/Login" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Credenciais:" -ForegroundColor White
Write-Host "   - CPF: 567.065.455-20" -ForegroundColor Gray
Write-Host "   - Senha: RXL8DjdYj6Y=" -ForegroundColor Gray