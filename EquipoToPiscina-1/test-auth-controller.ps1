#!/usr/bin/env pwsh

Write-Host "=== TESTE AUTH CONTROLLER ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Testando rota direta do controller..." -ForegroundColor Yellow

# Testar diferentes rotas
$routes = @(
    "http://localhost:5031/Auth/Login",
    "http://localhost:5031/auth/login",
    "http://localhost:5031/Auth",
    "http://localhost:5031/Home/Index"
)

foreach ($route in $routes) {
    try {
        Write-Host "   Testando: $route" -ForegroundColor Gray
        $response = Invoke-WebRequest -Uri $route -UseBasicParsing -TimeoutSec 5
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
        
        # Check if it contains login elements
        if ($response.Content -match "CPF" -or $response.Content -match "Senha") {
            Write-Host "   LOGIN FORM: ENCONTRADO!" -ForegroundColor Green
        } else {
            Write-Host "   LOGIN FORM: Nao encontrado" -ForegroundColor Red
        }
        
        # Check title
        if ($response.Content -match "<title>([^<]*)</title>") {
            Write-Host "   Title: $($matches[1])" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "   ERRO: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "2. Verificando arquivos do projeto..." -ForegroundColor Yellow

$files = @(
    "RDO-NET8-Migration/RdoApp.Core/Views/Auth/Login.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml",
    "RDO-NET8-Migration/RdoApp.Core/Controllers/AuthController.cs"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        Write-Host "   $file : OK ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "   $file : AUSENTE!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== DIAGNOSTICO ===" -ForegroundColor Magenta
Write-Host "Se o login form nao foi encontrado em nenhuma rota," -ForegroundColor White
Write-Host "pode haver um problema com:" -ForegroundColor White
Write-Host "1. View nao sendo encontrada" -ForegroundColor Gray
Write-Host "2. Controller nao funcionando" -ForegroundColor Gray
Write-Host "3. Roteamento incorreto" -ForegroundColor Gray