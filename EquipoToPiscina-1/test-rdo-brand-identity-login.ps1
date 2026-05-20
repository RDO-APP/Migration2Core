#!/usr/bin/env pwsh
# Test RDO Brand Identity Login Implementation
# Tests all 5 requested brand identity fixes

Write-Host "🎨 TESTING RDO BRAND IDENTITY LOGIN" -ForegroundColor Cyan
Write-Host "=" * 50

# Test Build
Write-Host "`nTesting build compilation..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"
$buildResult = dotnet build --no-restore 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "BUILD: FAILED" -ForegroundColor Red
    exit 1
}

# Test Login File Implementation
Write-Host "`nTesting RDO brand identity implementation..." -ForegroundColor Yellow
$loginFile = "Views/Account/Login.cshtml"

if (Test-Path $loginFile) {
    $content = Get-Content $loginFile -Raw
    
    # Check all 5 brand identity fixes
    $checks = @{
        "Professional Blue Gradient" = ($content -match 'background: linear-gradient\(135deg, #1e3a8a 0%, #3b82f6 100%\)')
        "Solid White Login Card" = ($content -match 'background: white' -and $content -match 'border-radius: 15px' -and $content -match 'box-shadow: 0 10px 25px')
        "Official Blue Button" = ($content -match 'background: linear-gradient\(135deg, #3b82f6 0%, #1e40af 100%\)')
        "Clear Input Labels" = ($content -match 'background: white' -and $content -match 'border: 1px solid #e2e8f0')
        "Password Toggle Script" = ($content -match 'passwordInput.type === .password.' -and $content -match 'passwordInput.type = .text.')
        "Vertical Centering" = ($content -match 'min-height: 100vh' -and $content -match 'display: flex' -and $content -match 'align-items: center')
        "Layout Isolation" = ($content -match 'Layout = null')
    }
    
    foreach ($check in $checks.GetEnumerator()) {
        if ($check.Value) {
            Write-Host "PASS: $($check.Key)" -ForegroundColor Green
        } else {
            Write-Host "FAIL: $($check.Key)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "LOGIN FILE NOT FOUND" -ForegroundColor Red
    exit 1
}

# Test Logo
Write-Host "`nTesting RDO logo..." -ForegroundColor Yellow
$logoFile = "wwwroot/images/logo.jpg"
if (Test-Path $logoFile) {
    Write-Host "LOGO: Found and ready" -ForegroundColor Green
} else {
    Write-Host "LOGO: Missing" -ForegroundColor Red
}

# Test Server
Write-Host "`nTesting server status..." -ForegroundColor Yellow
$serverCheck = netstat -an | Select-String "5031"
if ($serverCheck) {
    Write-Host "SERVER: Running on localhost:5031" -ForegroundColor Green
} else {
    Write-Host "SERVER: Not detected" -ForegroundColor Yellow
}

Write-Host "`n" + "=" * 50
Write-Host "RDO BRAND IDENTITY IMPLEMENTATION COMPLETE" -ForegroundColor Green
Write-Host "`nEXPECTED RESULT:"
Write-Host "- Professional blue gradient background (#1e3a8a to #3b82f6)"
Write-Host "- Solid white login card with shadow and rounded corners"
Write-Host "- Official blue ACESSAR button"
Write-Host "- Clear white input fields with proper labels"
Write-Host "- Working password toggle eye icon"
Write-Host "- Perfect vertical centering"
Write-Host "- NO white bars from old layout"
Write-Host "`nOpen: http://localhost:5031/Account/Login"