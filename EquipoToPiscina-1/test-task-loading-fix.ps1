#!/usr/bin/env pwsh

Write-Host "🔧 TESTING TASK LOADING FIX FOR OBRA 233" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Test the critical fix for task loading in accordion expansion
Write-Host ""
Write-Host "🎯 CRITICAL FIX: Task Loading for Accordion Expansion" -ForegroundColor Yellow
Write-Host "- Fixed EtapaService.cs to populate Tarefas collection" -ForegroundColor Green
Write-Host "- Added TarefaViewModel mapping from TaskRawDto" -ForegroundColor Green
Write-Host "- Badge counters should show correct task counts" -ForegroundColor Green
Write-Host "- Accordion expansion should show actual task list" -ForegroundColor Green

Write-Host ""
Write-Host "🚀 Starting application to test the fix..." -ForegroundColor Cyan

try {
    # Navigate to project directory
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    
    # Build the project
    Write-Host "🔨 Building project..." -ForegroundColor Yellow
    dotnet build --no-restore
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Build failed!" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Build successful!" -ForegroundColor Green
    
    # Start the application
    Write-Host ""
    Write-Host "🌐 Starting application..." -ForegroundColor Yellow
    Write-Host "Navigate to: https://localhost:5001/Auth/Login" -ForegroundColor Cyan
    Write-Host "Login with: ricardo / 123456" -ForegroundColor Cyan
    Write-Host "Then go to Obra 233 -> Etapas" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔍 WHAT TO TEST:" -ForegroundColor Yellow
    Write-Host "1. Check that 4 stages are visible for Obra 233" -ForegroundColor White
    Write-Host "2. Verify badge counters show correct task counts (not 0)" -ForegroundColor White
    Write-Host "3. Click to expand 'LIMPEZA' stage" -ForegroundColor White
    Write-Host "4. Confirm task list appears in accordion expansion" -ForegroundColor White
    Write-Host "5. Check browser console (F12) for any JavaScript errors" -ForegroundColor White
    Write-Host ""
    Write-Host "Press Ctrl+C to stop the server when testing is complete" -ForegroundColor Yellow
    
    # Run the application
    dotnet run --no-build
    
} catch {
    Write-Host "❌ Error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} finally {
    # Return to original directory
    Set-Location "../.."
}

Write-Host ""
Write-Host "🎉 Testing completed!" -ForegroundColor Green