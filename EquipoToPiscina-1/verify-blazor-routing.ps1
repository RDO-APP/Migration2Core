#!/usr/bin/env pwsh

Write-Host "BLAZOR ROUTING VERIFICATION" -ForegroundColor Cyan
Write-Host ""

# Test the new Blazor URL
$testUrl = "https://localhost:5001/blazor-etapa-cards/233"

Write-Host "Testing URL: $testUrl" -ForegroundColor Yellow

try {
    # Add certificate bypass for localhost testing
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    
    $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Green
    
    # Check for Pure Blazor indicators
    $hasPureBlazorIndicator = $response.Content -match "Pure Blazor Layout Active"
    $hasBlazorJs = $response.Content -match "_framework/blazor.server.js"
    $hasLegacyJs = $response.Content -match "bootstrap-compatibility.js"
    $hasLayoutBlazor = $response.Content -match "_LayoutBlazor"
    
    Write-Host ""
    Write-Host "VERIFICATION RESULTS:" -ForegroundColor Cyan
    
    if ($hasPureBlazorIndicator) {
        Write-Host "✅ Pure Blazor Layout Active indicator found" -ForegroundColor Green
    } else {
        Write-Host "❌ Pure Blazor Layout Active indicator NOT found" -ForegroundColor Red
    }
    
    if ($hasBlazorJs) {
        Write-Host "✅ Blazor Server JavaScript found" -ForegroundColor Green
    } else {
        Write-Host "❌ Blazor Server JavaScript NOT found" -ForegroundColor Red
    }
    
    if ($hasLegacyJs) {
        Write-Host "❌ Legacy bootstrap-compatibility.js still loading" -ForegroundColor Red
    } else {
        Write-Host "✅ No legacy JavaScript detected" -ForegroundColor Green
    }
    
    if ($hasLayoutBlazor) {
        Write-Host "✅ _LayoutBlazor is being used" -ForegroundColor Green
    } else {
        Write-Host "❌ _LayoutBlazor NOT being used" -ForegroundColor Red
    }
    
    Write-Host ""
    if ($hasPureBlazorIndicator -and $hasBlazorJs -and !$hasLegacyJs) {
        Write-Host "🎉 SUCCESS: Pure Blazor environment is working!" -ForegroundColor Green
        Write-Host "The routing conflict has been resolved." -ForegroundColor Green
    } else {
        Write-Host "⚠️  PARTIAL SUCCESS: Some issues remain" -ForegroundColor Yellow
        Write-Host "Check the browser manually for more details." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Make sure the application is running on https://localhost:5001" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open browser to: $testUrl" -ForegroundColor Yellow
Write-Host "2. Check browser console for Pure Blazor messages" -ForegroundColor Yellow
Write-Host "3. Test TaskCard buttons to verify EventCallback communication" -ForegroundColor Yellow
Write-Host "4. Verify Nova Medicao modal opens without JavaScript errors" -ForegroundColor Yellow