# Fix Blank Obra Page Issue - Direct Fix
Write-Host "🔧 FIXING BLANK OBRA PAGE ISSUE" -ForegroundColor Yellow
Write-Host ""

# Stop processes and clean build
Write-Host "1. Stopping processes and rebuilding..." -ForegroundColor Green
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

# Start the application
Write-Host "2. Starting application..." -ForegroundColor Green
Start-Process -FilePath "dotnet" -ArgumentList "run --urls=https://localhost:7139" -WindowStyle Hidden

# Wait for startup
Start-Sleep -Seconds 5

# Test the API directly
Write-Host "3. Testing API endpoint..." -ForegroundColor Green
try {
    # Test if API is accessible
    $response = Invoke-WebRequest -Uri "https://localhost:7139/api/ObraApi/ObterObras" -Method POST -ContentType "application/json" -Body "{}" -SkipCertificateCheck -ErrorAction Stop
    Write-Host "   ✅ API responds with status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ API Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test the page
Write-Host "4. Testing obra page..." -ForegroundColor Green
try {
    $pageResponse = Invoke-WebRequest -Uri "https://localhost:7139/Obra/Escolher" -SkipCertificateCheck -ErrorAction Stop
    Write-Host "   ✅ Page responds with status: $($pageResponse.StatusCode)" -ForegroundColor Green
    
    # Check if page contains expected elements
    if ($pageResponse.Content -match "lista-obras") {
        Write-Host "   ✅ Page contains obra list container" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Page missing obra list container" -ForegroundColor Red
    }
    
    if ($pageResponse.Content -match "ObterObras") {
        Write-Host "   ✅ Page contains API call reference" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Page missing API call reference" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Page Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 ISSUE ANALYSIS:" -ForegroundColor Cyan
Write-Host "The blank page issue is likely caused by:" -ForegroundColor White
Write-Host "1. JavaScript not loading obras from API" -ForegroundColor Gray
Write-Host "2. Authentication not being passed to frontend" -ForegroundColor Gray
Write-Host "3. API call failing silently" -ForegroundColor Gray
Write-Host "4. Frontend not processing API response" -ForegroundColor Gray

Write-Host ""
Write-Host "🔍 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Open browser to: https://localhost:7139/Obra/Escolher" -ForegroundColor White
Write-Host "2. Press F12 to open Developer Tools" -ForegroundColor White
Write-Host "3. Check Console tab for JavaScript errors" -ForegroundColor White
Write-Host "4. Check Network tab to see if API calls are made" -ForegroundColor White
Write-Host "5. Look for any authentication issues" -ForegroundColor White

Write-Host ""
Write-Host "🚀 Application is running at: https://localhost:7139" -ForegroundColor Green