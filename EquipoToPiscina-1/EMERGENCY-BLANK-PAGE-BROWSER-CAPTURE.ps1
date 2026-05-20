# EMERGENCY: Capture actual browser response to diagnose blank page
# This will show us EXACTLY what the browser is receiving

Write-Host "========================================" -ForegroundColor Red
Write-Host "EMERGENCY BLANK PAGE DIAGNOSIS" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

$projectPath = "RDO-NET8-Migration\RdoApp.Core"
Set-Location $projectPath

Write-Host "Killing all processes..." -ForegroundColor Yellow
Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "Building..." -ForegroundColor Yellow
dotnet build --no-incremental 2>&1 | Out-Null

Write-Host "Starting server..." -ForegroundColor Yellow
$job = Start-Job -ScriptBlock {
    param($path)
    Set-Location $path
    dotnet run
} -ArgumentList (Get-Location).Path

Start-Sleep -Seconds 10

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CAPTURING BROWSER RESPONSE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

try {
    # Make HTTP request and capture response
    $response = Invoke-WebRequest -Uri "https://localhost:7201/Obra/Escolher" -SkipCertificateCheck -UseBasicParsing
    
    Write-Host "STATUS CODE: $($response.StatusCode)" -ForegroundColor $(if ($response.StatusCode -eq 200) { "Green" } else { "Red" })
    Write-Host "CONTENT LENGTH: $($response.Content.Length) bytes" -ForegroundColor $(if ($response.Content.Length -gt 0) { "Green" } else { "Red" })
    Write-Host ""
    
    if ($response.Content.Length -eq 0) {
        Write-Host "❌ RESPONSE IS EMPTY (0 bytes)" -ForegroundColor Red
        Write-Host "This confirms middleware is blocking the response" -ForegroundColor Red
    }
    else {
        Write-Host "✅ RESPONSE HAS CONTENT ($($response.Content.Length) bytes)" -ForegroundColor Green
        Write-Host ""
        Write-Host "RESPONSE PREVIEW (first 500 chars):" -ForegroundColor Yellow
        Write-Host $response.Content.Substring(0, [Math]::Min(500, $response.Content.Length)) -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "RESPONSE HEADERS:" -ForegroundColor Yellow
    $response.Headers.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
    }
    
    # Save full response to file
    $response.Content | Out-File "emergency-response-capture.html" -Encoding UTF8
    Write-Host ""
    Write-Host "Full response saved to: emergency-response-capture.html" -ForegroundColor Green
}
catch {
    Write-Host "❌ ERROR MAKING REQUEST:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}
finally {
    Write-Host ""
    Write-Host "Stopping server..." -ForegroundColor Yellow
    Stop-Job $job -ErrorAction SilentlyContinue
    Remove-Job $job -ErrorAction SilentlyContinue
    
    Get-Process | Where-Object { $_.ProcessName -like "*RdoApp*" -or $_.ProcessName -like "*dotnet*" } | Stop-Process -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSIS COMPLETE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Check emergency-response-capture.html to see what the browser received" -ForegroundColor Yellow
