# Visual Studio F5 Debugging Guide - Blank Obra Page Issue
Write-Host "🎯 VISUAL STUDIO F5 DEBUGGING GUIDE" -ForegroundColor Yellow
Write-Host ""

# Clean build first
Write-Host "1. Preparing project for debugging..." -ForegroundColor Green
Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet clean --verbosity quiet
dotnet build --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✅ Build successful!" -ForegroundColor Green
} else {
    Write-Host "   ❌ Build failed - fix compilation errors first!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔍 ISSUE ANALYSIS:" -ForegroundColor Cyan
Write-Host "   • Backend API works (returns 103 obras)" -ForegroundColor White
Write-Host "   • Authentication works (login successful)" -ForegroundColor White
Write-Host "   • ObraController.Escolher() calls API and passes data to view" -ForegroundColor White
Write-Host "   • View expects @Model but page shows blank" -ForegroundColor White
Write-Host "   • Likely issue: Data format mismatch or JavaScript errors" -ForegroundColor White

Write-Host ""
Write-Host "🎯 DEBUGGING CHECKLIST:" -ForegroundColor Yellow
Write-Host ""

Write-Host "STEP 1: Open Visual Studio" -ForegroundColor White
Write-Host "   □ Double-click RdoApp.Core.sln" -ForegroundColor Gray
Write-Host "   □ Wait for solution to load completely" -ForegroundColor Gray

Write-Host ""
Write-Host "STEP 2: Set Strategic Breakpoints" -ForegroundColor White
Write-Host "   □ Controllers/ObraController.cs → Escolher() method (line 25)" -ForegroundColor Gray
Write-Host "   □ Controllers/Api/ObraApiController.cs → ObterObras() method (line 20)" -ForegroundColor Gray
Write-Host "   □ Check what data is returned from API" -ForegroundColor Gray
Write-Host "   □ Check what data is passed to View()" -ForegroundColor Gray

Write-Host ""
Write-Host "STEP 3: Start Debugging" -ForegroundColor White
Write-Host "   □ Press F5 to start debugging" -ForegroundColor Gray
Write-Host "   □ Browser should open to https://localhost:7139" -ForegroundColor Gray
Write-Host "   □ Login if not already authenticated" -ForegroundColor Gray
Write-Host "   □ Navigate to /Obra/Escolher" -ForegroundColor Gray

Write-Host ""
Write-Host "STEP 4: Verify Data Flow" -ForegroundColor White
Write-Host "   □ Does ObraController.Escolher() breakpoint hit?" -ForegroundColor Gray
Write-Host "   □ Does ObraApiController.ObterObras() breakpoint hit?" -ForegroundColor Gray
Write-Host "   □ What does the API return? (Check apiResult variable)" -ForegroundColor Gray
Write-Host "   □ What is passed to View()? (Check obras variable)" -ForegroundColor Gray

Write-Host ""
Write-Host "STEP 5: Frontend Debugging" -ForegroundColor White
Write-Host "   □ Press F12 to open Developer Tools" -ForegroundColor Gray
Write-Host "   □ Go to Console tab - any JavaScript errors?" -ForegroundColor Gray
Write-Host "   □ Go to Network tab - any failed requests?" -ForegroundColor Gray
Write-Host "   □ Check if page HTML contains obra data" -ForegroundColor Gray

Write-Host ""
Write-Host "🔧 EXPECTED FINDINGS:" -ForegroundColor Cyan
Write-Host "   • API should return 103 obras" -ForegroundColor White
Write-Host "   • Data should be passed to view as List<object>" -ForegroundColor White
Write-Host "   • View should render @Model.Count() obras" -ForegroundColor White
Write-Host "   • If data is there but not visible, it's a frontend issue" -ForegroundColor White

Write-Host ""
Write-Host "🚨 COMMON ISSUES TO CHECK:" -ForegroundColor Red
Write-Host "   • Authentication: User.FindFirst(ClaimTypes.NameIdentifier) returns null" -ForegroundColor White
Write-Host "   • Data format: API returns data but view can't process it" -ForegroundColor White
Write-Host "   • JavaScript errors: Console shows errors preventing rendering" -ForegroundColor White
Write-Host "   • CSS issues: Cards are rendered but not visible" -ForegroundColor White

Write-Host ""
Write-Host "💡 QUICK TESTS:" -ForegroundColor Yellow
Write-Host "   1. Add this to Escolher.cshtml after <body>:" -ForegroundColor White
Write-Host "      <div style='color:white;'>DEBUG: @Model.Count() obras loaded</div>" -ForegroundColor Gray
Write-Host "   2. Check if this shows the count" -ForegroundColor White
Write-Host "   3. If count shows but cards don't, it's a rendering issue" -ForegroundColor White

Write-Host ""
Write-Host "🚀 READY FOR DEBUGGING!" -ForegroundColor Green
Write-Host "   Open Visual Studio and follow the checklist above" -ForegroundColor White