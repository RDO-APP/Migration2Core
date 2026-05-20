#!/usr/bin/env pwsh

Write-Host "=== TESTE HTTPS LOGIN PAGE ===" -ForegroundColor Green
Write-Host ""

Write-Host "1. Testando HTTPS login page..." -ForegroundColor Yellow

try {
    # Test HTTPS login page
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Auth/Login" -UseBasicParsing -TimeoutSec 10
    Write-Host "   HTTPS Login: Status $($response.StatusCode)" -ForegroundColor Green
    
    # Check if login form elements are present
    if ($response.Content -match "CPF" -and $response.Content -match "Senha") {
        Write-Host "   Login Form: Elementos presentes" -ForegroundColor Green
    }
    
    if ($response.Content -match "Lembrar-me") {
        Write-Host "   Checkbox: 'Lembrar-me' encontrado" -ForegroundColor Green
    }
    
    if ($response.Content -match "RDO App") {
        Write-Host "   Logo: RDO App presente" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   HTTPS Login: Erro - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

Write-Host "2. Testando redirecionamento HTTPS..." -ForegroundColor Yellow

try {
    # Test root HTTPS
    $response = Invoke-WebRequest -Uri "https://localhost:7201/" -UseBasicParsing -TimeoutSec 10
    Write-Host "   Root HTTPS: Status $($response.StatusCode)" -ForegroundColor Green
    
    if ($response.Headers.Location) {
        Write-Host "   Redirecionamento: $($response.Headers.Location)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   Root HTTPS: Erro - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

Write-Host "3. Abrindo browser na pagina HTTPS..." -ForegroundColor Yellow

try {
    Start-Process "https://localhost:7201/Auth/Login"
    Write-Host "   Browser aberto: https://localhost:7201/Auth/Login" -ForegroundColor Green
} catch {
    Write-Host "   Erro ao abrir browser: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== INSTRUCOES ===" -ForegroundColor Magenta
Write-Host "1. Acesse: https://localhost:7201/Auth/Login" -ForegroundColor White
Write-Host "2. CPF: 567.065.455-20" -ForegroundColor White
Write-Host "3. Senha: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host "4. Marque 'Lembrar-me' se desejar" -ForegroundColor White
Write-Host "5. Clique em ACESSAR" -ForegroundColor White
Write-Host ""
Write-Host "A pagina deve mostrar o design exato da producao!" -ForegroundColor Green