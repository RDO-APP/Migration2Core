# Test authentication with current running application
Write-Host "=== TESTING AUTHENTICATION NOW ===" -ForegroundColor Yellow

# Test HTTP first
Write-Host "1. Testing HTTP connection..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5031/api/TestConnection/database" -Method GET
    Write-Host "✅ HTTP Database connection: $($response.mensagem)" -ForegroundColor Green
    Write-Host "   Total colaboradores: $($response.totalColaboradores)" -ForegroundColor White
} catch {
    Write-Host "❌ HTTP failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test HTTPS
Write-Host ""
Write-Host "2. Testing HTTPS connection..." -ForegroundColor Green
try {
    # Skip certificate validation
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
    Write-Host "✅ HTTPS Database connection: $($response.mensagem)" -ForegroundColor Green
    Write-Host "   Total colaboradores: $($response.totalColaboradores)" -ForegroundColor White
} catch {
    Write-Host "❌ HTTPS failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test login on working port
Write-Host ""
Write-Host "3. Testing login..." -ForegroundColor Green
$loginData = @{
    cpf = "567.065.455-20"
    senha = "RXL8DjdYj6Y="
    lembrarMe = $false
}

# Try HTTPS first
try {
    $loginResponse = Invoke-RestMethod -Uri "https://localhost:7201/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json"
    
    if ($loginResponse.sucesso) {
        Write-Host "✅ HTTPS LOGIN SUCCESSFUL!" -ForegroundColor Green
        Write-Host "   User: $($loginResponse.usuario.nome)" -ForegroundColor White
    } else {
        Write-Host "❌ HTTPS LOGIN FAILED!" -ForegroundColor Red
        Write-Host "   Message: $($loginResponse.mensagem)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ HTTPS login failed: $($_.Exception.Message)" -ForegroundColor Red
    
    # Try HTTP
    try {
        $loginResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json"
        
        if ($loginResponse.sucesso) {
            Write-Host "✅ HTTP LOGIN SUCCESSFUL!" -ForegroundColor Green
            Write-Host "   User: $($loginResponse.usuario.nome)" -ForegroundColor White
        } else {
            Write-Host "❌ HTTP LOGIN FAILED!" -ForegroundColor Red
            Write-Host "   Message: $($loginResponse.mensagem)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ HTTP login also failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== TEST COMPLETE ===" -ForegroundColor Yellow