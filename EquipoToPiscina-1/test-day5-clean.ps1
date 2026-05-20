# Day 5 - Teste dos Endpoints
Write-Host "TESTANDO DAY 5 - ENDPOINTS" -ForegroundColor Green

$baseUrl = "http://localhost:5031/api/teste"

# Teste 1: Conexao
Write-Host "`nTestando Conexao..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/conexao" -Method GET
    Write-Host "SUCESSO - Conexao OK!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 2) -ForegroundColor Cyan
} catch {
    Write-Host "ERRO na conexao: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 2: Day 5 Migration Ready
Write-Host "`nTestando Day 5 Migration Ready..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/day5-migration-ready" -Method GET
    Write-Host "SUCESSO - Day 5 Migration Ready!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
}

# Teste 3: Validacao Completa
Write-Host "`nTestando Validacao Completa..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/validate-all-entities" -Method GET
    Write-Host "SUCESSO - Validacao Completa OK!" -ForegroundColor Green
    Write-Host ($response | ConvertTo-Json -Depth 3) -ForegroundColor Cyan
} catch {
    Write-Host "ERRO: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nTESTES CONCLUIDOS!" -ForegroundColor Green