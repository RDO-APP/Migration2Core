# CAPTURE ESCOLHER RESPONSE - See what browser actually receives
# This will show us if the response is empty, has HTML, or has Blazor scripts

Write-Host "=== CAPTURING /Obra/Escolher RESPONSE ===" -ForegroundColor Cyan
Write-Host ""

# Make HTTP request and capture full response
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Obra/Escolher" `
        -Method GET `
        -SessionVariable session `
        -UseBasicParsing `
        -SkipCertificateCheck `
        -ErrorAction Stop
    
    Write-Host "✅ Response Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "📦 Response Size: $($response.Content.Length) bytes" -ForegroundColor Yellow
    Write-Host ""
    
    # Save response to file
    $response.Content | Out-File -FilePath "escolher-response-content.html" -Encoding UTF8
    Write-Host "💾 Response saved to: escolher-response-content.html" -ForegroundColor Green
    Write-Host ""
    
    # Show first 500 characters
    Write-Host "📄 Response Preview (first 500 chars):" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Write-Host $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length))
    Write-Host "----------------------------------------"
    Write-Host ""
    
    # Check for specific content
    if ($response.Content -match "MOTOR IS RUNNING") {
        Write-Host "✅ Found: MOTOR IS RUNNING" -ForegroundColor Green
    }
    elseif ($response.Content -match "<!DOCTYPE html>") {
        Write-Host "✅ Found: HTML DOCTYPE" -ForegroundColor Green
    }
    elseif ($response.Content.Length -eq 0) {
        Write-Host "❌ EMPTY RESPONSE (0 bytes)" -ForegroundColor Red
    }
    elseif ($response.Content -match "_framework") {
        Write-Host "⚠️  Found: Blazor framework scripts" -ForegroundColor Yellow
    }
    else {
        Write-Host "⚠️  Unknown response content" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "This might mean:" -ForegroundColor Yellow
    Write-Host "  1. Server is not running" -ForegroundColor Yellow
    Write-Host "  2. Authentication required (need to login first)" -ForegroundColor Yellow
    Write-Host "  3. SSL certificate issue" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Open escolher-response-content.html in a text editor"
Write-Host "2. Tell me what you see:"
Write-Host "   - Is it empty?"
Write-Host "   - Does it have HTML?"
Write-Host "   - Does it have Blazor scripts?"
Write-Host "   - Does it have error messages?"
