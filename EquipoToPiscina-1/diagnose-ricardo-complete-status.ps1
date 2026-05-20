# 🚨 RICARDO USER COMPLETE DIAGNOSTIC SCRIPT
# This script will check Ricardo's user status and obra associations

Write-Host "=== RICARDO USER COMPLETE DIAGNOSTIC ===" -ForegroundColor Yellow
Write-Host "Target CPF: 567.065.455-20 (56706545520 without formatting)" -ForegroundColor Cyan
Write-Host "Expected Password: RXL8DjdYj6Y=" -ForegroundColor Cyan
Write-Host ""

# Test database connection first
Write-Host "1. TESTING DATABASE CONNECTION..." -ForegroundColor Green
try {
    # Skip certificate validation for localhost
    add-type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    
    $response = Invoke-RestMethod -Uri "https://localhost:7201/api/TestConnection/database" -Method GET
    Write-Host "✅ Database connection: $($response.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Database connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. CHECKING RICARDO'S USER RECORD..." -ForegroundColor Green

# Check if Ricardo exists with CPF search
try {
    $searchResponse = Invoke-RestMethod -Uri "https://localhost:7201/api/TestUsuario/SearchByCpf?cpf=56706545520" -Method GET
    
    if ($searchResponse.found) {
        Write-Host "✅ RICARDO FOUND IN DATABASE!" -ForegroundColor Green
        Write-Host "   ID: $($searchResponse.user.id)" -ForegroundColor White
        Write-Host "   Nome: '$($searchResponse.user.nome)'" -ForegroundColor White
        Write-Host "   CPF: $($searchResponse.user.cpf)" -ForegroundColor White
        Write-Host "   Email: $($searchResponse.user.email)" -ForegroundColor White
        Write-Host "   Telefone: $($searchResponse.user.telefone)" -ForegroundColor White
        Write-Host "   Ativo: $($searchResponse.user.ativo)" -ForegroundColor White
        Write-Host "   Senha: $($searchResponse.user.senha)" -ForegroundColor White
        
        $ricardoId = $searchResponse.user.id
        $ricardoNome = $searchResponse.user.nome
        $ricardoAtivo = $searchResponse.user.ativo
        $ricardoSenha = $searchResponse.user.senha
        
        # Check password match
        if ($ricardoSenha -eq "RXL8DjdYj6Y=") {
            Write-Host "✅ Password matches expected value" -ForegroundColor Green
        } else {
            Write-Host "❌ Password MISMATCH!" -ForegroundColor Red
            Write-Host "   Expected: RXL8DjdYj6Y=" -ForegroundColor Yellow
            Write-Host "   Actual: $ricardoSenha" -ForegroundColor Yellow
        }
        
        # Check active status
        if ($ricardoAtivo -eq $true) {
            Write-Host "✅ User is ACTIVE" -ForegroundColor Green
        } elseif ($ricardoAtivo -eq $null) {
            Write-Host "⚠️ User Ativo is NULL (should work)" -ForegroundColor Yellow
        } else {
            Write-Host "❌ User is INACTIVE" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ RICARDO NOT FOUND!" -ForegroundColor Red
        Write-Host "   This explains why login fails" -ForegroundColor Yellow
        
        # Check total users in database
        Write-Host ""
        Write-Host "3. CHECKING TOTAL USERS IN DATABASE..." -ForegroundColor Green
        try {
            $countResponse = Invoke-RestMethod -Uri "https://localhost:7201/api/TestUsuario/Count" -Method GET
            Write-Host "   Total colaboradores: $($countResponse.count)" -ForegroundColor White
            
            if ($countResponse.count -eq 0) {
                Write-Host "❌ NO USERS IN DATABASE!" -ForegroundColor Red
                Write-Host "   Database appears to be empty" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Failed to get user count: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        exit 1
    }
    
} catch {
    Write-Host "❌ Failed to search for Ricardo: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3. CHECKING RICARDO'S OBRA ASSOCIATIONS..." -ForegroundColor Green

# Check obra associations
try {
    $obraResponse = Invoke-RestMethod -Uri "https://localhost:7201/api/TestUsuario/GetUserObras?userId=$ricardoId" -Method GET
    
    if ($obraResponse.obras -and $obraResponse.obras.Count -gt 0) {
        Write-Host "✅ RICARDO HAS $($obraResponse.obras.Count) OBRA(S)!" -ForegroundColor Green
        
        foreach ($obra in $obraResponse.obras) {
            Write-Host "   Obra ID: $($obra.obraId)" -ForegroundColor White
            Write-Host "   Descrição: '$($obra.descricao)'" -ForegroundColor White
            Write-Host "   Grupo: $($obra.grupoNome)" -ForegroundColor White
            Write-Host "   ---" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ RICARDO HAS NO OBRA ASSOCIATIONS!" -ForegroundColor Red
        Write-Host "   This explains why obra selection fails" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Failed to get Ricardo's obras: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. TESTING LOGIN FLOW..." -ForegroundColor Green

# Test login
try {
    $loginData = @{
        cpf = "567.065.455-20"
        senha = "RXL8DjdYj6Y="
        lembrarMe = $false
    }
    
    $loginResponse = Invoke-RestMethod -Uri "https://localhost:7201/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json"
    
    if ($loginResponse.sucesso) {
        Write-Host "✅ LOGIN SUCCESSFUL!" -ForegroundColor Green
        Write-Host "   User: $($loginResponse.usuario.nome)" -ForegroundColor White
    } else {
        Write-Host "❌ LOGIN FAILED!" -ForegroundColor Red
        Write-Host "   Message: $($loginResponse.mensagem)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ LOGIN REQUEST FAILED!" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode
        Write-Host "   Status Code: $statusCode" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== DIAGNOSTIC SUMMARY ===" -ForegroundColor Yellow

if ($searchResponse.found) {
    Write-Host "✅ Ricardo exists in database" -ForegroundColor Green
    Write-Host "   Name: $ricardoNome" -ForegroundColor White
    Write-Host "   Active: $ricardoAtivo" -ForegroundColor White
    
    if ($ricardoSenha -eq "RXL8DjdYj6Y=") {
        Write-Host "✅ Password is correct" -ForegroundColor Green
    } else {
        Write-Host "❌ Password is wrong" -ForegroundColor Red
    }
    
    if ($obraResponse.obras -and $obraResponse.obras.Count -gt 0) {
        Write-Host "✅ Has obra associations" -ForegroundColor Green
    } else {
        Write-Host "❌ No obra associations" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Ricardo does not exist in database" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Yellow

if (-not $searchResponse.found) {
    Write-Host "1. CREATE Ricardo's user record" -ForegroundColor Cyan
    Write-Host "2. ASSOCIATE Ricardo with obras" -ForegroundColor Cyan
} elseif ($ricardoSenha -ne "RXL8DjdYj6Y=") {
    Write-Host "1. FIX Ricardo's password" -ForegroundColor Cyan
} elseif (-not $obraResponse.obras -or $obraResponse.obras.Count -eq 0) {
    Write-Host "1. CREATE obra associations for Ricardo" -ForegroundColor Cyan
} else {
    Write-Host "1. INVESTIGATE why login/obra access still fails" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Diagnostic complete!" -ForegroundColor Green