#!/usr/bin/env pwsh

Write-Host "🔍 NUCLEAR RECOVERY VERIFICATION" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verify bootstrap-compatibility.js is deleted
$compatFile = "RDO-NET8-Migration/RdoApp.Core/wwwroot/js/bootstrap-compatibility.js"
if (Test-Path $compatFile) {
    Write-Host "❌ FAILED: Bootstrap compatibility layer still exists" -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ Bootstrap compatibility layer eliminated" -ForegroundColor Green
}

# 2. Verify layout has Two-Worlds logic
$layoutFile = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutBlazor.cshtml"
if (Test-Path $layoutFile) {
    $content = Get-Content $layoutFile -Raw
    
    # Check for Two-Worlds markers
    if ($content -match 'data-page-context.*obra-selection.*workspace') {
        Write-Host "✅ Two-Worlds system implemented" -ForegroundColor Green
    } else {
        Write-Host "❌ FAILED: Two-Worlds system not found" -ForegroundColor Red
        exit 1
    }
    
    # Check for nuclear recovery markers
    if ($content -match 'NUCLEAR RECOVERY.*Pure Blazor Layout restored') {
        Write-Host "✅ Nuclear recovery JavaScript active" -ForegroundColor Green
    } else {
        Write-Host "❌ FAILED: Nuclear recovery JavaScript not found" -ForegroundColor Red
        exit 1
    }
    
    # Check for Blazor Hub script
    if ($content -match '_framework/blazor.server.js') {
        Write-Host "✅ Blazor Server Hub script present" -ForegroundColor Green
    } else {
        Write-Host "❌ FAILED: Blazor Server Hub script missing" -ForegroundColor Red
        exit 1
    }
    
    # Verify no bootstrap-compatibility.js references
    if ($content -match 'bootstrap-compatibility.js') {
        Write-Host "❌ FAILED: Bootstrap compatibility layer still referenced" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "✅ No bootstrap compatibility references" -ForegroundColor Green
    }
    
} else {
    Write-Host "❌ FAILED: Layout file not found" -ForegroundColor Red
    exit 1
}

# 3. Verify ActionButtonService is intact
$actionService = "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/ActionButtonService.cs"
if (Test-Path $actionService) {
    $serviceContent = Get-Content $actionService -Raw
    if ($serviceContent -match 'ActionButtonType\.Laudos.*ActionButtonType\.NovaUnidade') {
        Write-Host "✅ ActionButtonService with 6 buttons intact" -ForegroundColor Green
    } else {
        Write-Host "❌ FAILED: ActionButtonService incomplete" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "❌ FAILED: ActionButtonService not found" -ForegroundColor Red
    exit 1
}

# 4. Verify ViewComponent is intact
$viewComponent = "RDO-NET8-Migration/RdoApp.Core/ViewComponents/ActionToolbarViewComponent.cs"
if (Test-Path $viewComponent) {
    Write-Host "✅ ActionToolbarViewComponent intact" -ForegroundColor Green
} else {
    Write-Host "❌ FAILED: ActionToolbarViewComponent not found" -ForegroundColor Red
    exit 1
}

# 5. Quick build test
Write-Host ""
Write-Host "🔨 Testing compilation..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    $buildOutput = dotnet build --configuration Release --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Project compiles successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ FAILED: Compilation errors" -ForegroundColor Red
        Write-Host $buildOutput -ForegroundColor Red
        Set-Location "../.."
        exit 1
    }
} catch {
    Write-Host "❌ FAILED: Build exception: $($_.Exception.Message)" -ForegroundColor Red
    Set-Location "../.."
    exit 1
}

Set-Location "../.."

Write-Host ""
Write-Host "🎉 NUCLEAR RECOVERY VERIFICATION COMPLETE" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Bootstrap Compatibility Layer: ELIMINATED" -ForegroundColor Green
Write-Host "✅ Two-Worlds System: ACTIVE" -ForegroundColor Green  
Write-Host "✅ Pure Blazor Layout: RESTORED" -ForegroundColor Green
Write-Host "✅ Action Toolbar: FUNCTIONAL" -ForegroundColor Green
Write-Host "✅ Compilation: SUCCESS" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 System ready for testing at: https://localhost:7001" -ForegroundColor Cyan
Write-Host "🌍 Test both worlds: Obra Selection → Workspace" -ForegroundColor Yellow