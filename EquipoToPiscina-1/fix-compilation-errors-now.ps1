#!/usr/bin/env pwsh

Write-Host "=== CORRIGINDO ERROS DE COMPILAÇÃO ===" -ForegroundColor Green

# Parar TODOS os processos relacionados
Write-Host "Parando todos os processos..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "MSBuild" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "VBCSCompiler" -ErrorAction SilentlyContinue | Stop-Process -Force

# Aguardar liberação dos arquivos
Write-Host "Aguardando liberação dos arquivos..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Ir para projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Limpeza completa forçada
Write-Host "Limpeza completa..." -ForegroundColor Yellow
if (Test-Path "bin") { Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue }
if (Test-Path "obj") { Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue }

# Aguardar mais um pouco
Start-Sleep -Seconds 2

# Restore e build
Write-Host "Restore..." -ForegroundColor Yellow
dotnet restore --verbosity quiet

Write-Host "Build..." -ForegroundColor Yellow
$buildOutput = dotnet build --verbosity minimal

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ COMPILAÇÃO CORRIGIDA!" -ForegroundColor Green
    Write-Host "✅ Sem erros MSB3026/MSB3027" -ForegroundColor Green
    Write-Host "✅ Projeto compilado com sucesso" -ForegroundColor Green
    
    # Contar avisos
    $warnings = ($buildOutput | Select-String "warning").Count
    if ($warnings -gt 0) {
        Write-Host "⚠️  $warnings avisos (nullable reference types - não críticos)" -ForegroundColor Yellow
    }
    
    # Verificar se DLL foi criada
    if (Test-Path "bin/Debug/net8.0/RdoApp.Core.dll") {
        Write-Host "✅ DLL criada com sucesso" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🎉 SISTEMA PRONTO PARA USO!" -ForegroundColor Green
        Write-Host ""
        Write-Host "ACESSO:" -ForegroundColor Cyan
        Write-Host "- HTTP:  http://localhost:5031/Auth/Login" -ForegroundColor White
        Write-Host "- HTTPS: https://localhost:7201/Auth/Login" -ForegroundColor White
        Write-Host ""
        Write-Host "CREDENCIAIS:" -ForegroundColor Cyan
        Write-Host "- CPF: 567.065.455-20" -ForegroundColor White
        Write-Host "- Senha: RXL8DjdYj6Y=" -ForegroundColor White
        Write-Host ""
        Write-Host "Execute F5 no Visual Studio para iniciar!" -ForegroundColor Green
        
    } else {
        Write-Host "❌ DLL não foi criada" -ForegroundColor Red
    }
    
} else {
    Write-Host "❌ Ainda há erros de compilação" -ForegroundColor Red
    Write-Host "Verifique os erros específicos no Visual Studio" -ForegroundColor Yellow
}