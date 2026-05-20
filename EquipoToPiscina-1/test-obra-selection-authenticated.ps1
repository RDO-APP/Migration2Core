Write-Host "=== TESTING OBRA SELECTION WITH PROPER AUTHENTICATION ===" -ForegroundColor Green
Write-Host "Testing Ricardo's access to obras with full authentication flow..." -ForegroundColor Yellow

# Ricardo's credentials
$ricardoCpf = "567.065.455-20"
$ricardoSenha = "RXL8DjdYj6Y="

# Test 1: Check if application is running
Write-Host "`n1. Checking if application is running..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Application is running successfully" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Application is not responding: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please start the application first with: dotnet run" -ForegroundColor Yellow
    exit 1
}

# Test 2: Perform authenticated login
Write-Host "`n2. Testing authenticated login..." -ForegroundColor Cyan
try {
    # Create session variable to maintain cookies
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    
    # Get login page first (to get any anti-forgery tokens)
    Write-Host "   Getting login page..." -ForegroundColor Gray
    $loginPage = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -WebSession $session -TimeoutSec 10
    
    # Prepare login data
    $loginData = @{
        Cpf = $ricardoCpf
        Senha = $ricardoSenha
    }
    
    # Perform login POST
    Write-Host "   Submitting login credentials..." -ForegroundColor Gray
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method POST -Body $loginData -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
    
    if ($loginResponse.StatusCode -eq 302) {
        Write-Host "✅ Login successful (redirected)" -ForegroundColor Green
        $redirectLocation = $loginResponse.Headers.Location
        Write-Host "   Redirect to: $redirectLocation" -ForegroundColor Gray
    } elseif ($loginResponse.StatusCode -eq 200) {
        Write-Host "✅ Login page loaded (check for errors)" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Login failed with status: $($loginResponse.StatusCode)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Login attempt failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "This might indicate authentication issues" -ForegroundColor Yellow
}

# Test 3: Test authenticated API calls
Write-Host "`n3. Testing authenticated API endpoints..." -ForegroundColor Cyan

# Test ObterObras API with session
try {
    Write-Host "   Calling ObterObras API..." -ForegroundColor Gray
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/ObterObras" -Method POST -ContentType "application/json" -Body "{}" -WebSession $session -TimeoutSec 10
    
    if ($apiResponse.StatusCode -eq 200) {
        Write-Host "✅ ObterObras API successful" -ForegroundColor Green
        
        # Parse JSON response
        $obras = $apiResponse.Content | ConvertFrom-Json
        if ($obras -and $obras.Count -gt 0) {
            Write-Host "✅ Found $($obras.Count) obras for Ricardo!" -ForegroundColor Green
            Write-Host "   First obra: $($obras[0].Nome)" -ForegroundColor Cyan
            
            # List all obras
            Write-Host "`n   📋 Ricardo's Obras:" -ForegroundColor White
            for ($i = 0; $i -lt $obras.Count; $i++) {
                Write-Host "   $($i + 1). $($obras[$i].Nome)" -ForegroundColor Gray
            }
        } else {
            Write-Host "⚠️  API returned empty result" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ API returned status: $($apiResponse.StatusCode)" -ForegroundColor Red
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "❌ API call failed: 401 Unauthorized" -ForegroundColor Red
        Write-Host "   This indicates authentication is not working properly" -ForegroundColor Yellow
    } else {
        Write-Host "❌ API call failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 4: Test obra selection page
Write-Host "`n4. Testing obra selection page..." -ForegroundColor Cyan
try {
    $obrasPage = Invoke-WebRequest -Uri "http://localhost:5031/Obra/Escolher" -WebSession $session -TimeoutSec 10
    
    if ($obrasPage.StatusCode -eq 200) {
        Write-Host "✅ Obra selection page loads successfully" -ForegroundColor Green
        
        # Check for obra cards in the HTML
        if ($obrasPage.Content -match "card-obra|obra-card|class.*card") {
            Write-Host "✅ Obra cards found in page content" -ForegroundColor Green
        } else {
            Write-Host "⚠️  No obra cards detected (might load via JavaScript)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Obra selection page returned: $($obrasPage.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Obra selection page failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test etapas endpoint (if we have an obra ID)
Write-Host "`n5. Testing etapas endpoint..." -ForegroundColor Cyan
try {
    # Try with obra ID 1 (common test case)
    $etapasResponse = Invoke-WebRequest -Uri "http://localhost:5031/api/ObraApi/Etapas/1" -Method GET -WebSession $session -TimeoutSec 10
    
    if ($etapasResponse.StatusCode -eq 200) {
        Write-Host "✅ Etapas API successful" -ForegroundColor Green
        $etapas = $etapasResponse.Content | ConvertFrom-Json
        if ($etapas -and $etapas.Count -gt 0) {
            Write-Host "✅ Found $($etapas.Count) etapas for obra 1" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  Etapas API returned: $($etapasResponse.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "❌ Etapas API: 401 Unauthorized" -ForegroundColor Red
    } else {
        Write-Host "⚠️  Etapas API failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Magenta
Write-Host "✅ RICARDO'S CREDENTIALS:" -ForegroundColor Green
Write-Host "   CPF: $ricardoCpf" -ForegroundColor White
Write-Host "   Password: $ricardoSenha" -ForegroundColor White
Write-Host "   Name: Marcel Castro de Santana" -ForegroundColor White

Write-Host "`n🎯 MANUAL TESTING STEPS:" -ForegroundColor Blue
Write-Host "1. Open browser: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "2. Enter CPF: $ricardoCpf" -ForegroundColor White
Write-Host "3. Enter Password: $ricardoSenha" -ForegroundColor White
Write-Host "4. Click 'Entrar' button" -ForegroundColor White
Write-Host "5. Should see obras selection page with 4 cards" -ForegroundColor White
Write-Host "6. Click any obra to navigate to etapas" -ForegroundColor White

Write-Host "`n🔧 IF AUTHENTICATION FAILS:" -ForegroundColor Yellow
Write-Host "- Check AuthService claims configuration" -ForegroundColor White
Write-Host "- Verify user exists in database with correct password hash" -ForegroundColor White
Write-Host "- Ensure ClaimTypes.NameIdentifier uses user ID (not CPF)" -ForegroundColor White
Write-Host "- Check session cookie configuration" -ForegroundColor White