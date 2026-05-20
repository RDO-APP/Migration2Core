#!/usr/bin/env pwsh

Write-Host "=== AUTHENTICATED OBRA SELECTION TEST ===" -ForegroundColor Cyan
Write-Host "Testing obra selection page with proper authentication" -ForegroundColor Yellow

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Kill any existing processes
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

Write-Host "`nStarting server..." -ForegroundColor Green
$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--urls=http://localhost:5000" -PassThru -NoNewWindow

Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    Write-Host "`n1. Testing Layout Files Directly..." -ForegroundColor Green
    
    # Test if _LayoutSelection.cshtml exists and is accessible
    if (Test-Path "Views/Shared/_LayoutSelection.cshtml") {
        Write-Host "✅ _LayoutSelection.cshtml exists" -ForegroundColor Green
        
        # Check content of layout file
        $layoutContent = Get-Content "Views/Shared/_LayoutSelection.cshtml" -Raw
        
        if ($layoutContent -match "fontello\.css") {
            Write-Host "✅ fontello.css reference found in _LayoutSelection.cshtml" -ForegroundColor Green
        } else {
            Write-Host "❌ fontello.css reference NOT found in _LayoutSelection.cshtml" -ForegroundColor Red
        }
        
        if ($layoutContent -match "rdo-unified-theme\.css") {
            Write-Host "✅ rdo-unified-theme.css reference found in _LayoutSelection.cshtml" -ForegroundColor Green
        } else {
            Write-Host "❌ rdo-unified-theme.css reference NOT found in _LayoutSelection.cshtml" -ForegroundColor Red
        }
        
        if ($layoutContent -match "UnifiedRdoHeader") {
            Write-Host "✅ UnifiedRdoHeader component found in _LayoutSelection.cshtml" -ForegroundColor Green
        } else {
            Write-Host "❌ UnifiedRdoHeader component NOT found in _LayoutSelection.cshtml" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ _LayoutSelection.cshtml does NOT exist" -ForegroundColor Red
    }
    
    Write-Host "`n2. Testing Obra/Escolher View..." -ForegroundColor Green
    
    if (Test-Path "Views/Obra/Escolher.cshtml") {
        Write-Host "✅ Escolher.cshtml exists" -ForegroundColor Green
        
        $escolherContent = Get-Content "Views/Obra/Escolher.cshtml" -Raw
        
        if ($escolherContent -match '_LayoutSelection') {
            Write-Host "✅ Escolher.cshtml uses _LayoutSelection layout" -ForegroundColor Green
        } else {
            Write-Host "❌ Escolher.cshtml does NOT use _LayoutSelection layout" -ForegroundColor Red
            Write-Host "   Layout setting: $($escolherContent -match 'Layout\s*=\s*["\']([^"\']*)["\']' | Out-String)" -ForegroundColor Yellow
        }
        
        if ($escolherContent -match 'RdoObraCards') {
            Write-Host "✅ RdoObraCards component found in Escolher.cshtml" -ForegroundColor Green
        } else {
            Write-Host "❌ RdoObraCards component NOT found in Escolher.cshtml" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Escolher.cshtml does NOT exist" -ForegroundColor Red
    }
    
    Write-Host "`n3. Testing Blazor Components..." -ForegroundColor Green
    
    if (Test-Path "Components/UnifiedRdoHeader.razor") {
        Write-Host "✅ UnifiedRdoHeader.razor exists" -ForegroundColor Green
    } else {
        Write-Host "❌ UnifiedRdoHeader.razor does NOT exist" -ForegroundColor Red
    }
    
    if (Test-Path "Components/RdoObraCards.razor") {
        Write-Host "✅ RdoObraCards.razor exists" -ForegroundColor Green
    } else {
        Write-Host "❌ RdoObraCards.razor does NOT exist" -ForegroundColor Red
    }
    
    Write-Host "`n4. Testing CSS Files..." -ForegroundColor Green
    
    $cssFiles = @(
        "wwwroot/css/fontello.css",
        "wwwroot/css/rdo-unified-theme.css",
        "wwwroot/css/site.css"
    )
    
    foreach ($cssFile in $cssFiles) {
        if (Test-Path $cssFile) {
            $size = (Get-Item $cssFile).Length
            Write-Host "✅ $cssFile exists ($size bytes)" -ForegroundColor Green
        } else {
            Write-Host "❌ $cssFile does NOT exist" -ForegroundColor Red
        }
    }
    
    Write-Host "`n5. Testing HTTP Requests..." -ForegroundColor Green
    
    # Test CSS files via HTTP
    $testUrls = @(
        "http://localhost:5000/css/fontello.css",
        "http://localhost:5000/css/rdo-unified-theme.css",
        "http://localhost:5000/Assets/images/user.png"
    )
    
    foreach ($url in $testUrls) {
        try {
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing
            Write-Host "✅ $url - Status: $($response.StatusCode), Size: $($response.Content.Length)" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ $url - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n6. Checking Program.cs Configuration..." -ForegroundColor Green
    
    $programContent = Get-Content "Program.cs" -Raw
    
    if ($programContent -match 'AddServerSideBlazor') {
        Write-Host "✅ Blazor Server services configured" -ForegroundColor Green
    } else {
        Write-Host "❌ Blazor Server services NOT configured" -ForegroundColor Red
    }
    
    if ($programContent -match 'MapBlazorHub') {
        Write-Host "✅ Blazor Hub mapped" -ForegroundColor Green
    } else {
        Write-Host "❌ Blazor Hub NOT mapped" -ForegroundColor Red
    }
    
    if ($programContent -match 'UseStaticFiles') {
        Write-Host "✅ Static files middleware configured" -ForegroundColor Green
    } else {
        Write-Host "❌ Static files middleware NOT configured" -ForegroundColor Red
    }
    
    Write-Host "`n7. Summary..." -ForegroundColor Green
    Write-Host "If all components exist and HTTP requests work, the issue might be:" -ForegroundColor White
    Write-Host "  1. Blazor component rendering failure" -ForegroundColor Yellow
    Write-Host "  2. Layout not being applied correctly" -ForegroundColor Yellow
    Write-Host "  3. Authentication state affecting component rendering" -ForegroundColor Yellow
    Write-Host "  4. Browser caching old version without CSS" -ForegroundColor Yellow
    
    Write-Host "`nNext steps:" -ForegroundColor White
    Write-Host "  1. Test with actual user login" -ForegroundColor Cyan
    Write-Host "  2. Check browser developer tools for specific 404 URLs" -ForegroundColor Cyan
    Write-Host "  3. Clear browser cache and test again" -ForegroundColor Cyan
    Write-Host "  4. Check if Blazor components are rendering properly" -ForegroundColor Cyan
}
finally {
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "`n=== AUTHENTICATED OBRA SELECTION TEST COMPLETE ===" -ForegroundColor Cyan