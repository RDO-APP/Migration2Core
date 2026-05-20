# TEST AUTHENTICATED ESCOLHER ACCESS
# Phase 1: Task 1.1 - Gather evidence from authenticated session

Write-Host "=== AUTHENTICATED ESCOLHER ACCESS TEST ===" -ForegroundColor Cyan

$baseUrl = "http://localhost:5031"

# Create a session to maintain cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    Write-Host "1. Getting login page..." -ForegroundColor Green
    $loginPage = Invoke-WebRequest -Uri "$baseUrl/Account/Login" -WebSession $session -UseBasicParsing
    Write-Host "   Login page loaded (Status: $($loginPage.StatusCode))" -ForegroundColor Gray
    
    # Extract anti-forgery token
    if ($loginPage.Content -match '__RequestVerificationToken.*?value="([^"]+)"') {
        $token = $matches[1]
        Write-Host "   Anti-forgery token extracted" -ForegroundColor Gray
    } else {
        Write-Host "   Warning: No anti-forgery token found" -ForegroundColor Yellow
        $token = ""
    }
    
    Write-Host "`n2. Attempting login..." -ForegroundColor Green
    
    # Prepare login data
    $loginData = @{
        'Email' = 'ricardo'
        'Password' = '123456'
        '__RequestVerificationToken' = $token
    }
    
    # Convert to form data
    $formData = ($loginData.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" }) -join '&'
    
    # Perform login
    $loginResponse = Invoke-WebRequest -Uri "$baseUrl/Account/Login" -Method POST -Body $formData -ContentType "application/x-www-form-urlencoded" -WebSession $session -UseBasicParsing -MaximumRedirection 0 -ErrorAction SilentlyContinue
    
    Write-Host "   Login response status: $($loginResponse.StatusCode)" -ForegroundColor Gray
    
    if ($loginResponse.StatusCode -eq 302) {
        Write-Host "   ✅ Login successful (redirected)" -ForegroundColor Green
        
        # Follow redirect to ESCOLHER OBRA
        Write-Host "`n3. Accessing ESCOLHER OBRA page..." -ForegroundColor Green
        $escolherResponse = Invoke-WebRequest -Uri "$baseUrl/Obra/Escolher" -WebSession $session -UseBasicParsing
        
        Write-Host "   ESCOLHER OBRA status: $($escolherResponse.StatusCode)" -ForegroundColor Gray
        Write-Host "   Content length: $($escolherResponse.Content.Length) bytes" -ForegroundColor Gray
        
        # Save the HTML for analysis
        $escolherResponse.Content | Out-File -FilePath "escolher-authenticated-source.html" -Encoding UTF8
        Write-Host "   ✅ HTML saved to: escolher-authenticated-source.html" -ForegroundColor Green
        
        # Quick analysis
        Write-Host "`n4. QUICK ANALYSIS:" -ForegroundColor Green
        
        if ($escolherResponse.Content -match "Found.*obras.*in Model") {
            Write-Host "   ✅ DEBUG MESSAGE FOUND - Controller working!" -ForegroundColor Green
            if ($escolherResponse.Content -match "Found (\d+) obras in Model") {
                Write-Host "   📊 Obra count: $($matches[1])" -ForegroundColor Cyan
            }
        } else {
            Write-Host "   ❌ DEBUG MESSAGE NOT FOUND" -ForegroundColor Red
        }
        
        if ($escolherResponse.Content -match "rdo-obra-cards-container") {
            Write-Host "   ✅ COMPONENT CONTAINER FOUND" -ForegroundColor Green
        } else {
            Write-Host "   ❌ COMPONENT CONTAINER MISSING" -ForegroundColor Red
        }
        
        if ($escolherResponse.Content -match "lista-obras") {
            Write-Host "   ✅ OBRA GRID FOUND" -ForegroundColor Green
        } else {
            Write-Host "   ❌ OBRA GRID MISSING" -ForegroundColor Red
        }
        
        if ($escolherResponse.Content -match "blazor\.server\.js") {
            Write-Host "   ✅ BLAZOR SERVER SCRIPT FOUND" -ForegroundColor Green
        } else {
            Write-Host "   ❌ BLAZOR SERVER SCRIPT MISSING" -ForegroundColor Red
        }
        
        # Check main content area
        if ($escolherResponse.Content -match '<main[^>]*class="conteudo"[^>]*>(.*?)</main>') {
            $mainContent = $matches[1]
            $mainLength = $mainContent.Length
            Write-Host "   📄 Main content length: $mainLength characters" -ForegroundColor Gray
            
            if ($mainLength -lt 100) {
                Write-Host "   ❌ MAIN CONTENT IS EMPTY OR VERY SHORT" -ForegroundColor Red
            } else {
                Write-Host "   ✅ Main content has substantial data" -ForegroundColor Green
            }
        }
        
    } else {
        Write-Host "   ❌ Login failed (Status: $($loginResponse.StatusCode))" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Run: .\html-source-analyzer.ps1" -ForegroundColor White
Write-Host "2. Open browser manually to: $baseUrl" -ForegroundColor White
Write-Host "3. Login with: ricardo / 123456" -ForegroundColor White
Write-Host "4. Check ESCOLHER OBRA page visually" -ForegroundColor White
Write-Host "5. Open F12 Developer Tools and check Network/Console tabs" -ForegroundColor White