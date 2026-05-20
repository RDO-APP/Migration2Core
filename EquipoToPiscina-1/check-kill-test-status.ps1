#!/usr/bin/env pwsh

Write-Host "=== KILL TEST STATUS CHECK ===" -ForegroundColor Yellow
Write-Host ""

# Check if application is running
$baseUrl = "http://localhost:5031"

try {
    $response = Invoke-WebRequest -Uri $baseUrl -UseBasicParsing -TimeoutSec 5
    Write-Host "✅ Application is RUNNING on $baseUrl" -ForegroundColor Green
} catch {
    Write-Host "❌ Application is NOT running" -ForegroundColor Red
    Write-Host "Start with: cd RDO-NET8-Migration/RdoApp.Core && dotnet run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== KILL TEST IMPLEMENTATION STATUS ===" -ForegroundColor Cyan

# Check if KILL TEST is implemented
$etapaServicePath = "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/EtapaService.cs"
if (Test-Path $etapaServicePath) {
    $content = Get-Content $etapaServicePath -Raw
    if ($content -match "KILL TEST.*Remove.*Include") {
        Write-Host "✅ KILL TEST is IMPLEMENTED in EtapaService.cs" -ForegroundColor Green
        Write-Host "   - .Include(e => e.Tarefas) has been REMOVED" -ForegroundColor Green
        Write-Host "   - This should eliminate the tar_id_obra column error" -ForegroundColor Green
    } else {
        Write-Host "❌ KILL TEST not found in EtapaService.cs" -ForegroundColor Red
    }
} else {
    Write-Host "❌ EtapaService.cs not found" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Yellow
Write-Host "1. Open browser: $baseUrl/Auth/Login" -ForegroundColor White
Write-Host "2. Login: ricardo / 123456" -ForegroundColor White
Write-Host "3. Select any obra" -ForegroundColor White
Write-Host "4. Check Etapas page for 4 stages (880, 881, 883, 884)" -ForegroundColor White
Write-Host ""
Write-Host "=== EXPECTED RESULTS ===" -ForegroundColor Cyan
Write-Host "✅ SUCCESS: 4 etapas appear (even if empty) = tar_id_obra was the only issue" -ForegroundColor Green
Write-Host "❌ FAILURE: Still empty = there's another issue beyond tar_id_obra" -ForegroundColor Red
Write-Host ""
Write-Host "Opening browser automatically..." -ForegroundColor Green
Start-Process "$baseUrl/Auth/Login"