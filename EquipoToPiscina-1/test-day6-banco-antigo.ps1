#!/usr/bin/env pwsh

Write-Host "🔄 TESTANDO DAY 6 COM BANCO ANTIGO" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Navegar para o projeto
Set-Location "RDO-NET8-Migration\RdoApp.Core"

Write-Host "📍 Diretório atual: $(Get-Location)" -ForegroundColor Yellow

# Verificar se o projeto existe
if (-not (Test-Path "RdoApp.Core.csproj")) {
    Write-Host "❌ Arquivo RdoApp.Core.csproj não encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Projeto encontrado" -ForegroundColor Green

# Compilar o projeto
Write-Host "🔨 Compilando projeto..." -ForegroundColor Yellow
dotnet build --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro na compilação!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Compilação bem-sucedida" -ForegroundColor Green

# Executar o projeto em background
Write-Host "🚀 Iniciando aplicação..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -NoNewWindow -PassThru

# Aguardar alguns segundos para a aplicação iniciar
Write-Host "⏳ Aguardando aplicação iniciar..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Testar endpoints
Write-Host "🧪 Testando endpoints..." -ForegroundColor Yellow

try {
    # Teste 1: Health check básico
    Write-Host "📡 Testando Swagger UI..." -ForegroundColor Cyan
    $swaggerResponse = Invoke-WebRequest -Uri "http://localhost:5000/swagger" -Method GET -TimeoutSec 10
    Write-Host "✅ Swagger UI: $($swaggerResponse.StatusCode)" -ForegroundColor Green
    
    # Teste 2: Endpoint de tarefas
    Write-Host "📡 Testando GET /api/tarefa..." -ForegroundColor Cyan
    $tarefasResponse = Invoke-WebRequest -Uri "http://localhost:5000/api/tarefa" -Method GET -TimeoutSec 15
    Write-Host "✅ GET Tarefas: $($tarefasResponse.StatusCode)" -ForegroundColor Green
    
    # Mostrar primeiros dados
    $tarefasData = $tarefasResponse.Content | ConvertFrom-Json
    Write-Host "📊 Total de tarefas encontradas: $($tarefasData.Count)" -ForegroundColor Cyan
    
    if ($tarefasData.Count -gt 0) {
        Write-Host "📋 Primeira tarefa:" -ForegroundColor Yellow
        Write-Host "   ID: $($tarefasData[0].id)" -ForegroundColor White
        Write-Host "   Descrição: $($tarefasData[0].descricao)" -ForegroundColor White
        Write-Host "   Status: $($tarefasData[0].statusDescricao)" -ForegroundColor White
    }
    
    Write-Host "🎉 TESTE CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
    Write-Host "✅ Banco antigo funcionando perfeitamente" -ForegroundColor Green
    Write-Host "✅ Endpoints respondendo com dados reais" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Erro no teste: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "🔍 Verificando se a aplicação está rodando..." -ForegroundColor Yellow
    
    # Tentar novamente após mais tempo
    Start-Sleep -Seconds 5
    try {
        $retryResponse = Invoke-WebRequest -Uri "http://localhost:5000/api/tarefa" -Method GET -TimeoutSec 10
        Write-Host "✅ Sucesso na segunda tentativa: $($retryResponse.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Falha na segunda tentativa também" -ForegroundColor Red
        Write-Host "💡 Verifique se a aplicação está rodando em http://localhost:5000" -ForegroundColor Yellow
    }
}

Write-Host "🏁 Teste finalizado" -ForegroundColor Cyan