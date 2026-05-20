Write-Host "=== TESTING RICARDO'S OBRA ACCESS ===" -ForegroundColor Green
Write-Host "Testing if Ricardo can access his obras with proper authentication..." -ForegroundColor Yellow

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
    
    # Get login page first
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
        Write-Host "✅ Login page loaded" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Login failed with status: $($loginResponse.StatusCode)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Login attempt failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test authenticated API calls
Write-Host "`n3. Testing authenticated API endpoints..." -ForegroundColor Cyan
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
        Write-Host "   Authentication is not working properly" -ForegroundColor Yellow
    } else {
        Write-Host "❌ API call failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== RICARDO'S CREDENTIALS ===" -ForegroundColor Magenta
Write-Host "CPF: $ricardoCpf" -ForegroundColor White
Write-Host "Password: $ricardoSenha" -ForegroundColor White
Write-Host "Name: Marcel Castro de Santana" -ForegroundColor White

Write-Host "`n=== MANUAL TESTING ===" -ForegroundColor Blue
Write-Host "1. Open: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "2. Enter CPF: $ricardoCpf" -ForegroundColor White
Write-Host "3. Enter Password: $ricardoSenha" -ForegroundColor White
Write-Host "4. Should see 4 obra cards after login" -ForegroundColor White

Write-Host "`n=== STATUS ===" -ForegroundColor Cyan
Write-Host "The authentication fix has been applied to AuthService" -ForegroundColor Green
Write-Host "ClaimTypes.NameIdentifier now uses user ID instead of CPF" -ForegroundColor Green
Write-Host "This allows ObraApiController to correctly parse user claims" -ForegroundColor Green