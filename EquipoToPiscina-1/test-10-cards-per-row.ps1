# Test 10 Cards Per Row Implementation
# This script tests the new 10 cards per row layout

Write-Host "🎯 Testing 10 Cards Per Row Layout" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Navigate to project directory
$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "✅ Navigated to project directory: $projectPath" -ForegroundColor Green
} else {
    Write-Host "❌ Project directory not found: $projectPath" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 Changes Applied:" -ForegroundColor Yellow
Write-Host "- Removed max-width: 1200px limitation" -ForegroundColor White
Write-Host "- Set flex-basis: 10% for 10 cards per row" -ForegroundColor White
Write-Host "- Added responsive breakpoints:" -ForegroundColor White
Write-Host "  • Mobile (<768px): 2 cards per row" -ForegroundColor Gray
Write-Host "  • Tablet (769-1024px): 5 cards per row" -ForegroundColor Gray
Write-Host "  • Small Laptop (1025-1366px): 7 cards per row" -ForegroundColor Gray
Write-Host "  • Standard Laptop (1367-1920px): 8 cards per row" -ForegroundColor Gray
Write-Host "  • Large Screen (>1920px): 10 cards per row" -ForegroundColor Gray

Write-Host ""
Write-Host "🚀 Starting application..." -ForegroundColor Cyan

try {
    # Clean and build
    Write-Host "🧹 Cleaning project..." -ForegroundColor Yellow
    dotnet clean --verbosity quiet
    
    Write-Host "🔨 Building project..." -ForegroundColor Yellow
    $buildResult = dotnet build --verbosity quiet
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🌐 Starting application on https://localhost:7201" -ForegroundColor Cyan
        Write-Host "📱 Test the layout on different screen sizes:" -ForegroundColor Yellow
        Write-Host "   • Press F12 to open DevTools" -ForegroundColor White
        Write-Host "   • Click the device toolbar icon" -ForegroundColor White
        Write-Host "   • Test different screen sizes:" -ForegroundColor White
        Write-Host "     - 1366x768 (Small laptop)" -ForegroundColor Gray
        Write-Host "     - 1920x1080 (Standard laptop)" -ForegroundColor Gray
        Write-Host "     - 2560x1440 (Large laptop)" -ForegroundColor Gray
        
        Write-Host ""
        Write-Host "🔍 What to look for:" -ForegroundColor Magenta
        Write-Host "   • Cards should fill the full width of the screen" -ForegroundColor White
        Write-Host "   • No wasted space on the sides" -ForegroundColor White
        Write-Host "   • Cards should be readable and not too small" -ForegroundColor White
        Write-Host "   • Icons and text should remain proportional" -ForegroundColor White
        
        Write-Host ""
        Write-Host "⚡ Press Ctrl+C to stop the application when done testing" -ForegroundColor Yellow
        
        # Start the application
        dotnet run --urls="https://localhost:7201"
        
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
        Write-Host "Build output:" -ForegroundColor Yellow
        Write-Host $buildResult -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error occurred: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🏁 Test completed!" -ForegroundColor Green