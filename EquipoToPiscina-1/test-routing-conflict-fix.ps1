#!/usr/bin/env pwsh

Write-Host "🔧 ROUTING CONFLICT FIX TEST" -ForegroundColor Cyan
Write-Host "Testing Pure Blazor routing vs MVC routing conflicts" -ForegroundColor Yellow
Write-Host ""

# Stop any running processes first
Write-Host "🛑 Stopping any running RDO processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" -and $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force -ErrorAction SilentlyContinue

# Clean and build
Write-Host "🧹 Cleaning and building project..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Clean build artifacts
Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue

# Build project
dotnet build --configuration Debug --verbosity minimal

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed! Cannot test routing." -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Write-Host "✅ Build successful!" -ForegroundColor Green

# Start the application
Write-Host "🚀 Starting application..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Debug" -WindowStyle Hidden

# Wait for application to start
Write-Host "⏳ Waiting for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test URLs
$testUrls = @(
    @{
        Name = "OLD MVC URL (should redirect)"
        Url = "https://localhost:5001/etapa/cards-blazor/233"
        ExpectedBehavior = "Should redirect to /blazor-etapa-cards/233"
    },
    @{
        Name = "NEW BLAZOR URL (should work)"
        Url = "https://localhost:5001/blazor-etapa-cards/233"
        ExpectedBehavior = "Should load Pure Blazor component with _LayoutBlazor"
    }
)

Write-Host ""
Write-Host "🧪 ROUTING TESTS:" -ForegroundColor Cyan

foreach ($test in $testUrls) {
    Write-Host ""
    Write-Host "Testing: $($test.Name)" -ForegroundColor Yellow
    Write-Host "URL: $($test.Url)" -ForegroundColor Gray
    Write-Host "Expected: $($test.ExpectedBehavior)" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $test.Url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        
        # Check if response contains Pure Blazor indicators
        $isPureBlazor = $response.Content -match "Pure Blazor Layout Active" -and 
                       $response.Content -match "_framework/blazor.server.js" -and
                       $response.Content -notmatch "bootstrap-compatibility.js"
        
        if ($isPureBlazor) {
            Write-Host "✅ SUCCESS: Pure Blazor component loaded!" -ForegroundColor Green
            Write-Host "   - Found 'Pure Blazor Layout Active' indicator" -ForegroundColor Green
            Write-Host "   - Found Blazor Server JavaScript" -ForegroundColor Green
            Write-Host "   - No legacy JavaScript detected" -ForegroundColor Green
        } else {
            Write-Host "❌ FAILED: Legacy MVC view still loading" -ForegroundColor Red
            if ($response.Content -match "bootstrap-compatibility.js") {
                Write-Host "   - Found legacy bootstrap-compatibility.js" -ForegroundColor Red
            }
            if ($response.Content -notmatch "_framework/blazor.server.js") {
                Write-Host "   - Missing Blazor Server JavaScript" -ForegroundColor Red
            }
        }
        
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Gray
    }
    catch {
        Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🌐 MANUAL BROWSER TEST:" -ForegroundColor Cyan
Write-Host "1. Open browser to: https://localhost:5001/blazor-etapa-cards/233" -ForegroundColor Yellow
Write-Host "2. Check browser console for:" -ForegroundColor Yellow
Write-Host "   ✅ 'PURE BLAZOR LAYOUT: Loaded successfully'" -ForegroundColor Green
Write-Host "   ✅ 'Zero legacy JavaScript dependencies'" -ForegroundColor Green
Write-Host "   ❌ NO 404 errors for missing scripts" -ForegroundColor Red
Write-Host "3. Verify page shows Pure Blazor Layout Active indicator" -ForegroundColor Yellow
Write-Host "4. Test (+) button on task cards - should open modal without errors" -ForegroundColor Yellow

Write-Host ""
Write-Host "🔍 DEBUGGING COMMANDS:" -ForegroundColor Cyan
Write-Host "If routing still conflicts, run:" -ForegroundColor Yellow
Write-Host "  dotnet run --urls https://localhost:5001" -ForegroundColor Gray
Write-Host "  Then check browser network tab for redirect behavior" -ForegroundColor Gray

Set-Location "../.."
Write-Host ""
Write-Host "🎯 ROUTING CONFLICT FIX TEST COMPLETE" -ForegroundColor Cyan