# Test ContentResult Motor - Bypass Blazor Middleware
# This tests if ContentResult can bypass the hot-reload middleware blocking

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CONTENTRESULT MOTOR TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill any running processes
Write-Host "Step 1: Stopping any running RdoApp processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "[OK] Processes stopped" -ForegroundColor Green
Write-Host ""

# Step 2: Navigate to project directory
Write-Host "Step 2: Navigating to project directory..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration\RdoApp.Core"
Write-Host "[OK] In project directory" -ForegroundColor Green
Write-Host ""

# Step 3: Build project
Write-Host "Step 3: Building project..." -ForegroundColor Yellow
dotnet build --no-incremental > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Build successful" -ForegroundColor Green
} else {
    Write-Host "[FAIL] Build failed" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Start server in background
Write-Host "Step 4: Starting server..." -ForegroundColor Yellow
$job = Start-Job -ScriptBlock {
    Set-Location "RDO-NET8-Migration\RdoApp.Core"
    dotnet run --no-hot-reload 2>&1
}
Write-Host "[OK] Server starting (Job ID: $($job.Id))" -ForegroundColor Green
Write-Host ""

# Step 5: Wait for server to be ready
Write-Host "Step 5: Waiting for server to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$serverReady = $false

while ($attempt -lt $maxAttempts -and -not $serverReady) {
    Start-Sleep -Seconds 2
    $attempt++
    
    try {
        $response = Invoke-WebRequest -Uri "https://localhost:7201" -SkipCertificateCheck -TimeoutSec 2 -ErrorAction SilentlyContinue
        $serverReady = $true
        Write-Host "[OK] Server is ready (attempt $attempt)" -ForegroundColor Green
    } catch {
        Write-Host "  Waiting... (attempt $attempt/$maxAttempts)" -ForegroundColor Gray
    }
}

if (-not $serverReady) {
    Write-Host "[FAIL] Server failed to start" -ForegroundColor Red
    Stop-Job -Job $job
    Remove-Job -Job $job
    exit 1
}
Write-Host ""

# Step 6: Test ContentResult endpoint
Write-Host "Step 6: Testing ContentResult endpoint..." -ForegroundColor Yellow
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Obra/Escolher" -SkipCertificateCheck -TimeoutSec 10
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "TEST RESULTS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor $(if ($response.StatusCode -eq 200) { "Green" } else { "Red" })
    Write-Host "Content Length: $($response.Content.Length) bytes" -ForegroundColor $(if ($response.Content.Length -gt 0) { "Green" } else { "Red" })
    Write-Host ""
    
    # Check if response contains expected content
    $hasMotorText = $response.Content -match "MOTOR IS RUNNING"
    $hasBlueBackground = $response.Content -match "#0066FF"
    $hasObraCount = $response.Content -match "Obras Loaded:"
    
    Write-Host "Content Checks:" -ForegroundColor Yellow
    Write-Host "  [CHECK] Contains 'MOTOR IS RUNNING': $hasMotorText" -ForegroundColor $(if ($hasMotorText) { "Green" } else { "Red" })
    Write-Host "  [CHECK] Contains blue background: $hasBlueBackground" -ForegroundColor $(if ($hasBlueBackground) { "Green" } else { "Red" })
    Write-Host "  [CHECK] Contains obra count: $hasObraCount" -ForegroundColor $(if ($hasObraCount) { "Green" } else { "Red" })
    Write-Host ""
    
    if ($hasMotorText -and $hasBlueBackground -and $hasObraCount) {
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "[SUCCESS] CONTENTRESULT WORKS!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "CONCLUSION:" -ForegroundColor Cyan
        Write-Host "  • Controller is working correctly" -ForegroundColor White
        Write-Host "  • Service is loading data" -ForegroundColor White
        Write-Host "  • ContentResult bypasses middleware" -ForegroundColor White
        Write-Host "  • Blazor hot-reload was blocking View rendering" -ForegroundColor White
        Write-Host ""
        Write-Host "NEXT STEP:" -ForegroundColor Yellow
        Write-Host "  Restore December 2025 backup with model type fix" -ForegroundColor White
        Write-Host "  and test with ContentResult approach or disable hot-reload" -ForegroundColor White
    } else {
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "[WARNING] PARTIAL SUCCESS" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Response received but content unexpected" -ForegroundColor Yellow
        Write-Host "First 500 chars of response:" -ForegroundColor Gray
        Write-Host $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length)) -ForegroundColor Gray
    }
    
} catch {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "[FAIL] TEST FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Browser URL: https://localhost:7201/Obra/Escolher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to stop server and exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Cleanup
Stop-Job -Job $job
Remove-Job -Job $job
Write-Host "[OK] Server stopped" -ForegroundColor Green
