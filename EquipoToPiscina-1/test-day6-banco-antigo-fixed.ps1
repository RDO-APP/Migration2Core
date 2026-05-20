#!/usr/bin/env pwsh

Write-Host "🔧 TESTE DAY 6 - BANCO ANTIGO FIXED" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Navegar para o projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "📦 1. Compilando projeto..." -ForegroundColor Yellow
dotnet build --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro na compilação!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Compilação OK!" -ForegroundColor Green

Write-Host "🚀 2. Iniciando aplicação..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -NoNewWindow -PassThru

# Aguardar inicialização
Start-Sleep -Seconds 8

Write-Host "🧪 3. Testando endpoints..." -ForegroundColor Yellow

# Teste 1: Conexão direta com banco
Write-Host "   📡 Testando conexão direta..." -ForegroundColor Cyan
try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:5000/api/TesteBanco/conexao" -Method GET
    Write-Host "   ✅ Conexão: $($response1.message)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erro na conexão: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 2: Contar tarefas
Write-Host "   📊 Contando tarefas..." -ForegroundColor Cyan
try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:5000/api/TesteBanco/tarefa-count" -Method GET
    Write-Host "   ✅ Total de tarefas: $($response2.total)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erro ao contar: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 3: Buscar tarefas via Entity Framework (NOVO)
Write-Host "   🎯 Testando TarefaController (Entity Framework)..." -ForegroundColor Cyan
try {
    $response3 = Invoke-RestMethod -Uri "http://localhost:5000/api/Tarefa" -Method GET
    Write-Host "   ✅ Tarefas via EF: $($response3.Count) registros" -ForegroundColor Green
    
    if ($response3.Count -gt 0) {
        $primeira = $response3[0]
        Write-Host "   📋 Primeira tarefa: ID=$($primeira.id), Desc='$($primeira.descricao)'" -ForegroundColor Cyan
    }
} catch {
    Write-Host "   ❌ Erro no TarefaController: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 4: Buscar tarefa específica
Write-Host "   🔍 Testando busca por ID..." -ForegroundColor Cyan
try {
    $response4 = Invoke-RestMethod -Uri "http://localhost:5000/api/Tarefa/1" -Method GET
    Write-Host "   ✅ Tarefa ID=1: '$($response4.descricao)'" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Erro na busca por ID: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 RESULTADO:" -ForegroundColor Yellow
Write-Host "   - Se todos os testes passaram, Day 6 está FUNCIONANDO!" -ForegroundColor Green
Write-Host "   - Entity Framework agora funciona com banco antigo" -ForegroundColor Green
Write-Host "   - Relacionamentos temporariamente desabilitados" -ForegroundColor Yellow
Write-Host ""
Write-Host "📝 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "   1. Implementar ColaboradorService" -ForegroundColor White
Write-Host "   2. Implementar ObraService" -ForegroundColor White
Write-Host "   3. Gradualmente reativar relacionamentos" -ForegroundColor White

# Parar aplicação
Write-Host "🛑 Parando aplicação..." -ForegroundColor Yellow
Get-Process -Name "dotnet" | Where-Object { $_.MainWindowTitle -eq "" } | Stop-Process -Force

Write-Host "✅ Teste concluído!" -ForegroundColor Green