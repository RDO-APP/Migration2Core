#!/usr/bin/env pwsh

Write-Host "=== DEBUG RESPONSE CONTENT ===" -ForegroundColor Red
Write-Host ""

Write-Host "1. Capturando conteudo da resposta..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing -TimeoutSec 10
    
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Content-Type: $($response.Headers['Content-Type'])" -ForegroundColor Gray
    Write-Host "   Content Length: $($response.Content.Length) bytes" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "2. Primeiros 500 caracteres do conteudo:" -ForegroundColor Yellow
    $preview = $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length))
    Write-Host $preview -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "3. Procurando por elementos especificos:" -ForegroundColor Yellow
    
    if ($response.Content -match "<!DOCTYPE html>") {
        Write-Host "   DOCTYPE: ENCONTRADO" -ForegroundColor Green
    } else {
        Write-Host "   DOCTYPE: NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "<title>") {
        Write-Host "   TITLE: ENCONTRADO" -ForegroundColor Green
    } else {
        Write-Host "   TITLE: NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "Login") {
        Write-Host "   'Login': ENCONTRADO" -ForegroundColor Green
    } else {
        Write-Host "   'Login': NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "CPF") {
        Write-Host "   'CPF': ENCONTRADO" -ForegroundColor Green
    } else {
        Write-Host "   'CPF': NAO ENCONTRADO" -ForegroundColor Red
    }
    
    if ($response.Content -match "Senha") {
        Write-Host "   'Senha': ENCONTRADO" -ForegroundColor Green
    } else {
        Write-Host "   'Senha': NAO ENCONTRADO" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "4. Salvando conteudo completo em arquivo..." -ForegroundColor Yellow
    $response.Content | Out-File -FilePath "debug-response.html" -Encoding UTF8
    Write-Host "   Arquivo salvo: debug-response.html" -ForegroundColor Green
    
} catch {
    Write-Host "   ERRO: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== ANALISE ===" -ForegroundColor Magenta
Write-Host "Abra o arquivo debug-response.html para ver o conteudo completo" -ForegroundColor White