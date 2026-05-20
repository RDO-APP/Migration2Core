#!/usr/bin/env pwsh

Write-Host "=== DIAGNOSING tar_id_obra Column Issue ===" -ForegroundColor Yellow
Write-Host ""

# Check if application is running
$baseUrl = "http://localhost:5031"

try {
    Write-Host "1. Testing direct database query via API..." -ForegroundColor Green
    
    # Test the diagnostic API endpoint if it exists
    $diagnosticUrl = "$baseUrl/api/EtapaDiagnostic/TestTarefaColumns"
    
    try {
        $response = Invoke-WebRequest -Uri $diagnosticUrl -UseBasicParsing -TimeoutSec 10
        Write-Host "✅ Diagnostic API response: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Response: $($response.Content)" -ForegroundColor White
    } catch {
        Write-Host "⚠️ Diagnostic API not available: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "2. ANALYSIS BASED ON SEARCH RESULTS:" -ForegroundColor Green
    Write-Host "   ✅ Column 'tar_id_obra' EXISTS in production SQL queries" -ForegroundColor Green
    Write-Host "   ✅ Entity mapping is CORRECT: [Column('tar_id_obra')] public int IdObra" -ForegroundColor Green
    Write-Host "   ✅ Fluent API mapping is CORRECT: .HasColumnName('tar_id_obra')" -ForegroundColor Green
    Write-Host ""
    Write-Host "3. LIKELY ROOT CAUSE:" -ForegroundColor Yellow
    Write-Host "   - The column exists, but EF Core's .Include() generates problematic SQL" -ForegroundColor White
    Write-Host "   - Possible case sensitivity issue in MySQL" -ForegroundColor White
    Write-Host "   - Possible AsSplitQuery() issue with column references" -ForegroundColor White
    Write-Host ""
    Write-Host "4. KILL TEST STATUS:" -ForegroundColor Yellow
    Write-Host "   - KILL TEST implemented: .Include(e => e.Tarefas) REMOVED" -ForegroundColor Green
    Write-Host "   - If 4 etapas appear now, confirms tar_id_obra is the ONLY issue" -ForegroundColor Green
    Write-Host ""
    Write-Host "5. NEXT STEPS IF KILL TEST SUCCEEDS:" -ForegroundColor Cyan
    Write-Host "   A) Fix the column mapping in TarefaConfiguration.cs" -ForegroundColor White
    Write-Host "   B) Or use explicit SQL query instead of .Include()" -ForegroundColor White
    Write-Host "   C) Or load Tarefas separately after loading Etapas" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== READY FOR KILL TEST VERIFICATION ===" -ForegroundColor Yellow
Write-Host "Please test the browser and report if 4 etapas appear!" -ForegroundColor Cyan