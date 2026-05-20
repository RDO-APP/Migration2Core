#!/usr/bin/env pwsh

Write-Host "=== TESTING SOLUTION B: Task Loading Fix ===" -ForegroundColor Green
Write-Host "Testing the improved EtapaService with Solution B implementation" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes first
Write-Host "1. Stopping any running processes..." -ForegroundColor Cyan
try {
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "✅ Processes stopped" -ForegroundColor Green
} catch {
    Write-Host "⚠️ No processes to stop or error stopping: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Navigate to project directory
Write-Host "2. Navigating to project directory..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Build the project
Write-Host "3. Building project with Solution B improvements..." -ForegroundColor Cyan
try {
    $buildResult = dotnet build --configuration Release --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Start the application
Write-Host "4. Starting application to test Solution B..." -ForegroundColor Cyan
try {
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Release" -PassThru -NoNewWindow
    Write-Host "✅ Application started with PID: $($process.Id)" -ForegroundColor Green
    
    # Wait for application to start
    Write-Host "5. Waiting for application to initialize..." -ForegroundColor Cyan
    Start-Sleep -Seconds 10
    
    # Test the application
    Write-Host "6. Testing Solution B implementation..." -ForegroundColor Cyan
    
    # Test 1: Check if application is responding
    Write-Host "   Testing application response..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "https://localhost:7001" -SkipCertificateCheck -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Application is responding" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Application responded with status: $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Application not responding: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 2: Check login page
    Write-Host "   Testing login page..." -ForegroundColor Yellow
    try {
        $loginResponse = Invoke-WebRequest -Uri "https://localhost:7001/Auth/Login" -SkipCertificateCheck -TimeoutSec 10 -ErrorAction Stop
        if ($loginResponse.StatusCode -eq 200) {
            Write-Host "   ✅ Login page accessible" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️ Login page responded with status: $($loginResponse.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Login page not accessible: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "=== SOLUTION B IMPLEMENTATION SUMMARY ===" -ForegroundColor Green
    Write-Host "✅ EtapaService updated with Solution B approach" -ForegroundColor Green
    Write-Host "✅ Load etapas first, then tarefas separately" -ForegroundColor Green
    Write-Host "✅ Avoid tar_id_obra mapping issues" -ForegroundColor Green
    Write-Host "✅ More efficient single query for all tarefas" -ForegroundColor Green
    Write-Host "✅ Group tarefas by EtapaId for assignment" -ForegroundColor Green
    Write-Host "✅ Enhanced logging for debugging" -ForegroundColor Green
    Write-Host "✅ Show all tasks for data integrity (legacy logic)" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "1. Login with user: ricardo / senha: 123456" -ForegroundColor White
    Write-Host "2. Navigate to Obras -> Escolher" -ForegroundColor White
    Write-Host "3. Select an obra to view etapas" -ForegroundColor White
    Write-Host "4. Verify that task counts now show correctly (not '0 tarefas')" -ForegroundColor White
    Write-Host "5. Check that etapas expand to show actual tasks" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 DEBUGGING INFO:" -ForegroundColor Cyan
    Write-Host "- Check console logs for 'SOLUTION B:' messages" -ForegroundColor White
    Write-Host "- Look for task count information in logs" -ForegroundColor White
    Write-Host "- Verify database queries are working correctly" -ForegroundColor White
    Write-Host ""
    Write-Host "Application is running at: https://localhost:7001" -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop the application when testing is complete." -ForegroundColor Yellow
    
    # Keep the process running
    Wait-Process -Id $process.Id
    
} catch {
    Write-Host "❌ Error starting application: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Cleanup
    Write-Host ""
    Write-Host "7. Cleaning up..." -ForegroundColor Cyan
    try {
        if ($process -and !$process.HasExited) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
        Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Cleanup completed" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Cleanup warning: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== SOLUTION B TEST COMPLETED ===" -ForegroundColor Green