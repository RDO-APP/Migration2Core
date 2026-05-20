#!/usr/bin/env pwsh

# TEST PURE BLAZOR BUTTONS - CORRECT PAGE
# Navigate to the Pure Blazor test page and verify all buttons work

Write-Host "🎯 TESTING PURE BLAZOR BUTTONS - CORRECT PAGE" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

Write-Host ""
Write-Host "📍 CRITICAL: You must navigate to the CORRECT Pure Blazor test page:" -ForegroundColor Yellow
Write-Host ""
Write-Host "❌ WRONG PAGE (Legacy): http://localhost:5031/cards?IdObra=233" -ForegroundColor Red
Write-Host "✅ CORRECT PAGE (Pure Blazor): http://localhost:5031/etapa/cards-blazor/233" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Starting application..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Start the application
Write-Host "Starting .NET 8 application..." -ForegroundColor Yellow
Start-Process "dotnet" -ArgumentList "run" -NoNewWindow

# Wait for startup
Write-Host "Waiting for application startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Open the CORRECT Pure Blazor test page
$correctUrl = "http://localhost:5031/etapa/cards-blazor/233"
Write-Host ""
Write-Host "🌐 Opening CORRECT Pure Blazor test page..." -ForegroundColor Green
Write-Host "URL: $correctUrl" -ForegroundColor Cyan
Start-Process $correctUrl

Write-Host ""
Write-Host "🧪 TESTING INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. ✅ Verify you see 'Pure Blazor System Active!' message" -ForegroundColor Green
Write-Host "2. ✅ Verify task cards are displayed in accordion format" -ForegroundColor Green
Write-Host "3. ✅ Test all 5 buttons on each task card:" -ForegroundColor Green
Write-Host "   - 👁️  View button (eye icon)" -ForegroundColor White
Write-Host "   - 🕒 History button (clock icon)" -ForegroundColor White
Write-Host "   - 🗑️  Delete button (trash icon)" -ForegroundColor White
Write-Host "   - ✏️  Edit button (pencil icon)" -ForegroundColor White
Write-Host "   - ➕ Add Measurement button (plus icon)" -ForegroundColor White
Write-Host ""
Write-Host "4. ✅ Test the (+) Add Measurement button opens the modal" -ForegroundColor Green
Write-Host "5. ✅ Verify modal has all form fields populated" -ForegroundColor Green
Write-Host "6. ✅ Test form submission (currently simulated)" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 EXPECTED RESULTS:" -ForegroundColor Magenta
Write-Host "===================" -ForegroundColor Magenta
Write-Host "- All buttons should work without JavaScript errors" -ForegroundColor White
Write-Host "- Modal should open with today's date pre-filled" -ForegroundColor White
Write-Host "- Form should have all water quality parameters" -ForegroundColor White
Write-Host "- No console errors in browser developer tools" -ForegroundColor White
Write-Host ""
Write-Host "WARNING: If you see any issues, check browser console F12" -ForegroundColor Red
Write-Host ""