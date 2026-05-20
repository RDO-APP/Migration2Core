#!/usr/bin/env pwsh

Write-Host "WHITE SCREEN DIAGNOSTIC - CRITICAL RENDERING FAILURE" -ForegroundColor Red
Write-Host "====================================================" -ForegroundColor Red

Write-Host "`nStarting application for diagnostic..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Start the application
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -NoNewWindow
Write-Host "Application started with PID: $($process.Id)" -ForegroundColor Green

# Wait for startup
Write-Host "Waiting 15 seconds for application startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    Write-Host "`nTesting /obra/escolher endpoint..." -ForegroundColor Cyan
    
    # Test the endpoint
    $response = Invoke-WebRequest -Uri "http://localhost:5031/obra/escolher" -UseBasicParsing -TimeoutSec 30
    
    Write-Host "Response Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response Length: $($response.Content.Length) characters" -ForegroundColor Green
    
    # Check for critical elements
    $hasRenderBody = $response.Content -match '@RenderBody\(\)'
    $hasBlazorScript = $response.Content -match 'blazor\.server\.js'
    $hasHeaderError = $response.Content -match 'Header Error:'
    $hasContent = $response.Content -match 'ESCOLHA UMA DAS UNIDADES'
    
    Write-Host "`nCRITICAL ELEMENTS CHECK:" -ForegroundColor Yellow
    Write-Host "Has @RenderBody(): $hasRenderBody" -ForegroundColor $(if($hasRenderBody) {"Green"} else {"Red"})
    Write-Host "Has blazor.server.js: $hasBlazorScript" -ForegroundColor $(if($hasBlazorScript) {"Green"} else {"Red"})
    Write-Host "Has Header Error: $hasHeaderError" -ForegroundColor $(if($hasHeaderError) {"Red"} else {"Green"})
    Write-Host "Has Page Content: $hasContent" -ForegroundColor $(if($hasContent) {"Green"} else {"Red"})
    
    if ($hasHeaderError) {
        Write-Host "`nHEADER ERROR DETECTED!" -ForegroundColor Red
        $errorMatch = [regex]::Match($response.Content, '<strong>Header Error:</strong>\s*([^<]+)')
        if ($errorMatch.Success) {
            Write-Host "Error Message: $($errorMatch.Groups[1].Value)" -ForegroundColor Red
        }
    }
    
    # Save response for inspection
    $response.Content | Out-File -FilePath "debug-response.html" -Encoding UTF8
    Write-Host "`nResponse saved to debug-response.html for inspection" -ForegroundColor Cyan
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    # Stop the application
    if ($process -and !$process.HasExited) {
        $process.Kill()
        Write-Host "`nApplication stopped" -ForegroundColor Yellow
    }
}

Write-Host "`nDIAGNOSTIC COMPLETE" -ForegroundColor Green