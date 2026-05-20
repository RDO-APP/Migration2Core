# Test Blank Page Fix
Write-Host "🔧 TESTING BLANK OBRA PAGE FIX" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes
Write-Host "1. Stopping existing processes..." -ForegroundColor Green
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate and build
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "2. Building project..." -ForegroundColor Green
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Build failed!" -ForegroundColor Red
    exit 1
}

# Start application
Write-Host "3. Starting application..." -ForegroundColor Green
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --urls=https://localhost:7139" -PassThru -WindowStyle Hidden

# Wait for startup
Write-Host "4. Waiting for application startup..." -ForegroundColor Green
Start-Sleep -Seconds 8

# Test the page
Write-Host "5. Testing obra selection page..." -ForegroundColor Green
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7139/Obra/Escolher" -SkipCertificateCheck -ErrorAction Stop
    Write-Host "   ✅ Page loads successfully (Status: $($response.StatusCode))" -ForegroundColor Green
    
    # Check for key elements
    if ($response.Content -match "lista-obras") {
        Write-Host "   ✅ Page contains obra list container" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Page missing obra list container" -ForegroundColor Red
    }
    
    if ($response.Content -match "Selecione uma das unidades escolares") {
        Write-Host "   ✅ Page contains expected title" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Page missing expected title" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ❌ Error accessing page: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 WHAT WAS FIXED:" -ForegroundColor Cyan
Write-Host "• ObraController was trying to call API via HTTP to localhost:5031" -ForegroundColor White
Write-Host "• Changed to call ObraApiController directly via dependency injection" -ForegroundColor White
Write-Host "• This eliminates HTTP call issues and authentication problems" -ForegroundColor White
Write-Host "• Now the controller gets data directly from the API controller" -ForegroundColor White

Write-Host ""
Write-Host "🚀 Application running at: https://localhost:7139" -ForegroundColor Green
Write-Host "📋 Test the page at: https://localhost:7139/Obra/Escolher" -ForegroundColor Cyan

Write-Host ""
Write-Host "⚠️  To stop the application later, run:" -ForegroundColor Yellow
Write-Host "   Get-Process dotnet | Stop-Process -Force" -ForegroundColor Gray