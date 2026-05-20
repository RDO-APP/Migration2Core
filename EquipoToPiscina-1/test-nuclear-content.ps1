# TEST NUCLEAR CONTENT - Verify Controller Can Return HTML
# This tests if the controller can return ANY HTML at all

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NUCLEAR CONTENT TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This test verifies if ObraController can return HTML." -ForegroundColor Yellow
Write-Host ""

Write-Host "STEP 1: Add Nuclear Content Method" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "Add this method to ObraController.cs:" -ForegroundColor White
Write-Host ""
Write-Host @"
public IActionResult EscolherNuclearContent()
{
    _logger.LogInformation("🔥 NUCLEAR CONTENT TEST");
    return Content("<html><body><h1>NUCLEAR TEST: Controller is working!</h1><script>console.log('NUCLEAR TEST PASSED');</script></body></html>", "text/html");
}
"@ -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 2: Restart Application" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "Press Ctrl+C to stop current application" -ForegroundColor White
Write-Host "Then run: dotnet run" -ForegroundColor White
Write-Host ""

Write-Host "STEP 3: Navigate to Test URL" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "URL: https://localhost:7201/Obra/EscolherNuclearContent" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 4: Check Results" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "EXPECTED RESULTS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ If you see 'NUCLEAR TEST: Controller is working!'" -ForegroundColor Green
Write-Host "   → Controller works, issue is in view rendering" -ForegroundColor White
Write-Host "   → Go to view file diagnostic" -ForegroundColor White
Write-Host ""
Write-Host "❌ If page is blank" -ForegroundColor Red
Write-Host "   → Middleware is blocking the response" -ForegroundColor White
Write-Host "   → Go to middleware bypass test" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press Enter when you've completed the test..." -ForegroundColor Yellow
Read-Host

Write-Host ""
Write-Host "What did you see?" -ForegroundColor Yellow
Write-Host "1) 'NUCLEAR TEST: Controller is working!' (Controller works)" -ForegroundColor Green
Write-Host "2) Blank page (Middleware blocking)" -ForegroundColor Red
Write-Host "3) Error page (Routing issue)" -ForegroundColor Yellow
Write-Host ""
$result = Read-Host "Enter 1, 2, or 3"

switch ($result) {
    "1" {
        Write-Host ""
        Write-Host "✅ CONTROLLER WORKS!" -ForegroundColor Green
        Write-Host "Issue is in view rendering." -ForegroundColor White
        Write-Host ""
        Write-Host "Next step: Check if view file exists" -ForegroundColor Yellow
        Write-Host "Run: Test-Path 'RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml'" -ForegroundColor Cyan
    }
    "2" {
        Write-Host ""
        Write-Host "❌ MIDDLEWARE IS BLOCKING!" -ForegroundColor Red
        Write-Host "Custom middleware is preventing response." -ForegroundColor White
        Write-Host ""
        Write-Host "Next step: Run Nuclear Bypass Test" -ForegroundColor Yellow
        Write-Host "Run: .\test-nuclear-bypass.ps1" -ForegroundColor Cyan
    }
    "3" {
        Write-Host ""
        Write-Host "⚠️ ROUTING ISSUE!" -ForegroundColor Yellow
        Write-Host "Route is not reaching controller." -ForegroundColor White
        Write-Host ""
        Write-Host "Next step: Check routing configuration" -ForegroundColor Yellow
        Write-Host "Check Program.cs MapControllerRoute settings" -ForegroundColor Cyan
    }
    default {
        Write-Host ""
        Write-Host "Invalid input. Please run the test again." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
