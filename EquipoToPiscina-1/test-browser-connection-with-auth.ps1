# TEST BROWSER CONNECTION WITH AUTHENTICATION
# This script will test the complete flow: Login → Obra Selection

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BROWSER CONNECTION TEST WITH AUTH" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$baseUrl = "http://localhost:5031"
$loginUrl = "$baseUrl/Account/Login"
$escolherUrl = "$baseUrl/Obra/Escolher"

Write-Host "Testing complete authentication flow..." -ForegroundColor Yellow
Write-Host ""

# Step 1: Test if server is responding
Write-Host "Step 1: Testing if server is responding..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $baseUrl -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Server is responding (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Server is NOT responding" -ForegroundColor Red
    Write-Host "   Make sure the server is running first!" -ForegroundColor Red
    Write-Host ""
    Write-Host "To start the server:" -ForegroundColor Yellow
    Write-Host "   cd RDO-NET8-Migration\RdoApp.Core" -ForegroundColor White
    Write-Host "   dotnet run" -ForegroundColor White
    exit 1
}

# Step 2: Test login page
Write-Host ""
Write-Host "Step 2: Testing login page..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $loginUrl -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ Login page is accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Login page is NOT accessible" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 3: Test escolher page (should redirect to login)
Write-Host ""
Write-Host "Step 3: Testing escolher page (without auth)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $escolherUrl -Method GET -TimeoutSec 5 -UseBasicParsing -MaximumRedirection 0 -ErrorAction Stop
    Write-Host "✅ Escolher page responded (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 302) {
        Write-Host "✅ Escolher page correctly redirects to login (302)" -ForegroundColor Green
        $redirectLocation = $_.Exception.Response.Headers.Location
        Write-Host "   Redirect to: $redirectLocation" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Escolher page error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 4: Open browser with instructions
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OPENING BROWSER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "I will now open your browser with the login page." -ForegroundColor Yellow
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host "1. Browser will open to the login page" -ForegroundColor White
Write-Host "2. Press F12 to open Developer Tools" -ForegroundColor White
Write-Host "3. Go to the Network tab" -ForegroundColor White
Write-Host "4. Log in with your credentials" -ForegroundColor White
Write-Host "5. After login, navigate to /Obra/Escolher" -ForegroundColor White
Write-Host "6. Check Network tab for any failed requests" -ForegroundColor White
Write-Host "7. Check Console tab for any JavaScript errors" -ForegroundColor White
Write-Host ""

Write-Host "Test credentials (if available):" -ForegroundColor Yellow
Write-Host "   Username: ricardo" -ForegroundColor White
Write-Host "   Password: 123456" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to open browser..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open browser
Start-Process $loginUrl

Write-Host ""
Write-Host "Browser opened!" -ForegroundColor Green
Write-Host ""
Write-Host "WHAT TO LOOK FOR:" -ForegroundColor Yellow
Write-Host ""
Write-Host "If you see a BLANK PAGE:" -ForegroundColor Yellow
Write-Host "1. Check Network tab in Developer Tools (F12)" -ForegroundColor White
Write-Host "   - Are there ANY requests?" -ForegroundColor White
Write-Host "   - Are requests failing (red)?" -ForegroundColor White
Write-Host "   - Are requests pending (gray)?" -ForegroundColor White
Write-Host ""
Write-Host "2. Check Console tab in Developer Tools (F12)" -ForegroundColor White
Write-Host "   - Are there JavaScript errors?" -ForegroundColor White
Write-Host "   - Are there CORS errors?" -ForegroundColor White
Write-Host "   - Are there security errors?" -ForegroundColor White
Write-Host ""
Write-Host "3. Check the URL in address bar" -ForegroundColor White
Write-Host "   - Is it exactly: $escolherUrl ?" -ForegroundColor White
Write-Host "   - Are there any typos?" -ForegroundColor White
Write-Host ""

Write-Host "COMMON SOLUTIONS:" -ForegroundColor Yellow
Write-Host "- Clear browser cache: Ctrl+Shift+Delete" -ForegroundColor White
Write-Host "- Hard refresh: Ctrl+Shift+R (Chrome) or Ctrl+F5 (Edge)" -ForegroundColor White
Write-Host "- Try incognito/private mode" -ForegroundColor White
Write-Host "- Try different browser (Chrome, Edge, Firefox)" -ForegroundColor White
Write-Host "- Make sure you're logged in first!" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
