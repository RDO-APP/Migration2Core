# Quick check for empty obra page issue
Write-Host "🔍 CHECKING OBRA PAGE ISSUE" -ForegroundColor Yellow

# Test login first
$loginData = @{
    cpf = "567.065.455-20"
    senha = "RXL8DjdYj6Y="
    lembrarMe = $false
}

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    Write-Host "1. Testing login..." -ForegroundColor Green
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json" -WebSession $session
    
    if ($loginResponse.sucesso) {
        Write-Host "   ✅ Login works: $($loginResponse.usuario.nome)" -ForegroundColor Green
        
        # Test the ObterObras endpoint
        Write-Host "2. Testing ObterObras endpoint..." -ForegroundColor Green
        $obrasResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/ObraApi/ObterObras" -Method POST -Body "{}" -ContentType "application/json" -WebSession $session
        
        if ($obrasResponse -and $obrasResponse.Count -gt 0) {
            Write-Host "   ✅ Found $($obrasResponse.Count) obras!" -ForegroundColor Green
            Write-Host "   First obra: $($obrasResponse[0].Descricao)" -ForegroundColor White
        } else {
            Write-Host "   ❌ No obras returned!" -ForegroundColor Red
            
            # Test direct database query
            Write-Host "3. Testing direct database..." -ForegroundColor Green
            $directResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/TestUsuario/GetUserObras?userId=302" -Method GET
            
            if ($directResponse.obras -and $directResponse.obras.Count -gt 0) {
                Write-Host "   ✅ Database has $($directResponse.obras.Count) obras!" -ForegroundColor Green
                Write-Host "   Issue: Authentication problem in ObterObras endpoint" -ForegroundColor Yellow
            } else {
                Write-Host "   ❌ Database is also empty!" -ForegroundColor Red
            }
        }
        
    } else {
        Write-Host "   ❌ Login failed: $($loginResponse.mensagem)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Next: Open browser to http://localhost:5031/Obra/Escolher and check F12 Console" -ForegroundColor Cyan