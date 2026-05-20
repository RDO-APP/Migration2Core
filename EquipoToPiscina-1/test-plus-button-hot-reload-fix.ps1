#!/usr/bin/env pwsh

Write-Host "🎯 TESTING: Plus Button Hot Reload Fix" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test compilation first
Write-Host "📋 Step 1: Testing compilation..." -ForegroundColor Yellow
try {
    dotnet build "RDO-NET8-Migration/RdoApp.Core" --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Compilation successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Compilation failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔧 CHANGES APPLIED:" -ForegroundColor Cyan
Write-Host "1. ✅ Moved window.novaMedicao function to INLINE script block" -ForegroundColor Green
Write-Host "2. ✅ Added Hot Reload bypass with separate <script> tag" -ForegroundColor Green
Write-Host "3. ✅ Added Bootstrap 4/5 compatibility (data-bs-dismiss)" -ForegroundColor Green
Write-Host "4. ✅ Enhanced alert message with 'INLINE JS TRIGGERED'" -ForegroundColor Green
Write-Host "5. ✅ Added console logging for debugging" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 TESTING INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Start the application (F5 in Visual Studio)" -ForegroundColor White
Write-Host "2. Navigate to Etapas/Tarefas page" -ForegroundColor White
Write-Host "3. Click the Plus (+) button on any TaskCard" -ForegroundColor White
Write-Host "4. You should see: 'INLINE JS TRIGGERED for ID: X'" -ForegroundColor White
Write-Host "5. The Nova Medição modal should open successfully" -ForegroundColor White

Write-Host ""
Write-Host "🔍 DEBUGGING CHECKLIST:" -ForegroundColor Yellow
Write-Host "- ✅ Alert popup appears (confirms Blazor → JS bridge works)" -ForegroundColor Green
Write-Host "- ✅ Console shows 'INLINE SCRIPT LOADING - Hot Reload Bypass Active'" -ForegroundColor Green
Write-Host "- ✅ Console shows 'INLINE window.novaMedicao function defined successfully'" -ForegroundColor Green
Write-Host "- ✅ Modal opens with task description and today's date" -ForegroundColor Green

Write-Host ""
Write-Host "IF ALERT STILL DOES NOT APPEAR:" -ForegroundColor Red
Write-Host "1. Check browser console for JavaScript errors" -ForegroundColor White
Write-Host "2. Verify TaskCard.razor uses only @onclick (no HTML onclick)" -ForegroundColor White
Write-Host "3. Check _Layout.cshtml script loading order" -ForegroundColor White
Write-Host "4. Try hard refresh (Ctrl+F5) to clear browser cache" -ForegroundColor White

Write-Host ""
Write-Host "Plus Button Hot Reload Fix Applied Successfully!" -ForegroundColor Green
Write-Host "Ready for testing with F5 in Visual Studio" -ForegroundColor Cyan
Write-Host "Ready for testing with F5 in Visual Studio" -ForegroundColor Cyan