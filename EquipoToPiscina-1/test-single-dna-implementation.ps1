# Test Single DNA Implementation - Blazor Login to ESCOLHER OBRA
# This script tests the unified Blazor architecture

Write-Host "TESTING SINGLE DNA IMPLEMENTATION" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Stop any running processes
Write-Host "Stopping existing processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Wait for processes to stop
Start-Sleep -Seconds 2

# Navigate to project directory
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (-not (Test-Path $projectPath)) {
    Write-Host "❌ Project path not found: $projectPath" -ForegroundColor Red
    exit 1
}

Set-Location $projectPath

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
$buildResult = dotnet build --configuration Debug --verbosity quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build successful" -ForegroundColor Green

# Start the application
Write-Host "Starting application..." -ForegroundColor Yellow
$process = Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Debug" -PassThru -WindowStyle Hidden

# Wait for application to start
Write-Host "⏳ Waiting for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Test if application is running
$testUrl = "https://localhost:7001"
try {
    $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ Application is running at $testUrl" -ForegroundColor Green
} catch {
    Write-Host "❌ Application failed to start or is not accessible" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try alternative port
    $testUrl = "http://localhost:5000"
    try {
        $response = Invoke-WebRequest -Uri $testUrl -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        Write-Host "✅ Application is running at $testUrl" -ForegroundColor Green
    } catch {
        Write-Host "❌ Application not accessible on any port" -ForegroundColor Red
        if ($process) { $process.Kill() }
        exit 1
    }
}

Write-Host ""
Write-Host "🧪 SINGLE DNA TESTING INSTRUCTIONS" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. 🌐 BLAZOR LOGIN TEST:" -ForegroundColor Yellow
Write-Host "   • Open browser to: $testUrl" -ForegroundColor White
Write-Host "   • Should see RDO Blazor login page (not old MVC login)" -ForegroundColor White
Write-Host "   • Check F12 Console for: '🚀 RDO Login: Initializing Blazor login component'" -ForegroundColor White
Write-Host "   • CPF field should be focused automatically" -ForegroundColor White
Write-Host "   • Double-click anywhere to auto-fill (localhost only)" -ForegroundColor White
Write-Host ""

Write-Host "2. 🔐 AUTHENTICATION TEST:" -ForegroundColor Yellow
Write-Host "   • CPF: 567.065.455-20" -ForegroundColor White
Write-Host "   • Password: RXL8DjdYj6Y=" -ForegroundColor White
Write-Host "   • Click ACESSAR button" -ForegroundColor White
Write-Host "   • Should show loading spinner during authentication" -ForegroundColor White
Write-Host ""

Write-Host "3. 🎯 SEAMLESS TRANSITION TEST:" -ForegroundColor Yellow
Write-Host "   • After successful login, should navigate to ESCOLHER OBRA" -ForegroundColor White
Write-Host "   • Should see 'Found 103 obras in Model' debug message" -ForegroundColor White
Write-Host "   • Should see obra cards (not blank page)" -ForegroundColor White
Write-Host "   • Both pages should use same _LayoutSelection.cshtml layout" -ForegroundColor White
Write-Host ""

Write-Host "4. 🔍 VISUAL VERIFICATION:" -ForegroundColor Yellow
Write-Host "   • Login page should have RDO logo and blue gradient background" -ForegroundColor White
Write-Host "   • CPF input should have mask: 000.000.000-00" -ForegroundColor White
Write-Host "   • Password field should have toggle eye icon" -ForegroundColor White
Write-Host "   • ESCOLHER OBRA should show obra cards in grid layout" -ForegroundColor White
Write-Host ""

Write-Host "5. 🛠️ TECHNICAL VERIFICATION:" -ForegroundColor Yellow
Write-Host "   • F12 Network tab: No 404 errors for CSS/JS files" -ForegroundColor White
Write-Host "   • F12 Console: No JavaScript errors" -ForegroundColor White
Write-Host "   • Blazor Server connection should establish (SignalR)" -ForegroundColor White
Write-Host "   • Session should persist across login → obra selection" -ForegroundColor White
Write-Host ""

Write-Host "6. 🧪 ERROR HANDLING TEST:" -ForegroundColor Yellow
Write-Host "   • Try invalid credentials - should show error message" -ForegroundColor White
Write-Host "   • Try empty fields - should show validation errors" -ForegroundColor White
Write-Host "   • Check that errors are displayed in Blazor component" -ForegroundColor White
Write-Host ""

Write-Host "✅ SUCCESS CRITERIA:" -ForegroundColor Green
Write-Host "• Blazor login page loads and functions correctly" -ForegroundColor White
Write-Host "• Authentication works and navigates to ESCOLHER OBRA" -ForegroundColor White
Write-Host "• ESCOLHER OBRA shows obra cards (not blank)" -ForegroundColor White
Write-Host "• No layout conflicts or CSS issues" -ForegroundColor White
Write-Host "• Single DNA architecture working end-to-end" -ForegroundColor White
Write-Host ""

Write-Host "❌ FAILURE INDICATORS:" -ForegroundColor Red
Write-Host "• Old MVC login page appears instead of Blazor" -ForegroundColor White
Write-Host "• Blank page after login" -ForegroundColor White
Write-Host "• JavaScript errors in F12 Console" -ForegroundColor White
Write-Host "• CSS not loading (404 errors)" -ForegroundColor White
Write-Host "• Authentication fails or doesn't redirect" -ForegroundColor White
Write-Host ""

Write-Host "🔧 DEBUGGING TIPS:" -ForegroundColor Magenta
Write-Host "• Check browser F12 Console for detailed error messages" -ForegroundColor White
Write-Host "• Verify all CSS/JS files load successfully in Network tab" -ForegroundColor White
Write-Host "• Look for Blazor Server SignalR connection in Network tab" -ForegroundColor White
Write-Host "• Check application logs for authentication errors" -ForegroundColor White
Write-Host ""

# Keep application running for testing
Write-Host "🏃 Application is running. Press Ctrl+C to stop." -ForegroundColor Green
Write-Host "📱 Test URL: $testUrl" -ForegroundColor Cyan

try {
    # Wait for user to stop
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    # Clean up
    Write-Host ""
    Write-Host "Stopping application..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
        Write-Host "✅ Application stopped" -ForegroundColor Green
    }
}