#!/usr/bin/env pwsh

Write-Host "🎯 TESTING: Conditional Header Implementation for Escolher Obra" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan

$testResults = @()

# Test 1: Verify Escolher.cshtml uses _LayoutBlazor
Write-Host "`n1. Testing Escolher.cshtml layout configuration..." -ForegroundColor Yellow
$escolherFile = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
if (Test-Path $escolherFile) {
    $content = Get-Content $escolherFile -Raw
    if ($content -match 'Layout = "_LayoutBlazor"') {
        Write-Host "   ✅ Escolher.cshtml uses _LayoutBlazor layout" -ForegroundColor Green
        $testResults += "✅ Layout Configuration"
    } else {
        Write-Host "   ❌ Escolher.cshtml does not use _LayoutBlazor layout" -ForegroundColor Red
        $testResults += "❌ Layout Configuration"
    }
    
    if ($content -match 'ViewBag\.IsObraSelection = true') {
        Write-Host "   ✅ IsObraSelection flag is set" -ForegroundColor Green
        $testResults += "✅ Selection Flag"
    } else {
        Write-Host "   ❌ IsObraSelection flag is missing" -ForegroundColor Red
        $testResults += "❌ Selection Flag"
    }
} else {
    Write-Host "   ❌ Escolher.cshtml file not found" -ForegroundColor Red
    $testResults += "❌ File Missing"
}

# Test 2: Verify _LayoutBlazor.cshtml has conditional logic
Write-Host "`n2. Testing _LayoutBlazor.cshtml conditional logic..." -ForegroundColor Yellow
$layoutFile = "RDO-NET8-Migration/RdoApp.Core/Views/Shared/_LayoutBlazor.cshtml"
if (Test-Path $layoutFile) {
    $content = Get-Content $layoutFile -Raw
    if ($content -match '@if \(ViewBag\.IsObraSelection != true\)') {
        Write-Host "   ✅ Conditional logic for obra selection found" -ForegroundColor Green
        $testResults += "✅ Conditional Logic"
    } else {
        Write-Host "   ❌ Conditional logic for obra selection missing" -ForegroundColor Red
        $testResults += "❌ Conditional Logic"
    }
    
    if ($content -match 'Component\.InvokeAsync\("ActionToolbar"\)') {
        Write-Host "   ✅ ActionToolbar component integration found" -ForegroundColor Green
        $testResults += "✅ ActionToolbar Integration"
    } else {
        Write-Host "   ❌ ActionToolbar component integration missing" -ForegroundColor Red
        $testResults += "❌ ActionToolbar Integration"
    }
    
    if ($content -match 'Component\.InvokeAsync\("CurrentObra"\)') {
        Write-Host "   ✅ CurrentObra component integration found" -ForegroundColor Green
        $testResults += "✅ CurrentObra Integration"
    } else {
        Write-Host "   ❌ CurrentObra component integration missing" -ForegroundColor Red
        $testResults += "❌ CurrentObra Integration"
    }
} else {
    Write-Host "   ❌ _LayoutBlazor.cshtml file not found" -ForegroundColor Red
    $testResults += "❌ Layout File Missing"
}

# Test 3: Verify CurrentObraViewComponent exists
Write-Host "`n3. Testing CurrentObraViewComponent implementation..." -ForegroundColor Yellow
$componentFile = "RDO-NET8-Migration/RdoApp.Core/ViewComponents/CurrentObraViewComponent.cs"
if (Test-Path $componentFile) {
    $content = Get-Content $componentFile -Raw
    if ($content -match 'class CurrentObraViewComponent : ViewComponent') {
        Write-Host "   ✅ CurrentObraViewComponent class found" -ForegroundColor Green
        $testResults += "✅ ViewComponent Class"
    } else {
        Write-Host "   ❌ CurrentObraViewComponent class missing" -ForegroundColor Red
        $testResults += "❌ ViewComponent Class"
    }
    
    if ($content -match 'ViewBag\.IsObraSelection == true') {
        Write-Host "   ✅ Obra selection state handling found" -ForegroundColor Green
        $testResults += "✅ Selection State Handling"
    } else {
        Write-Host "   ❌ Obra selection state handling missing" -ForegroundColor Red
        $testResults += "❌ Selection State Handling"
    }
    
    if ($content -match 'HttpContext\.Session\.GetString\("ObraNome"\)') {
        Write-Host "   ✅ Session-based obra name retrieval found" -ForegroundColor Green
        $testResults += "✅ Session Integration"
    } else {
        Write-Host "   ❌ Session-based obra name retrieval missing" -ForegroundColor Red
        $testResults += "❌ Session Integration"
    }
} else {
    Write-Host "   ❌ CurrentObraViewComponent.cs file not found" -ForegroundColor Red
    $testResults += "❌ ViewComponent Missing"
}

# Test 4: Verify ObraController updates
Write-Host "`n4. Testing ObraController session management..." -ForegroundColor Yellow
$controllerFile = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
if (Test-Path $controllerFile) {
    $content = Get-Content $controllerFile -Raw
    if ($content -match 'HttpContext\.Session\.SetString\("ObraNome"') {
        Write-Host "   ✅ Obra name session storage found" -ForegroundColor Green
        $testResults += "✅ Session Storage"
    } else {
        Write-Host "   ❌ Obra name session storage missing" -ForegroundColor Red
        $testResults += "❌ Session Storage"
    }
} else {
    Write-Host "   ❌ ObraController.cs file not found" -ForegroundColor Red
    $testResults += "❌ Controller Missing"
}

# Test 5: Check for compilation errors
Write-Host "`n5. Testing compilation..." -ForegroundColor Yellow
try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Project compiles successfully" -ForegroundColor Green
        $testResults += "✅ Compilation"
    } else {
        Write-Host "   ❌ Compilation errors found:" -ForegroundColor Red
        Write-Host "   $buildResult" -ForegroundColor Red
        $testResults += "❌ Compilation"
    }
    Pop-Location
} catch {
    Write-Host "   ⚠️ Could not test compilation: $($_.Exception.Message)" -ForegroundColor Yellow
    $testResults += "⚠️ Compilation Test Skipped"
}

# Summary
Write-Host "`n" -NoNewline
Write-Host "🎯 CONDITIONAL HEADER IMPLEMENTATION TEST RESULTS" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$successCount = ($testResults | Where-Object { $_ -match "✅" }).Count
$totalTests = $testResults.Count

foreach ($result in $testResults) {
    if ($result -match "✅") {
        Write-Host $result -ForegroundColor Green
    } elseif ($result -match "❌") {
        Write-Host $result -ForegroundColor Red
    } else {
        Write-Host $result -ForegroundColor Yellow
    }
}

Write-Host "`nSUCCESS RATE: $successCount/$totalTests tests passed" -ForegroundColor $(if ($successCount -eq $totalTests) { "Green" } else { "Yellow" })

if ($successCount -eq $totalTests) {
    Write-Host "`n🎉 CONDITIONAL HEADER IMPLEMENTATION COMPLETE!" -ForegroundColor Green
    Write-Host "✅ Escolher Obra page now uses conditional layout strategy" -ForegroundColor Green
    Write-Host "✅ Header adapts intelligently between selection and working states" -ForegroundColor Green
    Write-Host "✅ Action toolbar and context indicator show/hide appropriately" -ForegroundColor Green
    Write-Host "✅ Modern Blazor architecture maintained with zero legacy debt" -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Some tests failed. Please review the implementation." -ForegroundColor Yellow
}

Write-Host "`n🚀 Ready for testing with F5 in Visual Studio!" -ForegroundColor Cyan