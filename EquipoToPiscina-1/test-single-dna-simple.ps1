# Test Single DNA Implementation - Simple Version
Write-Host "TESTING SINGLE DNA IMPLEMENTATION" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Stop any running processes
Write-Host "Stopping existing processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Navigate to project directory
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (-not (Test-Path $projectPath)) {
    Write-Host "ERROR: Project path not found: $projectPath" -ForegroundColor Red
    exit 1
}

Set-Location $projectPath

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
$buildResult = dotnet build --configuration Debug --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "SUCCESS: Build completed" -ForegroundColor Green

# Start the application
Write-Host "Starting application..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Debug" -PassThru -WindowStyle Hidden

# Wait for application to start
Write-Host "Waiting for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test if application is running
$testUrl = "https://localhost:7001"
try {
    $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "SUCCESS: Application is running at $testUrl" -ForegroundColor Green
} catch {
    # Try alternative port
    $testUrl = "http://localhost:5000"
    try {
        $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Host "SUCCESS: Application is running at $testUrl" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Application not accessible" -ForegroundColor Red
        if ($process) { $process.Kill() }
        exit 1
    }
}

Write-Host ""
Write-Host "SINGLE DNA TESTING INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. BLAZOR LOGIN TEST:" -ForegroundColor Yellow
Write-Host "   - Open browser to: $testUrl" -ForegroundColor White
Write-Host "   - Should see RDO Blazor login page" -ForegroundColor White
Write-Host "   - CPF field should be focused automatically" -ForegroundColor White
Write-Host ""

Write-Host "2. AUTHENTICATION TEST:" -ForegroundColor Yellow
Write-Host "   - CPF: 567.065.455-20" -ForegroundColor White
Write-Host "   - Password: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host "   - Click ACESSAR button" -ForegroundColor White
Write-Host ""

Write-Host "3. SEAMLESS TRANSITION TEST:" -ForegroundColor Yellow
Write-Host "   - After login, should navigate to ESCOLHER OBRA" -ForegroundColor White
Write-Host "   - Should see obra cards (not blank page)" -ForegroundColor White
Write-Host ""

Write-Host "SUCCESS CRITERIA:" -ForegroundColor Green
Write-Host "- Blazor login page loads correctly" -ForegroundColor White
Write-Host "- Authentication works and navigates to ESCOLHER OBRA" -ForegroundColor White
Write-Host "- ESCOLHER OBRA shows obra cards" -ForegroundColor White
Write-Host "- No layout conflicts or errors" -ForegroundColor White
Write-Host ""

Write-Host "Application is running. Press Ctrl+C to stop." -ForegroundColor Green
Write-Host "Test URL: $testUrl" -ForegroundColor Cyan

try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host ""
    Write-Host "Stopping application..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
        Write-Host "Application stopped" -ForegroundColor Green
    }
}