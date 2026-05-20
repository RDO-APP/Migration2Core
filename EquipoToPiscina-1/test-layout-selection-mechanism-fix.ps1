# TEST: Layout Selection Mechanism Fix
# Verify which layout is actually being used and fix CSS issues

Write-Host "=== LAYOUT SELECTION MECHANISM FIX TEST ===" -ForegroundColor Cyan

# Step 1: Clear browser cache and rebuild
Write-Host "Step 1: Clearing cache and rebuilding..." -ForegroundColor Yellow
Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "RdoApp.Core" -Force -ErrorAction SilentlyContinue

# Clean and rebuild
Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet clean
dotnet build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build successful" -ForegroundColor Green

# Step 2: Start application
Write-Host "Step 2: Starting application..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run" -NoNewWindow -PassThru

# Wait for startup
Start-Sleep -Seconds 10

# Step 3: Test login and obra selection
Write-Host "Step 3: Testing login and obra selection..." -ForegroundColor Yellow

try {
    # Test login page
    $loginResponse = Invoke-WebRequest -Uri "https://localhost:7297/Account/Login" -UseBasicParsing -SessionVariable session
    Write-Host "Login page status: $($loginResponse.StatusCode)" -ForegroundColor Green
    
    # Check for login form
    if ($loginResponse.Content -match "password") {
        Write-Host "✅ Login form found" -ForegroundColor Green
    } else {
        Write-Host "❌ Login form not found" -ForegroundColor Red
    }
    
    # Test obra selection page (after authentication)
    # Note: This will redirect to login if not authenticated, which is expected
    $obraResponse = Invoke-WebRequest -Uri "https://localhost:7297/Obra/Escolher" -UseBasicParsing -WebSession $session -ErrorAction SilentlyContinue
    
    if ($obraResponse) {
        Write-Host "Obra selection page status: $($obraResponse.StatusCode)" -ForegroundColor Green
        
        # Check for layout identification comments
        if ($obraResponse.Content -match "_LayoutSelection.cshtml is being used") {
            Write-Host "✅ CORRECT: _LayoutSelection.cshtml is being used" -ForegroundColor Green
        } elseif ($obraResponse.Content -match "_Layout.cshtml is being used") {
            Write-Host "❌ WRONG: _Layout.cshtml is being used instead" -ForegroundColor Red
        } else {
            Write-Host "⚠️ Layout identification comment not found" -ForegroundColor Yellow
        }
        
        # Check for task counter (should NOT be present in selection layout)
        if ($obraResponse.Content -match "TAREFA\(S\) SELECIONADA\(S\)") {
            Write-Host "❌ Task counter found (should not be present)" -ForegroundColor Red
        } else {
            Write-Host "✅ Task counter not found (correct)" -ForegroundColor Green
        }
        
        # Check for UnifiedRdoHeader component
        if ($obraResponse.Content -match "Piscinas") {
            Write-Host "✅ UnifiedRdoHeader component found" -ForegroundColor Green
        } else {
            Write-Host "❌ UnifiedRdoHeader component not found" -ForegroundColor Red
        }
        
        # Check for CSS files
        if ($obraResponse.Content -match "rdo-unified-theme.css") {
            Write-Host "✅ RDO Unified Theme CSS found" -ForegroundColor Green
        } else {
            Write-Host "❌ RDO Unified Theme CSS not found" -ForegroundColor Red
        }
        
        if ($obraResponse.Content -match "fontello.css") {
            Write-Host "✅ Fontello CSS found" -ForegroundColor Green
        } else {
            Write-Host "❌ Fontello CSS not found" -ForegroundColor Red
        }
    }
    
} catch {
    Write-Host "❌ Error testing pages: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 4: Check static files
Write-Host "Step 4: Checking static files..." -ForegroundColor Yellow

$staticFiles = @(
    "https://localhost:7297/css/fontello.css",
    "https://localhost:7297/css/rdo-unified-theme.css",
    "https://localhost:7297/css/site.css"
)

foreach ($file in $staticFiles) {
    try {
        $response = Invoke-WebRequest -Uri $file -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $file - OK" -ForegroundColor Green
        } else {
            Write-Host "❌ $file - Status: $($response.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ $file - Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "=== TEST COMPLETE ===" -ForegroundColor Cyan
Write-Host "Check browser developer tools for actual HTML structure" -ForegroundColor Yellow
Write-Host "Look for layout identification comments in HTML source" -ForegroundColor Yellow

Set-Location "../.."