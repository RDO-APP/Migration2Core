# Test the obra page directly in browser
Write-Host "Testing obra page in browser..." -ForegroundColor Yellow

# First login to get session
$loginData = @{
    cpf = "567.065.455-20"
    senha = "RXL8DjdYj6Y="
    lembrarMe = $false
}

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    # Login first
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json" -WebSession $session
    
    if ($loginResponse.sucesso) {
        Write-Host "✅ Login successful" -ForegroundColor Green
        
        # Now try to access the obra page
        $pageResponse = Invoke-WebRequest -Uri "http://localhost:8000/Obra/Escolher" -WebSession $session
        
        if ($pageResponse.StatusCode -eq 200) {
            Write-Host "✅ Page loads successfully (Status: 200)" -ForegroundColor Green
            
            # Check if page contains expected elements
            $content = $pageResponse.Content
            
            if ($content -match "ObterObras") {
                Write-Host "✅ Page references ObterObras API" -ForegroundColor Green
            } else {
                Write-Host "❌ Page does NOT reference ObterObras API" -ForegroundColor Red
            }
            
            if ($content -match "lista-obras") {
                Write-Host "✅ Page has obra list container" -ForegroundColor Green
            } else {
                Write-Host "❌ Page missing obra list container" -ForegroundColor Red
            }
            
            # Check for JavaScript errors in the HTML
            if ($content -match "error|Error|undefined") {
                Write-Host "⚠️  Possible JavaScript errors in page" -ForegroundColor Yellow
            }
            
        } else {
            Write-Host "❌ Page failed to load: Status $($pageResponse.StatusCode)" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ Login failed" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🌐 Opening browser to test manually..." -ForegroundColor Cyan
Write-Host "   1. Go to: http://localhost:8000/Auth/Login" -ForegroundColor White
Write-Host "   2. Login with CPF: 567.065.455-20" -ForegroundColor White
Write-Host "   3. Go to: http://localhost:8000/Obra/Escolher" -ForegroundColor White
Write-Host "   4. Press F12 and check Console for errors" -ForegroundColor White

# Open browser
Start-Process "http://localhost:8000/Auth/Login"