#!/usr/bin/env pwsh

# KILL TEST: Remove .Include entirely to prove tar_id_obra column mapping is the issue
Write-Host "=== KILL TEST: REMOVING .INCLUDE TO ISOLATE tar_id_obra ISSUE ===" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "🎯 KILL TEST OBJECTIVE:" -ForegroundColor Yellow
Write-Host "If 4 etapas appear after removing .Include, we know the issue is Tarefa entity mapping" -ForegroundColor White

Write-Host "`n1. Compiling with .Include removed..." -ForegroundColor Cyan
try {
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project compiles successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation errors:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Starting application for KILL TEST..." -ForegroundColor Cyan
Write-Host "🚀 Running dotnet run..." -ForegroundColor Yellow

# Start the application in background
$process = Start-Process "dotnet" -ArgumentList "run" -PassThru -NoNewWindow

# Wait for startup
Start-Sleep -Seconds 8

Write-Host "`n✅ Application should be running now" -ForegroundColor Green

Write-Host "`n🎯 KILL TEST INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Open browser to: https://localhost:7201" -ForegroundColor White
Write-Host "2. Login with test credentials" -ForegroundColor White  
Write-Host "3. Select obra 233 (the one with 4 etapas)" -ForegroundColor White
Write-Host "4. Navigate to Etapas page" -ForegroundColor White

Write-Host "`n🔍 EXPECTED RESULTS:" -ForegroundColor Yellow
Write-Host "SUCCESS: 4 etapas appear (880, 881, 883, 884) - proves tar_id_obra mapping issue" -ForegroundColor Green
Write-Host "FAILURE: Still empty page - indicates different issue" -ForegroundColor Red

Write-Host "`n📊 DEBUG LOGS TO WATCH:" -ForegroundColor Yellow
Write-Host "Look for in Visual Studio Output:" -ForegroundColor White
Write-Host "- 'Etapas encontradas no banco: 4'" -ForegroundColor Gray
Write-Host "- 'KILL TEST: etapa.Tarefas is NULL (expected)'" -ForegroundColor Gray
Write-Host "- 'RESULTADO FINAL: 4 etapas no ViewModel'" -ForegroundColor Gray
Write-Host "- 'FORCE DEBUG: Model count = 4'" -ForegroundColor Gray

Write-Host "`n⚠️  IMPORTANT:" -ForegroundColor Red
Write-Host "Etapas will show with 0 tarefas (expected since .Include removed)" -ForegroundColor White
Write-Host "The goal is to see if the 4 ETAPAS themselves appear" -ForegroundColor White

Write-Host "`nPress ENTER when you've completed the KILL TEST..." -ForegroundColor Cyan
Read-Host

# Stop the application
if ($process -and !$process.HasExited) {
    $process.Kill()
    Write-Host "🛑 Application stopped" -ForegroundColor Yellow
}

Write-Host "`n=== KILL TEST RESULTS ===" -ForegroundColor Green
Write-Host "Please report:" -ForegroundColor Yellow
Write-Host "✅ SUCCESS: 4 etapas appeared → tar_id_obra mapping issue confirmed" -ForegroundColor Green
Write-Host "❌ FAILURE: Still empty → different issue (not tar_id_obra)" -ForegroundColor Red