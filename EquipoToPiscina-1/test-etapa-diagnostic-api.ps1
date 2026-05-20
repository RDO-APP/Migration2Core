# ETAPA DIAGNOSTIC API TEST
# Tests the EtapaDiagnosticController endpoints to identify the root cause of empty results

Write-Host "=== ETAPA DIAGNOSTIC API TEST ===" -ForegroundColor Yellow
Write-Host "Testing EtapaService database connection and queries via API..." -ForegroundColor Green

# Base URL for the application
$baseUrl = "https://localhost:7001"  # Adjust port if needed
$apiBase = "$baseUrl/api/EtapaDiagnostic"

Write-Host "`n=== TEST 1: Database Connection ===" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$apiBase/test-connection" -Method GET -ContentType "application/json"
    Write-Host "✅ Connection Test Result:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host
} catch {
    Write-Host "❌ Connection Test Failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== TEST 2: Etapa Count ===" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$apiBase/test-etapa-count" -Method GET -ContentType "application/json"
    Write-Host "✅ Etapa Count Result:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host
} catch {
    Write-Host "❌ Etapa Count Test Failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== TEST 3: Etapa Details for ObraId=1 ===" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$apiBase/test-etapa-details/1" -Method GET -ContentType "application/json"
    Write-Host "✅ Etapa Details Result:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host
} catch {
    Write-Host "❌ Etapa Details Test Failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== TEST 4: Include Tarefas for ObraId=1 ===" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$apiBase/test-include-tarefas/1" -Method GET -ContentType "application/json"
    Write-Host "✅ Include Tarefas Result:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host
} catch {
    Write-Host "❌ Include Tarefas Test Failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== TEST 5: Raw SQL for ObraId=1 ===" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$apiBase/test-raw-sql/1" -Method GET -ContentType "application/json"
    Write-Host "✅ Raw SQL Result:" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 3 | Write-Host
} catch {
    Write-Host "❌ Raw SQL Test Failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host "`n=== DIAGNOSTIC COMPLETE ===" -ForegroundColor Yellow
Write-Host "Analysis:" -ForegroundColor White
Write-Host "1. If connection test fails → Database connectivity issue" -ForegroundColor Gray
Write-Host "2. If etapa count shows 0 for ObraId=1 → Wrong ObraId or no data" -ForegroundColor Gray
Write-Host "3. If raw SQL works but EF doesn't → Entity Framework configuration issue" -ForegroundColor Gray
Write-Host "4. If include test fails → Navigation property configuration issue" -ForegroundColor Gray

Write-Host "`nTo run this test:" -ForegroundColor Yellow
Write-Host "1. Start the application (F5 in Visual Studio)" -ForegroundColor White
Write-Host "2. Run this PowerShell script" -ForegroundColor White
Write-Host "3. Compare results with DBeaver data" -ForegroundColor White