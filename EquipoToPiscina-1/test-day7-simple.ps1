# Test Day 7 Real Relationships - Simple Version
Write-Host "Testing Day 7 Real Relationships..." -ForegroundColor Green

try {
    # Test specific tarefa with real relationships
    Write-Host "Testing GET /api/tarefa/4827..." -ForegroundColor Cyan
    $tarefa = Invoke-RestMethod -Uri "http://localhost:5031/api/tarefa/4827" -Method GET
    Write-Host "Tarefa ID: $($tarefa.id)" -ForegroundColor Green
    Write-Host "Status: '$($tarefa.statusDescricao)' (REAL DATA!)" -ForegroundColor Yellow
    Write-Host "Etapa: '$($tarefa.etapaDescricao)' (REAL DATA!)" -ForegroundColor Yellow
    Write-Host "Obra: '$($tarefa.obraDescricao)' (REAL DATA!)" -ForegroundColor Yellow
    Write-Host "Colaborador: '$($tarefa.colaboradorInsercaoNome)' (REAL DATA!)" -ForegroundColor Yellow
    
    # Test all tarefas
    Write-Host "Testing GET /api/tarefa..." -ForegroundColor Cyan
    $allTarefas = Invoke-RestMethod -Uri "http://localhost:5031/api/tarefa" -Method GET
    Write-Host "Total tarefas: $($allTarefas.Count)" -ForegroundColor Green
    
    if ($allTarefas.Count -gt 0) {
        $first = $allTarefas[0]
        Write-Host "First tarefa status: '$($first.statusDescricao)'" -ForegroundColor Gray
        Write-Host "First tarefa etapa: '$($first.etapaDescricao)'" -ForegroundColor Gray
    }
    
    Write-Host "DAY 7 SUCCESS - Real relationships working!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}