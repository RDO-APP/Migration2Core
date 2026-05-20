# EMERGENCY DIAGNOSTIC: ESCOLHER OBRA BLANK PAGE
# This will capture the ACTUAL HTTP response to see what's being sent

Write-Host "🚨 EMERGENCY DIAGNOSTIC: ESCOLHER OBRA BLANK PAGE" -ForegroundColor Red
Write-Host "=" * 80

# Step 1: Check if server is running
Write-Host "`n📡 Step 1: Checking if server is running..." -ForegroundColor Cyan
$serverRunning = $false
try {
    $response = Invoke-WebRequest -Uri "https://localhost:7201" -Method GET -SkipCertificateCheck -TimeoutSec 5 -ErrorAction SilentlyContinue
    $serverRunning = $true
    Write-Host "✅ Server is running on https://localhost:7201" -ForegroundColor Green
} catch {
    Write-Host "❌ Server is NOT running" -ForegroundColor Red
    Write-Host "Please start the server first with: dotnet run" -ForegroundColor Yellow
    exit 1
}

# Step 2: Test login to get authentication cookie
Write-Host "`n🔐 Step 2: Logging in to get authentication cookie..." -ForegroundColor Cyan
$loginUrl = "https://localhost:7201/Account/Login"
$escolherUrl = "https://localhost:7201/Obra/Escolher"

# Create a session to maintain cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    # Get login page first to get antiforgery token
    $loginPage = Invoke-WebRequest -Uri $loginUrl -Method GET -SessionVariable session -SkipCertificateCheck
    Write-Host "✅ Got login page" -ForegroundColor Green
    
    # Extract antiforgery token
    $token = ""
    if ($loginPage.Content -match 'name="__RequestVerificationToken"[^>]*value="([^"]+)"') {
        $token = $Matches[1]
        Write-Host "✅ Got antiforgery token: $($token.Substring(0, 20))..." -ForegroundColor Green
    }
    
    # Perform login
    $loginBody = @{
        "__RequestVerificationToken" = $token
        "cpf" = "567.065.455-20"
        "senha" = "RXL8DjdYj6Y="
    }
    
    $loginResponse = Invoke-WebRequest -Uri $loginUrl -Method POST -Body $loginBody -WebSession $session -SkipCertificateCheck -MaximumRedirection 0 -ErrorAction SilentlyContinue
    
    if ($loginResponse.StatusCode -eq 302 -or $loginResponse.StatusCode -eq 200) {
        Write-Host "✅ Login successful" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Login response: $($loginResponse.StatusCode)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "⚠️  Login attempt completed (may have redirected)" -ForegroundColor Yellow
}

# Step 3: Request Escolher page and capture FULL response
Write-Host "`n📄 Step 3: Requesting Escolher page..." -ForegroundColor Cyan
try {
    $escolherResponse = Invoke-WebRequest -Uri $escolherUrl -Method GET -WebSession $session -SkipCertificateCheck
    
    Write-Host "✅ Got response from Escolher" -ForegroundColor Green
    Write-Host "Status Code: $($escolherResponse.StatusCode)" -ForegroundColor Cyan
    Write-Host "Content Length: $($escolherResponse.Content.Length) bytes" -ForegroundColor Cyan
    Write-Host "Content Type: $($escolherResponse.Headers['Content-Type'])" -ForegroundColor Cyan
    
    # Save full HTML response to file
    $htmlFile = "escolher-response-emergency.html"
    $escolherResponse.Content | Out-File -FilePath $htmlFile -Encoding UTF8
    Write-Host "✅ Saved full HTML response to: $htmlFile" -ForegroundColor Green
    
    # Analyze the HTML content
    Write-Host "`n🔍 Step 4: Analyzing HTML content..." -ForegroundColor Cyan
    
    $html = $escolherResponse.Content
    
    # Check for DOCTYPE
    if ($html -match '<!DOCTYPE') {
        Write-Host "✅ Has DOCTYPE declaration" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing DOCTYPE declaration" -ForegroundColor Red
    }
    
    # Check for HTML tag
    if ($html -match '<html') {
        Write-Host "✅ Has <html> tag" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing <html> tag" -ForegroundColor Red
    }
    
    # Check for HEAD section
    if ($html -match '<head>') {
        Write-Host "✅ Has <head> section" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing <head> section" -ForegroundColor Red
    }
    
    # Check for BODY section
    if ($html -match '<body') {
        Write-Host "✅ Has <body> section" -ForegroundColor Green
        
        # Extract body content length
        if ($html -match '<body[^>]*>(.*)</body>') {
            $bodyContent = $Matches[1]
            Write-Host "   Body content length: $($bodyContent.Length) characters" -ForegroundColor Cyan
            
            if ($bodyContent.Length -lt 100) {
                Write-Host "   ⚠️  Body content is VERY SHORT!" -ForegroundColor Yellow
                Write-Host "   Body content: $bodyContent" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "❌ Missing <body> section" -ForegroundColor Red
    }
    
    # Check for debug info
    if ($html -match 'DEBUG INFO') {
        Write-Host "✅ Has DEBUG INFO section" -ForegroundColor Green
        
        # Extract model count
        if ($html -match 'Model count:</strong>\s*(\d+)') {
            $modelCount = $Matches[1]
            Write-Host "   📊 Model count: $modelCount" -ForegroundColor Cyan
        }
        
        # Extract model is null
        if ($html -match 'Model is null:</strong>\s*(\w+)') {
            $modelIsNull = $Matches[1]
            Write-Host "   📊 Model is null: $modelIsNull" -ForegroundColor Cyan
        }
    } else {
        Write-Host "❌ Missing DEBUG INFO section" -ForegroundColor Red
    }
    
    # Check for obra cards
    if ($html -match 'lista-obras') {
        Write-Host "✅ Has lista-obras section" -ForegroundColor Green
        
        # Count obra items
        $obraCount = ([regex]::Matches($html, '<div class="item">')).Count
        Write-Host "   📊 Found $obraCount obra cards in HTML" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Missing lista-obras section" -ForegroundColor Red
    }
    
    # Check for CSS links
    $cssLinks = ([regex]::Matches($html, '<link[^>]*rel="stylesheet"[^>]*>')).Count
    Write-Host "📊 Found $cssLinks CSS link tags" -ForegroundColor Cyan
    
    # Check for inline styles
    if ($html -match '<style>') {
        Write-Host "✅ Has inline <style> section" -ForegroundColor Green
    } else {
        Write-Host "❌ Missing inline <style> section" -ForegroundColor Red
    }
    
    # Check for JavaScript
    $scriptTags = ([regex]::Matches($html, '<script')).Count
    Write-Host "📊 Found $scriptTags <script> tags" -ForegroundColor Cyan
    
    Write-Host "`n" + ("=" * 80)
    Write-Host "🎯 DIAGNOSIS COMPLETE" -ForegroundColor Green
    Write-Host "=" * 80
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "1. Open the saved HTML file: $htmlFile" -ForegroundColor White
    Write-Host "2. Check if it contains the expected content" -ForegroundColor White
    Write-Host "3. Compare with what you see in the browser" -ForegroundColor White
    Write-Host "4. Check browser F12 Console for JavaScript errors" -ForegroundColor White
    Write-Host "5. Check browser F12 Network tab for failed resource loads" -ForegroundColor White
    
} catch {
    Write-Host "❌ Error requesting Escolher page: $_" -ForegroundColor Red
    Write-Host "Exception: $($_.Exception.Message)" -ForegroundColor Red
}
