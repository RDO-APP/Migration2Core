# Test Day 6 Endpoints - Simple Version
Write-Host "Testing Day 6 Endpoints..." -ForegroundColor Green

# Start application
Write-Host "Starting application..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -WorkingDirectory "RDO-NET8-Migration/RdoApp.Core" -PassThru -WindowStyle Hidden

# Wait for startup
Start-Sleep -Seconds 10

try {
    # Test database connection
    Write-Host "Testing database connection..." -ForegroundColor Cyan
    $response1 = Invoke-RestMethod -Uri "http://localhost:5000/api/TesteBanco/conexao" -Method GET
    Write-Host "Connection OK: $($response1.message)" -ForegroundColor Green
    
    # Test get all tarefas
    Write-Host "Testing GET /api/tarefa..." -ForegroundColor Cyan
    $response2 = Invoke-RestMethod -Uri "http://localhost:5000/api/tarefa" -Method GET
    Write-Host "Returned $($response2.Count) tarefas" -ForegroundColor Green
    
    if ($response2.Count -gt 0) {
        $firstTarefa = $response2[0]
        Write-Host "First tarefa: ID=$($firstTarefa.id), Description='$($firstTarefa.descricao)'" -ForegroundColor Gray
        
        # Test get by ID
        Write-Host "Testing GET /api/tarefa/{id}..." -ForegroundColor Cyan
        $response3 = Invoke-RestMethod -Uri "http://localhost:5000/api/tarefa/$($firstTarefa.id)" -Method GET
        Write-Host "Got tarefa by ID: $($response3.id)" -ForegroundColor Green
    }
    
    Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "Day 6 COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Stop application
    if ($process -and !$process.HasExited) {
        $process.Kill()
        $process.WaitForExit()
    }
    Write-Host "Application stopped" -ForegroundColor Green
}