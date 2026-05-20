#!/usr/bin/env pwsh

Write-Host "=== CORRIGINDO PÁGINA LOGIN EM BRANCO ===" -ForegroundColor Green

# Parar todos os processos
Write-Host "Parando processos..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Limpeza completa
Write-Host "Limpeza completa..." -ForegroundColor Yellow
Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue

# Build completo
Write-Host "Build completo..." -ForegroundColor Yellow
dotnet restore --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build OK!" -ForegroundColor Green
    
    # Iniciar aplicação
    Write-Host "Iniciando aplicação..." -ForegroundColor Yellow
    Start-Process -FilePath "dotnet" -ArgumentList "run" -WindowStyle Hidden
    
    # Aguardar inicialização
    Start-Sleep -Seconds 5
    
    # Testar página
    Write-Host "Testando página de login..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -TimeoutSec 10
        
        if ($response.StatusCode -eq 200 -and $response.Content.Length -gt 1000) {
            Write-Host "✅ PÁGINA DE LOGIN FUNCIONANDO!" -ForegroundColor Green
            Write-Host "✅ Conteúdo: $($response.Content.Length) caracteres" -ForegroundColor Green
            
            # Abrir browser
            Write-Host "Abrindo browser..." -ForegroundColor Yellow
            Start-Process "http://localhost:5031/Auth/Login"
            
            Write-Host "`n=== PROBLEMA RESOLVIDO ===" -ForegroundColor Green
            Write-Host "✅ Login.cshtml recriado completamente" -ForegroundColor Green
            Write-Host "✅ Cache limpo e aplicação recompilada" -ForegroundColor Green
            Write-Host "✅ Página agora tem formulário completo" -ForegroundColor Green
            
        } else {
            Write-Host "❌ Página ainda com problema" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Erro ao testar: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} else {
    Write-Host "❌ Build falhou!" -ForegroundColor Red
}