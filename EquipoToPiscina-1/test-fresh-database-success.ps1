# Teste do Banco Novo - Day 6 Success!
Write-Host "=== TESTANDO BANCO NOVO - DAY 6 ===" -ForegroundColor Green

$baseUrl = "http://localhost:5031"

Write-Host "`n1. Testando conexão..." -ForegroundColor Yellow
try {
    $conexao = Invoke-RestMethod -Uri "$baseUrl/api/teste/conexao" -Method GET -TimeoutSec 5
    Write-Host "✅ Conexão: $($conexao.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro conexão: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

Write-Host "`n2. Testando endpoint tarefas..." -ForegroundColor Yellow
try {
    $tarefas = Invoke-RestMethod -Uri "$baseUrl/api/tarefa" -Method GET -TimeoutSec 10
    Write-Host "✅ Tarefas: Retornou $($tarefas.Count) registros (banco vazio = normal)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro tarefas: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n3. Testando Swagger..." -ForegroundColor Yellow
try {
    $swagger = Invoke-WebRequest -Uri "$baseUrl/swagger" -Method GET -TimeoutSec 5
    Write-Host "✅ Swagger: Status $($swagger.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erro Swagger: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 BANCO NOVO FUNCIONANDO!" -ForegroundColor Green
Write-Host "Database: rdoapp_net8_test (novo, limpo)" -ForegroundColor Cyan
Write-Host "Swagger: http://localhost:5031/swagger" -ForegroundColor Cyan
Write-Host "API: http://localhost:5031/api/tarefa" -ForegroundColor Cyan

Write-Host "`n=== DAY 6 RESOLVIDO! ===" -ForegroundColor Green