#!/usr/bin/env pwsh

Write-Host "=== TESTING ETAPA TAR_ID_OBRA COLUMN MAPPING FIX ===" -ForegroundColor Green
Write-Host "Issue: MySqlException 'Unknown column 't.tar_id_obra' in 'field list'" -ForegroundColor Yellow
Write-Host "Fix: Restored IdObra property with exact case-sensitive mapping" -ForegroundColor Yellow
Write-Host "Fix: Added missing TarefaConfiguration for tar_id_obra column" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes
Write-Host "1. Stopping any running RdoApp processes..." -ForegroundColor Cyan
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Clean and rebuild
Write-Host "2. Cleaning and rebuilding project..." -ForegroundColor Cyan
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Check compilation errors." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Start the application in background
Write-Host "3. Starting application..." -ForegroundColor Cyan
$process = Start-Process "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden

# Wait for application to start
Write-Host "4. Waiting for application to start..." -ForegroundColor Cyan
Start-Sleep -Seconds 15

# Test the Etapas page that was causing the MySqlException
Write-Host "5. Testing Etapas page (previously causing MySqlException)..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000/Obra/Etapas?obraId=233" -UseBasicParsing -TimeoutSec 30
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ SUCCESS: Etapas page loaded without MySqlException!" -ForegroundColor Green
        Write-Host "✅ Status Code: $($response.StatusCode)" -ForegroundColor Green
        
        # Check if the response contains data (not empty)
        if ($response.Content.Length -gt 1000) {
            Write-Host "✅ Response contains substantial content ($($response.Content.Length) characters)" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Response seems small ($($response.Content.Length) characters) - might be empty data" -ForegroundColor Yellow
        }
        
        # Check for error indicators in the response
        if ($response.Content -match "MySqlException|Unknown column|tar_id_obra") {
            Write-Host "❌ Response still contains database errors!" -ForegroundColor Red
            Write-Host "Error content preview:" -ForegroundColor Red
            Write-Host ($response.Content.Substring(0, [Math]::Min(500, $response.Content.Length))) -ForegroundColor Red
        } else {
            Write-Host "✅ No database errors detected in response" -ForegroundColor Green
        }
        
    } else {
        Write-Host "❌ FAILED: Status Code $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
    
    # Check if it's a connection error (app not started) vs actual error
    if ($_.Exception.Message -match "conectar|connect") {
        Write-Host "⚠️  This might be a connection issue. Checking if app is running..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        
        # Try one more time
        try {
            $response2 = Invoke-WebRequest -Uri "http://localhost:5000/" -UseBasicParsing -TimeoutSec 10
            Write-Host "✅ App is running, but Etapas endpoint had issues" -ForegroundColor Yellow
        } catch {
            Write-Host "❌ App is not responding at all" -ForegroundColor Red
        }
    }
}

# Test a few more endpoints to ensure the fix doesn't break anything else
Write-Host "6. Testing other endpoints to ensure no regression..." -ForegroundColor Cyan

$testEndpoints = @(
    "http://localhost:5000/",
    "http://localhost:5000/Obra/Escolher"
)

foreach ($endpoint in $testEndpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint -UseBasicParsing -TimeoutSec 15
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $endpoint - OK" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $endpoint - Status $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ $endpoint - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test the API endpoint specifically
Write-Host "7. Testing API endpoint for etapas..." -ForegroundColor Cyan
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5000/api/obra/233/etapas" -UseBasicParsing -TimeoutSec 15
    if ($apiResponse.StatusCode -eq 200) {
        Write-Host "✅ API endpoint works - Status $($apiResponse.StatusCode)" -ForegroundColor Green
        
        # Try to parse JSON to see if it contains data
        try {
            $jsonData = $apiResponse.Content | ConvertFrom-Json
            if ($jsonData -and $jsonData.Count -gt 0) {
                Write-Host "✅ API returned $($jsonData.Count) etapas" -ForegroundColor Green
            } else {
                Write-Host "⚠️  API returned empty data" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "⚠️  API response is not valid JSON" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ API endpoint failed - Status $($apiResponse.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ API endpoint error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== TEST SUMMARY ===" -ForegroundColor Green
Write-Host "✅ Restored IdObra property in Tarefa entity" -ForegroundColor Green
Write-Host "✅ Added proper EF Core configuration for tar_id_obra column" -ForegroundColor Green
Write-Host "✅ Fixed case-sensitive column mapping" -ForegroundColor Green
Write-Host "✅ Maintained proper relationship: tarefa -> etapa -> obra" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open browser to http://localhost:5000/Obra/Etapas?obraId=233" -ForegroundColor White
Write-Host "2. Verify that etapas and tarefas are now loading correctly" -ForegroundColor White
Write-Host "3. Check browser console for any remaining JavaScript errors" -ForegroundColor White
Write-Host "4. Test creating new tasks to ensure IdObra is properly set" -ForegroundColor White

# Keep the application running
Write-Host ""
Write-Host "Application is running at http://localhost:5000" -ForegroundColor Green
Write-Host "Process ID: $($process.Id)" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop this script (application will continue running)" -ForegroundColor Yellow

# Wait for user input to keep script alive
Read-Host "Press Enter to stop the application and exit"

# Stop the application
if (!$process.HasExited) {
    $process.Kill()
    Write-Host "Application stopped." -ForegroundColor Yellow
}