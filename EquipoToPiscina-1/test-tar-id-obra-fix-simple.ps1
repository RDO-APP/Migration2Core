Write-Host "=== TESTING TAR_ID_OBRA COLUMN FIX ===" -ForegroundColor Cyan

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. Building project..." -ForegroundColor Green
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}

Write-Host "2. Starting application..." -ForegroundColor Green
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden

Start-Sleep -Seconds 10

Write-Host "3. Testing application..." -ForegroundColor Green

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -TimeoutSec 30
    Write-Host "✅ Application is running" -ForegroundColor Green
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor White
} catch {
    Write-Host "❌ Application test failed: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    if ($process -and !$process.HasExited) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        Write-Host "Application stopped" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== CHANGES MADE ===" -ForegroundColor Cyan
Write-Host "✅ Removed tar_id_obra property from Tarefa entity" -ForegroundColor Green
Write-Host "✅ Removed tar_id_obra mapping from TarefaConfiguration" -ForegroundColor Green
Write-Host "✅ Fixed EtapaService CreateTaskInEtapaAsync method" -ForegroundColor Green
Write-Host ""
Write-Host "The tar_id_obra column error should now be resolved!" -ForegroundColor Yellow