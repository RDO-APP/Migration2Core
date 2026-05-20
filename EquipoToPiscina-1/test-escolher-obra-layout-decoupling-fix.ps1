# TEST: ESCOLHER OBRA Layout Decoupling Fix
# Verify that ESCOLHER OBRA is now using _LayoutSelection.cshtml instead of legacy _Layout.cshtml

Write-Host "=== ESCOLHER OBRA LAYOUT DECOUPLING FIX ===" -ForegroundColor Cyan

# Step 1: Clean rebuild to ensure changes take effect
Write-Host "Step 1: Clean rebuild..." -ForegroundColor Yellow
Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "RdoApp.Core" -Force -ErrorAction SilentlyContinue

Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet clean
dotnet build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful" -ForegroundColor Green

# Step 2: Start application
Write-Host "Step 2: Starting application..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -NoNewWindow -PassThru

# Wait for startup
Start-Sleep -Seconds 10

# Step 3: Test the fix
Write-Host "Step 3: Testing ESCOLHER OBRA layout decoupling..." -ForegroundColor Yellow

try {
    # Test ESCOLHER OBRA page directly (will redirect to login if not authenticated)
    $response = Invoke-WebRequest -Uri "https://localhost:7297/Obra/Escolher" -UseBasicParsing -ErrorAction SilentlyContinue
    
    if ($response) {
        Write-Host "ESCOLHER OBRA page status: $($response.StatusCode)" -ForegroundColor Green
        
        # CRITICAL TEST: Check for layout identification comment
        if ($response.Content -match "_LayoutSelection.cshtml is being used") {
            Write-Host "✅ SUCCESS: _LayoutSelection.cshtml is being used!" -ForegroundColor Green
        } elseif ($response.Content -match "_Layout.cshtml is being used") {
            Write-Host "❌ FAILURE: Still using legacy _Layout.cshtml" -ForegroundColor Red
        } else {
            Write-Host "⚠️ Layout identification comment not found" -ForegroundColor Yellow
        }
        
        # CRITICAL TEST: Task counter should NOT be present
        if ($response.Content -match "TAREFA\(S\) SELECIONADA\(S\)") {
            Write-Host "❌ FAILURE: Task counter found (legacy layout contamination)" -ForegroundColor Red
        } else {
            Write-Host "✅ SUCCESS: No task counter found (correct layout)" -ForegroundColor Green
        }
        
        # CRITICAL TEST: UnifiedRdoHeader should be present
        if ($response.Content -match "Piscinas") {
            Write-Host "✅ SUCCESS: UnifiedRdoHeader component found" -ForegroundColor Green
        } else {
            Write-Host "❌ FAILURE: UnifiedRdoHeader component not found" -ForegroundColor Red
        }
        
        # CRITICAL TEST: Blazor Server script should be present
        if ($response.Content -match "_framework/blazor.server.js") {
            Write-Host "✅ SUCCESS: Blazor Server runtime found" -ForegroundColor Green
        } else {
            Write-Host "❌ FAILURE: Blazor Server runtime not found" -ForegroundColor Red
        }
        
        # CRITICAL TEST: RDO Unified Theme CSS should be present
        if ($response.Content -match "rdo-unified-theme.css") {
            Write-Host "✅ SUCCESS: RDO Unified Theme CSS found" -ForegroundColor Green
        } else {
            Write-Host "❌ FAILURE: RDO Unified Theme CSS not found" -ForegroundColor Red
        }
        
        # CRITICAL TEST: Blazor CSS Bundle should be present
        if ($response.Content -match "_content/RdoApp.Core/RdoApp.Core.styles.css") {
            Write-Host "✅ SUCCESS: Blazor CSS Bundle found" -ForegroundColor Green
        } else {
            Write-Host "❌ FAILURE: Blazor CSS Bundle not found" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ Could not reach ESCOLHER OBRA page" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error testing ESCOLHER OBRA page: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Test other pages to ensure they still use legacy layout
Write-Host "Step 4: Testing other pages still use legacy layout..." -ForegroundColor Yellow

try {
    # Test a page that should still use legacy layout (like Home)
    $homeResponse = Invoke-WebRequest -Uri "https://localhost:7297/Home/Index" -UseBasicParsing -ErrorAction SilentlyContinue
    
    if ($homeResponse) {
        if ($homeResponse.Content -match "_Layout.cshtml is being used") {
            Write-Host "✅ SUCCESS: Other pages still use legacy layout" -ForegroundColor Green
        } else {
            Write-Host "⚠️ Other pages may have been affected" -ForegroundColor Yellow
        }
    }
    
} catch {
    Write-Host "⚠️ Could not test other pages" -ForegroundColor Yellow
}

Write-Host "=== TEST COMPLETE ===" -ForegroundColor Cyan
Write-Host "If all tests pass, the 'Skeleton Render' should be eliminated!" -ForegroundColor Green
Write-Host "Check browser: ESCOLHER OBRA should now show proper header and obra cards" -ForegroundColor Yellow

# Clean up
Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
Set-Location "../.."