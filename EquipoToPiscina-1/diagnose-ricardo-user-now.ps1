Write-Host "=== DIAGNOSING RICARDO USER ISSUE ===" -ForegroundColor Red
Write-Host "Investigating why the name is wrong and authentication stopped working..." -ForegroundColor Yellow

# Test 1: Check if application is running
Write-Host "`n1. Checking application status..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031" -Method GET -TimeoutSec 5
    Write-Host "✅ Application is running (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Application not responding: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Check login page
Write-Host "`n2. Testing login page..." -ForegroundColor Cyan
try {
    $loginPage = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method GET -TimeoutSec 5
    Write-Host "✅ Login page loads (Status: $($loginPage.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "❌ Login page failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test database connection via API
Write-Host "`n3. Testing database connection..." -ForegroundColor Cyan
try {
    $dbTest = Invoke-WebRequest -Uri "http://localhost:5031/api/TestConnection/database" -Method GET -TimeoutSec 10
    if ($dbTest.StatusCode -eq 200) {
        $dbResult = $dbTest.Content | ConvertFrom-Json
        Write-Host "✅ Database connection: $($dbResult.mensagem)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Database test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Check specific user via API
Write-Host "`n4. Testing Ricardo's user data via API..." -ForegroundColor Cyan
try {
    $userTest = Invoke-WebRequest -Uri "http://localhost:5031/api/TestConnection/usuario/567.065.455-20" -Method GET -TimeoutSec 10
    if ($userTest.StatusCode -eq 200) {
        $userResult = $userTest.Content | ConvertFrom-Json
        if ($userResult.sucesso) {
            Write-Host "✅ User found in database!" -ForegroundColor Green
            Write-Host "   ID: $($userResult.usuario.id)" -ForegroundColor White
            Write-Host "   Nome: $($userResult.usuario.nome)" -ForegroundColor White
            Write-Host "   CPF: $($userResult.usuario.cpf)" -ForegroundColor White
            Write-Host "   Ativo: $($userResult.usuario.ativo)" -ForegroundColor White
        } else {
            Write-Host "❌ User not found: $($userResult.mensagem)" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ User test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Try login with both password variations
Write-Host "`n5. Testing login with different passwords..." -ForegroundColor Cyan

$passwords = @("1234", "RXL8DjdYj6Y=", "RXL8DjdVj6Y=")
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

foreach ($password in $passwords) {
    Write-Host "   Testing password: $password" -ForegroundColor Gray
    try {
        $loginData = @{
            Cpf = "567.065.455-20"
            Senha = $password
        }
        
        $loginResponse = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -Method POST -Body $loginData -WebSession $session -MaximumRedirection 0 -ErrorAction SilentlyContinue
        
        if ($loginResponse.StatusCode -eq 302) {
            Write-Host "   ✅ SUCCESS with password: $password" -ForegroundColor Green
            $redirectLocation = $loginResponse.Headers.Location
            Write-Host "   Redirected to: $redirectLocation" -ForegroundColor Cyan
            break
        } else {
            Write-Host "   ❌ Failed with password: $password (Status: $($loginResponse.StatusCode))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Error with password: $password - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== ANALYSIS ===" -ForegroundColor Magenta
Write-Host "The issue might be:" -ForegroundColor Yellow
Write-Host "1. Database connection problems" -ForegroundColor White
Write-Host "2. User data changed in database" -ForegroundColor White
Write-Host "3. Password hash mismatch" -ForegroundColor White
Write-Host "4. Authentication service configuration changed" -ForegroundColor White

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Blue
Write-Host "1. Check application logs in Visual Studio (Debug Output)" -ForegroundColor White
Write-Host "2. Verify database connection string" -ForegroundColor White
Write-Host "3. Check if user exists in database with correct data" -ForegroundColor White
Write-Host "4. Verify AuthService claims configuration" -ForegroundColor White