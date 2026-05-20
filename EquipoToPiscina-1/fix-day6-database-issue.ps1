# Fix Day 6 - Problema do Banco de Dados
Write-Host "=== FIX DAY 6 - PROBLEMA DO BANCO ===" -ForegroundColor Green

Write-Host "`n1. Matando processos RdoApp.Core..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*" -and $_.MainWindowTitle -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "`n2. Limpando arquivos temporários..." -ForegroundColor Yellow
Remove-Item "RDO-NET8-Migration\RdoApp.Core\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "RDO-NET8-Migration\RdoApp.Core\obj" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n3. Testando se aplicação está rodando..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/api/teste/conexao" -Method GET -TimeoutSec 5
    Write-Host "✅ Aplicação está rodando! Status: $($response.StatusCode)" -ForegroundColor Green
    
    Write-Host "`n4. Testando endpoint de tarefas..." -ForegroundColor Yellow
    $tarefas = Invoke-RestMethod -Uri "http://localhost:5031/api/tarefa" -Method GET -TimeoutSec 10
    Write-Host "✅ Endpoint tarefas funcionando! Retornou $($tarefas.Count) registros" -ForegroundColor Green
    
    if ($tarefas.Count -gt 0) {
        Write-Host "   Primeira tarefa: $($tarefas[0].descricao)" -ForegroundColor Cyan
    }
    
} catch {
    Write-Host "❌ Aplicação não está rodando. Iniciando..." -ForegroundColor Red
    
    Write-Host "`n5. Compilando projeto..." -ForegroundColor Yellow
    Set-Location "RDO-NET8-Migration\RdoApp.Core"
    dotnet build --no-restore
    
    Write-Host "`n6. Iniciando aplicação..." -ForegroundColor Yellow
    Start-Process -FilePath "dotnet" -ArgumentList "run --urls http://localhost:5031" -WindowStyle Hidden
    
    Write-Host "Aguardando 10 segundos para aplicação iniciar..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5031/api/teste/conexao" -Method GET -TimeoutSec 5
        Write-Host "✅ Aplicação iniciada com sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Falha ao iniciar aplicação" -ForegroundColor Red
    }
}

Write-Host "`n=== TESTE BROWSER ===" -ForegroundColor Green
Write-Host "Abra no browser: http://localhost:5031/swagger" -ForegroundColor Cyan
Write-Host "Teste endpoint: http://localhost:5031/api/tarefa" -ForegroundColor Cyan