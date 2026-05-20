Write-Host "=== TESTING DATABASE DIRECT QUERY ===" -ForegroundColor Green
Write-Host "Checking what's actually in the database..." -ForegroundColor Yellow

# Test the database connection via API with more details
Write-Host "`n1. Testing database connection..." -ForegroundColor Cyan
try {
    $dbTest = Invoke-WebRequest -Uri "http://localhost:5031/api/TestConnection/database" -Method GET -TimeoutSec 10 -UseBasicParsing
    if ($dbTest.StatusCode -eq 200) {
        $dbResult = $dbTest.Content | ConvertFrom-Json
        Write-Host "✅ Database connection successful" -ForegroundColor Green
        Write-Host "   Total colaboradores: $($dbResult.totalColaboradores)" -ForegroundColor White
        Write-Host "   Connection string: $($dbResult.connectionString)" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Database test failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test user lookup with CPF without formatting
Write-Host "`n2. Testing user lookup with unformatted CPF..." -ForegroundColor Cyan
try {
    $userTest = Invoke-WebRequest -Uri "http://localhost:5031/api/TestConnection/usuario/56706545520" -Method GET -TimeoutSec 10 -UseBasicParsing
    if ($userTest.StatusCode -eq 200) {
        $userResult = $userTest.Content | ConvertFrom-Json
        Write-Host "✅ User found with unformatted CPF!" -ForegroundColor Green
        Write-Host "   ID: $($userResult.usuario.id)" -ForegroundColor White
        Write-Host "   Nome: $($userResult.usuario.nome)" -ForegroundColor White
        Write-Host "   CPF: $($userResult.usuario.cpf)" -ForegroundColor White
        Write-Host "   Ativo: $($userResult.usuario.ativo)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ User test with unformatted CPF failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test user lookup with formatted CPF
Write-Host "`n3. Testing user lookup with formatted CPF..." -ForegroundColor Cyan
try {
    $userTest2 = Invoke-WebRequest -Uri "http://localhost:5031/api/TestConnection/usuario/567.065.455-20" -Method GET -TimeoutSec 10 -UseBasicParsing
    if ($userTest2.StatusCode -eq 200) {
        $userResult2 = $userTest2.Content | ConvertFrom-Json
        Write-Host "✅ User found with formatted CPF!" -ForegroundColor Green
        Write-Host "   ID: $($userResult2.usuario.id)" -ForegroundColor White
        Write-Host "   Nome: $($userResult2.usuario.nome)" -ForegroundColor White
        Write-Host "   CPF: $($userResult2.usuario.cpf)" -ForegroundColor White
        Write-Host "   Ativo: $($userResult2.usuario.ativo)" -ForegroundColor White
    }
} catch {
    Write-Host "❌ User test with formatted CPF failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== CONCLUSION ===" -ForegroundColor Magenta
Write-Host "This will help us understand:" -ForegroundColor Yellow
Write-Host "1. If the user exists in the database" -ForegroundColor White
Write-Host "2. What the correct name is" -ForegroundColor White
Write-Host "3. What format the CPF is stored in" -ForegroundColor White
Write-Host "4. What the Ativo field value is" -ForegroundColor White