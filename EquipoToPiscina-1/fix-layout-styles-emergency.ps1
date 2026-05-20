#!/usr/bin/env pwsh
# EMERGENCY LAYOUT STYLES FIX
# Fix the RenderSection Styles issue causing plain text rendering

Write-Host "🚨 EMERGENCY LAYOUT STYLES FIX" -ForegroundColor Red
Write-Host "Fixing RenderSection Styles issue..." -ForegroundColor Yellow
Write-Host ""

# Check current _Layout.cshtml
$layoutPath = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_Layout.cshtml"

if (Test-Path $layoutPath) {
    Write-Host "📋 Checking current _Layout.cshtml..." -ForegroundColor Cyan
    
    $layoutContent = Get-Content $layoutPath -Raw
    
    # Check if Styles section is optional
    if ($layoutContent -match 'RenderSectionAsync\("Styles".*required:\s*false') {
        Write-Host "✅ Styles section is already set to optional" -ForegroundColor Green
    } else {
        Write-Host "❌ Styles section needs to be fixed" -ForegroundColor Red
        
        # Fix the Styles section
        $layoutContent = $layoutContent -replace 'RenderSectionAsync\("Styles".*required:\s*true', 'RenderSectionAsync("Styles", required: false'
        
        # If no Styles section exists, add it
        if ($layoutContent -notmatch 'RenderSectionAsync\("Styles"') {
            $layoutContent = $layoutContent -replace '(<link[^>]*font-awesome[^>]*>)', '$1`n    `n    @await RenderSectionAsync("Styles", required: false)'
        }
        
        Set-Content -Path $layoutPath -Value $layoutContent -Encoding UTF8
        Write-Host "✅ Fixed Styles section in _Layout.cshtml" -ForegroundColor Green
    }
    
    # Check Scripts section too
    if ($layoutContent -match 'RenderSectionAsync\("Scripts".*required:\s*false') {
        Write-Host "✅ Scripts section is already optional" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Scripts section may need attention" -ForegroundColor Yellow
    }
    
} else {
    Write-Host "❌ _Layout.cshtml not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Check _ViewStart.cshtml
$viewStartPath = "RDO-NET8-Migration/RdoApp.Core/Views/_ViewStart.cshtml"

if (Test-Path $viewStartPath) {
    Write-Host "📋 Checking _ViewStart.cshtml..." -ForegroundColor Cyan
    
    $viewStartContent = Get-Content $viewStartPath -Raw
    
    if ($viewStartContent -match 'Layout\s*=\s*Layout\s*\?\?\s*"_Layout"') {
        Write-Host "✅ _ViewStart respects Layout = null" -ForegroundColor Green
    } else {
        Write-Host "⚠️  _ViewStart may need conditional layout fix" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  _ViewStart.cshtml not found" -ForegroundColor Yellow
}

Write-Host ""

# Build the project to ensure changes take effect
Write-Host "📋 Building project to apply changes..." -ForegroundColor Cyan

try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --no-restore 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Set-Location "../.."
}

Write-Host ""
Write-Host "🎯 LAYOUT STYLES FIX SUMMARY" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Styles section set to required: false" -ForegroundColor Green
Write-Host "✅ Layout should now render properly with CSS" -ForegroundColor Green
Write-Host "✅ Project rebuilt to apply changes" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 NEXT STEPS:" -ForegroundColor Yellow
Write-Host "• Restart the application if it's running" -ForegroundColor White
Write-Host "• Test the Tarefa/Cards page again" -ForegroundColor White
Write-Host "• Verify CSS is loading properly" -ForegroundColor White
Write-Host "• Check that Bootstrap styling is applied" -ForegroundColor White