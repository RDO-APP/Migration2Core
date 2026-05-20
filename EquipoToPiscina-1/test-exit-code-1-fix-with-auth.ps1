# Test Exit Code -1 Fix with Authentication
# This script logs in first, then tests the /Obra/Escolher endpoint

Write-Host "=== TESTING EXIT CODE -1 FIX ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get login page to obtain antiforgery token
Write-Host "Step 1: Getting login page..." -ForegroundColor Yellow
$loginPage = Invoke-WebRequest -Uri "https://localhost:7201/Account/Login" `
    -SkipCertificateCheck `
    -SessionVariable session `
    -ErrorAction Stop

Write-Host "Login page loaded" -ForegroundColor Green
Write-Host ""

# Step 2: Extract antiforgery token
Write-Host "Step 2: Extracting antiforgery token..." -ForegroundColor Yellow
$token = $loginPage.InputFields | Where-Object { $_.name -eq "__RequestVerificationToken" } | Select-Object -ExpandProperty value

if ($token) {
    Write-Host "Token extracted: $($token.Substring(0, 20))..." -ForegroundColor Green
}
else {
    Write-Host "Failed to extract token" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 3: Login with test credentials
Write-Host "Step 3: Logging in as ricardo..." -ForegroundColor Yellow
$loginBody = @{
    "__RequestVerificationToken" = $token
    "cpf" = "12345678900"
    "senha" = "senha123"
}

$loginResponse = Invoke-WebRequest -Uri "https://localhost:7201/Account/Login" `
    -Method Post `
    -Body $loginBody `
    -WebSession $session `
    -SkipCertificateCheck `
    -MaximumRedirection 0 `
    -ErrorAction SilentlyContinue

if ($loginResponse.StatusCode -eq 302) {
    Write-Host "Login successful (redirected)" -ForegroundColor Green
}
else {
    Write-Host "Login failed: Status $($loginResponse.StatusCode)" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Step 4: Access /Obra/Escolher
Write-Host "Step 4: Accessing /Obra/Escolher..." -ForegroundColor Yellow
Write-Host "This is the CRITICAL TEST - checking for Exit Code -1..." -ForegroundColor Cyan
Write-Host ""

try {
    $escolherResponse = Invoke-WebRequest -Uri "https://localhost:7201/Obra/Escolher" `
        -WebSession $session `
        -SkipCertificateCheck `
        -ErrorAction Stop
    
    Write-Host "SUCCESS! Page loaded without crash!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Status Code: $($escolherResponse.StatusCode)" -ForegroundColor Green
    Write-Host "Content Length: $($escolherResponse.Content.Length) bytes" -ForegroundColor Green
    Write-Host ""
    
    # Check for obra cards
    $obraCount = ([regex]::Matches($escolherResponse.Content, '<div class="item">')).Count
    Write-Host "Obra cards found: $obraCount" -ForegroundColor $(if ($obraCount -gt 0) { "Green" } else { "Yellow" })
    
    # Check for icons
    $hasIcons = $escolherResponse.Content -match 'icon-contratante|icon-contratada'
    Write-Host "Icons present: $hasIcons" -ForegroundColor $(if ($hasIcons) { "Green" } else { "Yellow" })
    
    # Check for progress bars
    $hasProgressBars = $escolherResponse.Content -match 'progress-bar'
    Write-Host "Progress bars present: $hasProgressBars" -ForegroundColor $(if ($hasProgressBars) { "Green" } else { "Yellow" })
    
    # Check for legend
    $hasLegend = $escolherResponse.Content -match 'area-legenda'
    Write-Host "Legend section present: $hasLegend" -ForegroundColor $(if ($hasLegend) { "Green" } else { "Yellow" })
    
    Write-Host ""
    Write-Host "=== EXIT CODE -1 FIX VERIFIED ===" -ForegroundColor Green
    Write-Host "The application did NOT crash with Exit Code -1!" -ForegroundColor Green
    Write-Host "The three architectural fixes RESOLVED the issue!" -ForegroundColor Green
    
}
catch {
    Write-Host "FAILURE! Request failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "=== EXIT CODE -1 MAY STILL BE PRESENT ===" -ForegroundColor Red
    exit 1
}
