#!/usr/bin/env pwsh

Write-Host "=== LAYOUT CONFIGURATION TEST ===" -ForegroundColor Cyan

Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "`n1. Testing Layout Files..." -ForegroundColor Green

# Test if _LayoutSelection.cshtml exists
if (Test-Path "Views/Shared/_LayoutSelection.cshtml") {
    Write-Host "✅ _LayoutSelection.cshtml exists" -ForegroundColor Green
    
    $layoutContent = Get-Content "Views/Shared/_LayoutSelection.cshtml" -Raw
    
    if ($layoutContent -match "fontello\.css") {
        Write-Host "✅ fontello.css reference found in layout" -ForegroundColor Green
    } else {
        Write-Host "❌ fontello.css reference NOT found in layout" -ForegroundColor Red
    }
    
    if ($layoutContent -match "rdo-unified-theme\.css") {
        Write-Host "✅ rdo-unified-theme.css reference found in layout" -ForegroundColor Green
    } else {
        Write-Host "❌ rdo-unified-theme.css reference NOT found in layout" -ForegroundColor Red
    }
    
    if ($layoutContent -match "UnifiedRdoHeader") {
        Write-Host "✅ UnifiedRdoHeader component found in layout" -ForegroundColor Green
    } else {
        Write-Host "❌ UnifiedRdoHeader component NOT found in layout" -ForegroundColor Red
    }
} else {
    Write-Host "❌ _LayoutSelection.cshtml does NOT exist" -ForegroundColor Red
}

Write-Host "`n2. Testing Obra/Escolher View..." -ForegroundColor Green

if (Test-Path "Views/Obra/Escolher.cshtml") {
    Write-Host "✅ Escolher.cshtml exists" -ForegroundColor Green
    
    $escolherContent = Get-Content "Views/Obra/Escolher.cshtml" -Raw
    Write-Host "Escolher.cshtml content preview:" -ForegroundColor White
    Write-Host ($escolherContent.Substring(0, [Math]::Min(500, $escolherContent.Length))) -ForegroundColor Cyan
    
    if ($escolherContent -match "_LayoutSelection") {
        Write-Host "✅ Escolher.cshtml uses _LayoutSelection layout" -ForegroundColor Green
    } else {
        Write-Host "❌ Escolher.cshtml does NOT use _LayoutSelection layout" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Escolher.cshtml does NOT exist" -ForegroundColor Red
}

Write-Host "`n3. Testing Blazor Components..." -ForegroundColor Green

$components = @(
    "Components/UnifiedRdoHeader.razor",
    "Components/RdoObraCards.razor"
)

foreach ($component in $components) {
    if (Test-Path $component) {
        Write-Host "✅ $component exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $component does NOT exist" -ForegroundColor Red
    }
}

Write-Host "`n4. Testing CSS Files..." -ForegroundColor Green

$cssFiles = @(
    "wwwroot/css/fontello.css",
    "wwwroot/css/rdo-unified-theme.css",
    "wwwroot/Assets/images/user.png"
)

foreach ($cssFile in $cssFiles) {
    if (Test-Path $cssFile) {
        $size = (Get-Item $cssFile).Length
        Write-Host "✅ $cssFile exists ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "❌ $cssFile does NOT exist" -ForegroundColor Red
    }
}

Write-Host "`n5. Testing Program.cs Configuration..." -ForegroundColor Green

$programContent = Get-Content "Program.cs" -Raw

$checks = @(
    @{ Pattern = "AddServerSideBlazor"; Name = "Blazor Server services" },
    @{ Pattern = "MapBlazorHub"; Name = "Blazor Hub mapping" },
    @{ Pattern = "UseStaticFiles"; Name = "Static files middleware" }
)

foreach ($check in $checks) {
    if ($programContent -match $check.Pattern) {
        Write-Host "✅ $($check.Name) configured" -ForegroundColor Green
    } else {
        Write-Host "❌ $($check.Name) NOT configured" -ForegroundColor Red
    }
}

Write-Host "`n6. Starting Server for HTTP Tests..." -ForegroundColor Green

# Kill any existing processes
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

$process = Start-Process -FilePath "dotnet" -ArgumentList "run", "--urls=http://localhost:5000" -PassThru -NoNewWindow
Write-Host "Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

try {
    Write-Host "`n7. Testing HTTP Asset Requests..." -ForegroundColor Green
    
    $testUrls = @(
        "http://localhost:5000/css/fontello.css",
        "http://localhost:5000/css/rdo-unified-theme.css",
        "http://localhost:5000/Assets/images/user.png"
    )
    
    foreach ($url in $testUrls) {
        try {
            $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing
            Write-Host "✅ $url - Status: $($response.StatusCode)" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ $url - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
finally {
    Write-Host "`nStopping server..." -ForegroundColor Yellow
    if ($process -and !$process.HasExited) {
        $process.Kill()
    }
    Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
}

Write-Host "`n=== LAYOUT CONFIGURATION TEST COMPLETE ===" -ForegroundColor Cyan
Write-Host "`nCONCLUSION:" -ForegroundColor White
Write-Host "If all files exist and HTTP requests work, the issue is likely:" -ForegroundColor Yellow
Write-Host "  1. Browser cache showing old version" -ForegroundColor Cyan
Write-Host "  2. Blazor component not rendering properly" -ForegroundColor Cyan
Write-Host "  3. Authentication affecting component state" -ForegroundColor Cyan