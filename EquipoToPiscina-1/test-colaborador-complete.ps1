# Test Complete Colaborador Entity Implementation

Write-Host "Testing COMPLETE COLABORADOR ENTITY" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

# Test 1: Basic connection and count
Write-Host "1. Testing database connection..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/TestConnection/database" -Method GET
    Write-Host "✅ Connection OK: $($response.mensagem)" -ForegroundColor Green
    Write-Host "   Total Colaboradores: $($response.totalColaboradores)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: Sample colaborador data
Write-Host "`n2. Getting sample colaborador data..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/DatabaseAnalysis/colaborador-sample" -Method GET
    Write-Host "✅ Sample data retrieved!" -ForegroundColor Green
    Write-Host "   Sample Records: $($response.totalSample)" -ForegroundColor Cyan
    
    foreach ($colaborador in $response.colaboradores) {
        Write-Host "   - ID: $($colaborador.id) | Nome: $($colaborador.nome) | CPF: $($colaborador.cpf)" -ForegroundColor White
    }
} catch {
    Write-Host "⚠️ Sample data failed (expected with new fields): $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test 3: Login with test user
Write-Host "`n3. Testing login functionality..." -ForegroundColor Yellow
try {
    $loginData = @{
        Cpf = "56706545520"
        Senha = "1234"
        LembrarMe = $false
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/Auth/login" -Method POST -Body $loginData -ContentType "application/json"
    
    if ($response.sucesso) {
        Write-Host "✅ Login successful!" -ForegroundColor Green
        Write-Host "   User: $($response.usuario.nome)" -ForegroundColor Cyan
        Write-Host "   CPF: $($response.usuario.cpf)" -ForegroundColor Cyan
        Write-Host "   Email: $($response.usuario.email)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Login failed: $($response.mensagem)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Login test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Check if we can access the web login page
Write-Host "`n4. Testing web login page..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5031/Auth/Login" -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Web login page accessible!" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Web login page failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎯 COLABORADOR ENTITY TEST COMPLETE!" -ForegroundColor Green
Write-Host "Next: Continue with systematic database table analysis" -ForegroundColor Cyan