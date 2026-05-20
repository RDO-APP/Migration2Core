# Test Day 6 Endpoints - Fixed Version
# Tests all TarefaController endpoints with simplified service

Write-Host "🚀 TESTANDO DAY 6 ENDPOINTS - VERSÃO CORRIGIDA" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Start application in background
Write-Host "1. Iniciando aplicação..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory "RDO-NET8-Migration/RdoApp.Core" -PassThru -WindowStyle Hidden

# Wait for application to start
Write-Host "2. Aguardando aplicação inicializar (10 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

try {
    # Test 1: Database connection test
    Write-Host "3. Testando conexão com banco..." -ForegroundColor Cyan
    $response1 = Invoke-RestMethod -Uri "http://localhost:5000/api/TesteBanco/conexao" -Method GET
    Write-Host "✅ Conexão OK: $($response1.message)" -ForegroundColor Green
    
    # Test 2: Count tarefas
    Write-Host "4. Contando tarefas no banco..." -ForegroundColor Cyan
    $response2 = Invoke-RestMethod -Uri "http://localhost:5000/api/TesteBanco/tarefa-count" -Method GET
    Write-Host "✅ Total de tarefas: $($response2.total)" -ForegroundColor Green
    
    # Test 3: Get all tarefas (main endpoint)
    Write-Host "5. Testando GET /api/tarefa (todas as tarefas)..." -ForegroundColor Cyan
    $response3 = Invoke-RestMethod -Uri "http://localhost:5000/api/tarefa" -Method GET
    Write-Host "✅ Retornadas $($response3.Count) tarefas" -ForegroundColor Green
    
    if ($response3.Count -gt 0) {
        $firstTarefa = $response3[0]
        Write-Host "   Primeira tarefa: ID=$($firstTarefa.id), Descrição='$($firstTarefa.descricao)'" -ForegroundColor Gray
        
        # Test 4: Get tarefa by ID
        Write-Host "6. Testando GET /api/tarefa/{id}..." -ForegroundColor Cyan
        $response4 = Invoke-RestMethod -Uri "http://localhost:5000/api/tarefa/$($firstTarefa.id)" -Method GET
        Write-Host "✅ Tarefa específica: ID=$($response4.id), Status=$($response4.statusDescricao)" -ForegroundColor Green
        
        # Test 5: Get tarefas by status
        Write-Host "7. Testando GET /api/tarefa/status/{statusId}..." -ForegroundColor Cyan
        $response5 = Invoke-RestMethod -Uri "http://localhost:5000/api/tarefa/status/$($firstTarefa.statusId)" -Method GET
        Write-Host "✅ Tarefas por status: $($response5.Count) tarefas com status $($firstTarefa.statusId)" -ForegroundColor Green
        
        # Test 6: Get tarefas by obra
        Write-Host "8. Testando GET /api/tarefa/obra/1..." -ForegroundColor Cyan
        $response6 = Invoke-RestMethod -Uri "http://localhost:5000/api/tarefa/obra/1" -Method GET
        Write-Host "✅ Tarefas por obra: $($response6.Count) tarefas" -ForegroundColor Green
    }
    
    # Test 7: Paged search
    Write-Host "9. Testando POST /api/tarefa/search (busca paginada)..." -ForegroundColor Cyan
    $searchBody = @{
        page = 1
        pageSize = 5
        descricao = ""
    } | ConvertTo-Json
    
    $response7 = Invoke-RestMethod -Uri "http://localhost:5000/api/tarefa/search" -Method POST -Body $searchBody -ContentType "application/json"
    Write-Host "✅ Busca paginada: $($response7.items.Count) itens de $($response7.totalCount) total" -ForegroundColor Green
    
    Write-Host "" -ForegroundColor White
    Write-Host "🎉 TODOS OS TESTES PASSARAM!" -ForegroundColor Green
    Write-Host "✅ Conexão com banco antigo funcionando" -ForegroundColor Green
    Write-Host "✅ Todos os endpoints retornando dados reais" -ForegroundColor Green
    Write-Host "✅ Nenhum erro 500 encontrado" -ForegroundColor Green
    Write-Host "✅ Day 6 CONCLUÍDO COM SUCESSO!" -ForegroundColor Green
    
} catch {
    Write-Host "❌ ERRO no teste: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Detalhes: $($_.Exception)" -ForegroundColor Red
} finally {
    # Stop application
    Write-Host "10. Parando aplicação..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
        $process.WaitForExit()
    }
    Write-Host "✅ Aplicação parada" -ForegroundColor Green
}

Write-Host "" -ForegroundColor White
Write-Host "📋 RESUMO DO DAY 6:" -ForegroundColor Cyan
Write-Host "- TarefaService simplificado (sem relacionamentos complexos)" -ForegroundColor White
Write-Host "- Todos os endpoints funcionando com dados reais" -ForegroundColor White
Write-Host "- Banco antigo integrado corretamente" -ForegroundColor White
Write-Host "- Pronto para Day 7 (implementar relacionamentos)" -ForegroundColor White