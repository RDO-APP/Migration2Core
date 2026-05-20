# Teste rápido Day 6 - Entidades corrigidas
Write-Host "=== TESTE DAY 6 - ENTIDADES CORRIGIDAS ===" -ForegroundColor Green

$baseUrl = "http://localhost:5031"

Write-Host "`n1. Testando conexão básica..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/teste/conexao" -Method GET
    Write-Host "✅ Conexão OK: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro na conexão: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n2. Testando endpoint de tarefas..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/api/tarefa" -Method GET
    Write-Host "✅ Endpoint tarefas OK - Retornou $($response.Count) registros" -ForegroundColor Green
    
    if ($response.Count -gt 0) {
        $primeira = $response[0]
        Write-Host "   Primeira tarefa: ID=$($primeira.id), Descrição=$($primeira.descricao)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Erro no endpoint tarefas: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Testando Swagger..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/swagger" -Method GET
    Write-Host "✅ Swagger OK - Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro no Swagger: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== TESTE CONCLUÍDO ===" -ForegroundColor Green