# 🚨 SIMPLE RICARDO DIAGNOSTIC SCRIPT
Write-Host "=== SIMPLE RICARDO DIAGNOSTIC ===" -ForegroundColor Yellow
Write-Host "Target CPF: 567.065.455-20 (56706545520 without formatting)" -ForegroundColor Cyan
Write-Host ""

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

Write-Host "1. TESTING DATABASE CONNECTION..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7201/api/TestConnection/database" -Method GET
    Write-Host "✅ Database connection: $($response.mensagem)" -ForegroundColor Green
    Write-Host "   Total colaboradores: $($response.totalColaboradores)" -ForegroundColor White
} catch {
    Write-Host "❌ Database connection failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. TESTING ENTITY FRAMEWORK SEARCH..." -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7201/api/TestUsuario/test-entity" -Method GET
    
    if ($response.encontrado) {
        Write-Host "✅ RICARDO FOUND via Entity Framework!" -ForegroundColor Green
        Write-Host "   ID: $($response.usuario.id)" -ForegroundColor White
        Write-Host "   Nome: '$($response.usuario.nome)'" -ForegroundColor White
        Write-Host "   CPF: $($response.usuario.cpf)" -ForegroundColor White
        Write-Host "   Ativo: $($response.usuario.ativo)" -ForegroundColor White
    } else {
        Write-Host "❌ RICARDO NOT FOUND via Entity Framework!" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Entity Framework test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. TESTING LOGIN API..." -ForegroundColor Green
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
Write-Host "=== DIAGNOSTIC COMPLETE ===" -ForegroundColor Yellow