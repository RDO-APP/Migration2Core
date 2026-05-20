# Day 5 - Teste Simples dos Endpoints
Write-Host "🚀 TESTANDO DAY 5 - ENDPOINTS" -ForegroundColor Green

$baseUrl = "http://localhost:5031/api/teste"

# Teste 1: Conexão
Write-Host "`n📡 Testando Conexão..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/conexao" -Method GET
    Write-Host "✅ Conexão OK!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 2) -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erro na conexão: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 2: Day 5 Migration Ready
Write-Host "`n📡 Testando Day 5 Migration Ready..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/day5-migration-ready" -Method GET
    Write-Host "✅ Day 5 Migration Ready!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 3: Validação Completa
Write-Host "`n📡 Testando Validação Completa..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/validate-all-entities" -Method GET
    Write-Host "✅ Validação Completa OK!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 TESTES CONCLUÍDOS!" -ForegroundColor Green