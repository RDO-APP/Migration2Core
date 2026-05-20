# Test Ricardo's obra count
Write-Host "=== TESTING RICARDO'S OBRAS COUNT ===" -ForegroundColor Yellow

# First login to get authentication
Write-Host "1. Logging in as Ricardo..." -ForegroundColor Green
$loginData = @{
    cpf = "567.065.455-20"
    senha = "RXL8DjdYj6Y="
    lembrarMe = $false
}

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json"
    
    if ($loginResponse.sucesso) {
        Write-Host "✅ Login successful: $($loginResponse.usuario.nome)" -ForegroundColor Green
    } else {
        Write-Host "❌ Login failed: $($loginResponse.mensagem)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Login request failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test using the GetUserObras endpoint I created
Write-Host ""
Write-Host "2. Testing GetUserObras endpoint..." -ForegroundColor Green
try {
    $obraResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/TestUsuario/GetUserObras?userId=302" -Method GET
    
    if ($obraResponse.obras) {
        $count = $obraResponse.obras.Count
        Write-Host "✅ Found $count obras for Ricardo!" -ForegroundColor Green
        
        foreach ($obra in $obraResponse.obras) {
            Write-Host "   - Obra ID: $($obra.obraId)" -ForegroundColor White
            Write-Host "     Descrição: '$($obra.descricao)'" -ForegroundColor White
            Write-Host "     Grupo: $($obra.grupoNome)" -ForegroundColor White
            Write-Host "     ---" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ No obras found for Ricardo" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ GetUserObras failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test using the actual ObraApi endpoint (the one used by the application)
Write-Host ""
Write-Host "3. Testing actual ObraApi endpoint..." -ForegroundColor Green

# Create a session to maintain cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Login with session
try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json" -WebSession $session
    
    if ($loginResponse.sucesso) {
        Write-Host "✅ Login with session successful" -ForegroundColor Green
        
        # Now call the actual obra endpoint
        $obraApiResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/ObraApi/ObterObras" -Method POST -Body "{}" -ContentType "application/json" -WebSession $session
        
        if ($obraApiResponse) {
            $count = $obraApiResponse.Count
            Write-Host "✅ ObraApi returned $count obras!" -ForegroundColor Green
            
            foreach ($obra in $obraApiResponse) {
                Write-Host "   - Obra ID: $($obra.IdObra)" -ForegroundColor White
                Write-Host "     Descrição: '$($obra.Descricao)'" -ForegroundColor White
                Write-Host "     Cidade/Estado: $($obra.CidadeEstado)" -ForegroundColor White
                Write-Host "     Status: $($obra.StatusBasicaGratuita)" -ForegroundColor White
                Write-Host "     ---" -ForegroundColor Gray
            }
        } else {
            Write-Host "❌ ObraApi returned no obras" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ Session login failed: $($loginResponse.mensagem)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ObraApi test failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== TEST COMPLETE ===" -ForegroundColor Yellow