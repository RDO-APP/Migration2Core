# BROWSER CONNECTION DIAGNOSTIC SCRIPT
# Automatically diagnoses why browser shows blank page when server is running

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BROWSER CONNECTION DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if server is running
Write-Host "Step 1: Checking if server is running..." -ForegroundColor Yellow
$serverProcess = Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue
if ($serverProcess) {
    Write-Host "✅ Server process is running (PID: $($serverProcess.Id))" -ForegroundColor Green
} else {
    Write-Host "❌ Server process is NOT running" -ForegroundColor Red
    Write-Host "   You need to start the server first!" -ForegroundColor Red
    exit 1
}

# Step 2: Check if ports are listening
Write-Host ""
Write-Host "Step 2: Checking if ports are listening..." -ForegroundColor Yellow
$port7201 = netstat -ano | Select-String "7201" | Select-String "LISTENING"
$port5031 = netstat -ano | Select-String "5031" | Select-String "LISTENING"

if ($port7201) {
    Write-Host "✅ Port 7201 (HTTPS) is listening" -ForegroundColor Green
} else {
    Write-Host "❌ Port 7201 (HTTPS) is NOT listening" -ForegroundColor Red
}

if ($port5031) {
    Write-Host "✅ Port 5031 (HTTP) is listening" -ForegroundColor Green
} else {
    Write-Host "❌ Port 5031 (HTTP) is NOT listening" -ForegroundColor Red
}

# Step 3: Test HTTP connection
Write-Host ""
Write-Host "Step 3: Testing HTTP connection to server..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/" -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ HTTP connection successful (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ HTTP connection failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Test HTTPS connection
Write-Host ""
Write-Host "Step 4: Testing HTTPS connection to server..." -ForegroundColor Yellow
try {
    # Skip certificate validation for self-signed cert
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $response = Invoke-WebRequest -Uri "https://localhost:7201/" -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ HTTPS connection successful (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ HTTPS connection failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   This might be an SSL certificate issue" -ForegroundColor Yellow
}

# Step 5: Test /Obra/Escolher endpoint
Write-Host ""
Write-Host "Step 5: Testing /Obra/Escolher endpoint..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Obra/Escolher" -Method GET -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ /Obra/Escolher endpoint responded (Status: $($response.StatusCode))" -ForegroundColor Green
    
    if ($response.StatusCode -eq 302) {
        Write-Host "⚠️  Server returned redirect (302) - You might need to log in first" -ForegroundColor Yellow
        Write-Host "   Redirect location: $($response.Headers.Location)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ /Obra/Escolher endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Message -like "*302*" -or $_.Exception.Message -like "*redirect*") {
        Write-Host "⚠️  Server is redirecting - You need to log in first!" -ForegroundColor Yellow
        Write-Host "   Navigate to: http://localhost:5031/Account/Login" -ForegroundColor Yellow
    }
}

# Step 6: Check Windows Firewall
Write-Host ""
Write-Host "Step 6: Checking Windows Firewall..." -ForegroundColor Yellow
$firewallRules = Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*dotnet*" -or $_.DisplayName -like "*RdoApp*"}
if ($firewallRules) {
    Write-Host "✅ Found firewall rules for .NET applications" -ForegroundColor Green
} else {
    Write-Host "⚠️  No specific firewall rules found - might need to add exception" -ForegroundColor Yellow
}

# Step 7: DNS resolution test
Write-Host ""
Write-Host "Step 7: Testing DNS resolution..." -ForegroundColor Yellow
try {
    $dnsResult = Resolve-DnsName -Name "localhost" -ErrorAction Stop
    Write-Host "✅ localhost resolves to: $($dnsResult.IPAddress)" -ForegroundColor Green
} catch {
    Write-Host "❌ localhost DNS resolution failed" -ForegroundColor Red
    Write-Host "   Try using 127.0.0.1 instead of localhost" -ForegroundColor Yellow
}

# Step 8: Summary and recommendations
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "RECOMMENDED ACTIONS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open browser and press F12 to open Developer Tools" -ForegroundColor White
Write-Host "2. Go to Network tab" -ForegroundColor White
Write-Host "3. Navigate to: http://localhost:5031/Account/Login" -ForegroundColor White
Write-Host "4. Log in with valid credentials" -ForegroundColor White
Write-Host "5. Then navigate to: http://localhost:5031/Obra/Escolher" -ForegroundColor White
Write-Host ""
Write-Host "If you see a blank page:" -ForegroundColor Yellow
Write-Host "- Check Network tab for failed requests" -ForegroundColor White
Write-Host "- Check Console tab for JavaScript errors" -ForegroundColor White
Write-Host "- Try clearing browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "- Try incognito/private mode" -ForegroundColor White
Write-Host "- Try different browser (Chrome, Edge, Firefox)" -ForegroundColor White
Write-Host ""

Write-Host "MOST LIKELY ISSUE:" -ForegroundColor Yellow
Write-Host "You need to LOG IN first before accessing /Obra/Escolher" -ForegroundColor White
Write-Host "The page requires authentication!" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
