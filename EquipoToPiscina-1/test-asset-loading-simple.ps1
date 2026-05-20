#!/usr/bin/env pwsh

Write-Host "=== SIMPLE ASSET LOADING TEST ===" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Kill any existing processes
Write-Host "Stopping any existing dotnet processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "`n1. Physical File Verification..." -ForegroundColor Green

# Check if files actually exist
$files = @(
    "wwwroot/css/fontello.css",
    "wwwroot/Assets/images/user.png", 
    "wwwroot/fonts/fontello.woff2",
    "wwwroot/css/rdo-unified-theme.css",
    "wwwroot/css/site.css"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        Write-Host "✅ $file exists ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "❌ $file MISSING" -ForegroundColor Red
    }
}

Write-Host "`n2. Program.cs Configuration Check..." -ForegroundColor Green
$programContent = Get-Content "Program.cs" -Raw

# Check UseStaticFiles configuration
if ($programContent -match 'app\.UseStaticFiles\(\)') {
    Write-Host "✅ UseStaticFiles() found in Program.cs" -ForegroundColor Green
} else {
    Write-Host "❌ UseStaticFiles() NOT found in Program.cs" -ForegroundColor Red
}

# Check middleware order
$lines = Get-Content "Program.cs"
$useStaticFilesLine = -1
$useRoutingLine = -1
$useAuthenticationLine = -1

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'UseStaticFiles') { $useStaticFilesLine = $i }
    if ($lines[$i] -match 'UseRouting') { $useRoutingLine = $i }
    if ($lines[$i] -match 'UseAuthentication') { $useAuthenticationLine = $i }
}

Write-Host "`nMiddleware Order Analysis:" -ForegroundColor White
Write-Host "UseStaticFiles line: $useStaticFilesLine" -ForegroundColor White
Write-Host "UseRouting line: $useRoutingLine" -ForegroundColor White  
Write-Host "UseAuthentication line: $useAuthenticationLine" -ForegroundColor White

if ($useStaticFilesLine -lt $useRoutingLine -and $useStaticFilesLine -lt $useAuthenticationLine) {
    Write-Host "✅ Middleware order is correct (UseStaticFiles before UseRouting and UseAuthentication)" -ForegroundColor Green
} else {
    Write-Host "❌ Middleware order is WRONG - UseStaticFiles should be FIRST" -ForegroundColor Red
}

Write-Host "`n3. Starting Server and Testing..." -ForegroundColor Green

# Start server
Write-Host "Starting dotnet run..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--urls=http://localhost:5000" -PassThru -NoNewWindow

Write-Host "Waiting 15 seconds for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    # Test with curl if available, otherwise use simple HTTP test
    Write-Host "`nTesting HTTP requests..." -ForegroundColor White
    
    # Test fontello.css
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/css/fontello.css" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ fontello.css: Status $($response.StatusCode)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ fontello.css: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test user.png
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/Assets/images/user.png" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ user.png: Status $($response.StatusCode)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ user.png: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test main page
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5000/" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ Main page: Status $($response.StatusCode)" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Main page: $($_.Exception.Message)" -ForegroundColor Red
    }
}
finally {
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "`n=== TEST COMPLETE ===" -ForegroundColor Cyan