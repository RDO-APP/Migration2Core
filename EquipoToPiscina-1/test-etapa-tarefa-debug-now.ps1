#!/usr/bin/env pwsh

Write-Host "🔍 Teste Debug: Etapa/Tarefa Empty Page" -ForegroundColor Yellow
Write-Host "=" * 60

Write-Host "`n📋 Passos para diagnóstico:" -ForegroundColor Cyan
Write-Host "1. Execute investigate-empty-etapas-page.sql no DBeaver primeiro" -ForegroundColor Yellow
Write-Host "2. Compilar e executar aplicação com debug logs" -ForegroundColor Yellow
Write-Host "3. Acessar página Etapas/Tarefas" -ForegroundColor Yellow
Write-Host "4. Verificar logs no console" -ForegroundColor Yellow

Write-Host "`n🔧 Compilando aplicação..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    dotnet build --no-restore
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilação bem-sucedida" -ForegroundColor Green
        
        Write-Host "`n🚀 Iniciando aplicação..." -ForegroundColor Cyan
        Write-Host "Acesse: https://localhost:7001" -ForegroundColor Yellow
        Write-Host "Faça login e vá para Etapas/Tarefas" -ForegroundColor Yellow
        Write-Host "Verifique os logs no console abaixo:" -ForegroundColor Yellow
        Write-Host "=" * 60
        
        # Executar aplicação
        dotnet run --no-build
    } else {
        Write-Host "❌ Erro na compilação" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location "..\..\"
}