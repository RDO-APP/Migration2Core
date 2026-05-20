# Test Blazor Circuit & Real Data Fix
# Tests the Pure Blazor page with proper circuit initialization and real data

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BLAZOR CIRCUIT & REAL DATA FIX TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop any running processes
Write-Host "Step 1: Stopping any running processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet", "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 2: Clean and build
Write-Host "Step 2: Building project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration\RdoApp.Core"
dotnet clean --verbosity quiet
dotnet build --no-incremental --verbosity quiet

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Set-Location "..\..\"
    exit 1
}

Write-Host "✅ Build successful" -ForegroundColor Green

# Step 3: Start the application
Write-Host "Step 3: Starting application..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --no-build" -PassThru -NoNewWindow
Start-Sleep -Seconds 8

# Step 4: Test the Blazor page
Write-Host "Step 4: Testing Blazor Circuit..." -ForegroundColor Yellow
Write-Host ""

$testUrl = "https://localhost:7139/blazor-etapa-cards/233"

Write-Host "🔍 Testing URL: $testUrl" -ForegroundColor Cyan
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -SkipCertificateCheck -TimeoutSec 10
    
    Write-Host "✅ Page loaded successfully (Status: $($response.StatusCode))" -ForegroundColor Green
    Write-Host ""
    
    # Check for Blazor script
    if ($response.Content -match '_framework/blazor\.server\.js') {
        Write-Host "✅ Blazor Server script found" -ForegroundColor Green
    } else {
        Write-Host "❌ Blazor Server script NOT found" -ForegroundColor Red
    }
    
    # Check for base href
    if ($response.Content -match '<base href="/"\s*/?>') {
        Write-Host "✅ Base href configured correctly" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Base href may need adjustment" -ForegroundColor Yellow
    }
    
    # Check for component
    if ($response.Content -match 'EtapaCardsPage') {
        Write-Host "✅ Blazor component found" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Blazor component not detected in HTML" -ForegroundColor Yellow
    }
    
    # Check for logo
    if ($response.Content -match 'images/logo\.png') {
        Write-Host "✅ RDO logo path found" -ForegroundColor Green
    } else {
        Write-Host "⚠️  RDO logo path not found" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "MANUAL TESTING REQUIRED" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Open browser to: $testUrl" -ForegroundColor White
    Write-Host "2. Open F12 Console" -ForegroundColor White
    Write-Host "3. Verify NO 404 errors for:" -ForegroundColor White
    Write-Host "   - _framework/blazor.server.js" -ForegroundColor Gray
    Write-Host "   - _blazor/initializers" -ForegroundColor Gray
    Write-Host "4. Verify console shows:" -ForegroundColor White
    Write-Host "   - 🚀 PURE BLAZOR LAYOUT: Loaded successfully" -ForegroundColor Gray
    Write-Host "   - 🔌 Blazor Circuit: Initializing..." -ForegroundColor Gray
    Write-Host "   - ✅ BLAZOR CIRCUIT: Component rendered successfully" -ForegroundColor Gray
    Write-Host "   - 🔥 PRODUCTION REALITY - REAL DATA LOADED" -ForegroundColor Gray
    Write-Host "5. Verify page shows REAL data (not mock)" -ForegroundColor White
    Write-Host "6. Verify RDO logo is visible" -ForegroundColor White
    Write-Host "7. Test (+) button on a task card" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server when done testing" -ForegroundColor Yellow
    Write-Host ""
    
    # Keep process running for manual testing
    Wait-Process -Id $process.Id
    
} catch {
    Write-Host "❌ Error testing page: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "The server is still running. Check the console for errors." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
    
    # Keep process running for debugging
    Wait-Process -Id $process.Id
} finally {
    Set-Location "..\..\"
}
