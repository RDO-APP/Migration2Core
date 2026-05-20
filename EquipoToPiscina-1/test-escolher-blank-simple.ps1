# SIMPLE TEST: Capture Escolher page HTML response
Write-Host "Testing Escolher page..." -ForegroundColor Cyan

$escolherUrl = "https://localhost:7201/Obra/Escolher"

# Create session
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# Login first
try {
    $loginUrl = "https://localhost:7201/Account/Login"
    $loginPage = Invoke-WebRequest -Uri $loginUrl -Method GET -SessionVariable session -SkipCertificateCheck
    
    $token = ""
    if ($loginPage.Content -match 'name="__RequestVerificationToken"[^>]*value="([^"]+)"') {
        $token = $Matches[1]
    }
    
    $loginBody = @{
        "__RequestVerificationToken" = $token
        "cpf" = "567.065.455-20"
        "senha" = "RXL8DjdYj6Y="
    }
    
    $loginResponse = Invoke-WebRequest -Uri $loginUrl -Method POST -Body $loginBody -WebSession $session -SkipCertificateCheck -MaximumRedirection 0 -ErrorAction SilentlyContinue
    Write-Host "Login completed" -ForegroundColor Green
    
} catch {
    Write-Host "Login attempt done" -ForegroundColor Yellow
}

# Get Escolher page
try {
    $response = Invoke-WebRequest -Uri $escolherUrl -Method GET -WebSession $session -SkipCertificateCheck
    
    Write-Host "`nResponse Status: $($response.StatusCode)" -ForegroundColor Cyan
    Write-Host "Content Length: $($response.Content.Length) bytes" -ForegroundColor Cyan
    
    # Save to file
    $response.Content | Out-File -FilePath "escolher-response.html" -Encoding UTF8
    Write-Host "Saved to: escolher-response.html" -ForegroundColor Green
    
    # Quick analysis
    $html = $response.Content
    
    Write-Host "`nQuick Analysis:" -ForegroundColor Yellow
    Write-Host "Has DOCTYPE: $($html -match '<!DOCTYPE')" -ForegroundColor White
    Write-Host "Has html tag: $($html -match '<html')" -ForegroundColor White
    Write-Host "Has body tag: $($html -match '<body')" -ForegroundColor White
    Write-Host "Has DEBUG INFO: $($html -match 'DEBUG INFO')" -ForegroundColor White
    Write-Host "Has lista-obras: $($html -match 'lista-obras')" -ForegroundColor White
    
    # Extract model count
    if ($html -match 'Model count:</strong>\s*(\d+)') {
        Write-Host "Model count in HTML: $($Matches[1])" -ForegroundColor Cyan
    }
    
    # Count obra cards
    $obraCount = ([regex]::Matches($html, '<div class="item">')).Count
    Write-Host "Obra cards found: $obraCount" -ForegroundColor Cyan
    
    Write-Host "`nOpen escolher-response.html in a browser to see what the server is sending" -ForegroundColor Yellow
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
