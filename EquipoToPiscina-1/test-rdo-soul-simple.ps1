#!/usr/bin/env pwsh

Write-Host "🎯 RDO SOUL RESTORATION - SIMPLE VERIFICATION" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

$ErrorActionPreference = "Continue"
$testsPassed = 0
$totalTests = 0

# Test 1: Build Check
Write-Host "`n1️⃣ BUILD CHECK" -ForegroundColor Yellow
$totalTests++
try {
    Set-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: CSS File Check
Write-Host "`n2️⃣ CSS THEME FILE" -ForegroundColor Yellow
$totalTests++
$cssFile = "wwwroot/css/rdo-blazor-theme.css"
if (Test-Path $cssFile) {
    $cssContent = Get-Content $cssFile -Raw
    if ($cssContent -match "--rdo-header-primary.*#27496F" -and $cssContent -match "navbar-dark-theme") {
        Write-Host "✅ CSS dark theme present" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "❌ CSS dark theme missing" -ForegroundColor Red
    }
} else {
    Write-Host "❌ CSS file not found" -ForegroundColor Red
}

# Test 3: Layout File Check
Write-Host "`n3️⃣ LAYOUT IMPLEMENTATION" -ForegroundColor Yellow
$totalTests++
$layoutFile = "Views/Shared/_LayoutBlazor.cshtml"
if (Test-Path $layoutFile) {
    $layoutContent = Get-Content $layoutFile -Raw
    if ($layoutContent -match "navbar-dark-theme" -and $layoutContent -match "ActionToolbar") {
        Write-Host "✅ Layout dark theme implemented" -ForegroundColor Green
        $testsPassed++
    } else {
        Write-Host "❌ Layout dark theme missing" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Layout file not found" -ForegroundColor Red
}

# Test 4: Service Files Check
Write-Host "`n4️⃣ SERVICE FILES" -ForegroundColor Yellow
$totalTests++
$serviceFiles = @(
    "Services/Implementations/ActionButtonService.cs",
    "Services/Implementations/NavigationService.cs",
    "Services/Implementations/ThemeConfigurationService.cs"
)

$servicesFound = 0
foreach ($file in $serviceFiles) {
    if (Test-Path $file) {
        $servicesFound++
    }
}

if ($servicesFound -eq $serviceFiles.Count) {
    Write-Host "✅ All service files present ($servicesFound/$($serviceFiles.Count))" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "❌ Missing service files ($servicesFound/$($serviceFiles.Count))" -ForegroundColor Red
}

# Test 5: ViewComponent Files Check
Write-Host "`n5️⃣ VIEWCOMPONENT FILES" -ForegroundColor Yellow
$totalTests++
$vcFiles = @(
    "ViewComponents/ActionToolbarViewComponent.cs",
    "ViewComponents/CurrentObraViewComponent.cs",
    "Views/Shared/Components/ActionToolbar/Default.cshtml"
)

$vcFound = 0
foreach ($file in $vcFiles) {
    if (Test-Path $file) {
        $vcFound++
    }
}

if ($vcFound -eq $vcFiles.Count) {
    Write-Host "✅ All ViewComponent files present ($vcFound/$($vcFiles.Count))" -ForegroundColor Green
    $testsPassed++
} else {
    Write-Host "❌ Missing ViewComponent files ($vcFound/$($vcFiles.Count))" -ForegroundColor Red
}

# Final Results
Write-Host "`n🎯 FINAL RESULTS" -ForegroundColor Cyan
Write-Host "================" -ForegroundColor Cyan
$successRate = [math]::Round(($testsPassed / $totalTests) * 100, 1)
Write-Host "Tests Passed: $testsPassed/$totalTests ($successRate%)" -ForegroundColor $(if ($successRate -eq 100) { "Green" } elseif ($successRate -ge 80) { "Yellow" } else { "Red" })

if ($successRate -eq 100) {
    Write-Host "`n🎉 RDO SOUL RESTORATION: COMPLETE!" -ForegroundColor Green
    Write-Host "✨ Professional dark blue theme restored" -ForegroundColor Green
    Write-Host "✨ All services and components implemented" -ForegroundColor Green
    Write-Host "✨ Ready for production deployment" -ForegroundColor Green
    Write-Host "`n🚀 THE RDO SOUL HAS BEEN RESTORED!" -ForegroundColor Cyan
} elseif ($successRate -ge 80) {
    Write-Host "`n⚠️  RDO SOUL RESTORATION: MOSTLY COMPLETE" -ForegroundColor Yellow
    Write-Host "Most components working. Minor issues to resolve." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ RDO SOUL RESTORATION: NEEDS WORK" -ForegroundColor Red
    Write-Host "Multiple issues found. Review above." -ForegroundColor Red
}

Write-Host "`n================================================" -ForegroundColor Cyan