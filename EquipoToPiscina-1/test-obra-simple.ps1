# Simple obra page test
Write-Host "Testing obra page issue..." -ForegroundColor Yellow

$loginData = @{
    cpf = "567.065.455-20"
    senha = "RXL8DjdYj6Y="
    lembrarMe = $false
}

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    # Login
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json" -WebSession $session
    
    if ($loginResponse.sucesso) {
        Write-Host "Login OK: $($loginResponse.usuario.nome)" -ForegroundColor Green
        
        # Test ObterObras
        $obrasResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/ObraApi/ObterObras" -Method POST -Body "{}" -ContentType "application/json" -WebSession $session
        
        if ($obrasResponse -and $obrasResponse.Count -gt 0) {
            Write-Host "Found $($obrasResponse.Count) obras!" -ForegroundColor Green
        } else {
            Write-Host "No obras found - this is the problem!" -ForegroundColor Red
        }
        
    } else {
        Write-Host "Login failed" -ForegroundColor Red
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}