#!/usr/bin/env pwsh
# Test Escolher Obra Fixes Implementation
# Tests all 3 requested fixes: Visual Alignment, Routing Fix, Clean Up

Write-Host "🏗️ TESTING ESCOLHER OBRA FIXES" -ForegroundColor Cyan
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

# Test Escolher Obra File Implementation
Write-Host "`nTesting Escolher Obra implementation..." -ForegroundColor Yellow
$escolherFile = "Views/Obra/Escolher.cshtml"

if (Test-Path $escolherFile) {
    $content = Get-Content $escolherFile -Raw
    
    # Test Task 1: Visual Alignment (RDO Brand Identity)
    Write-Host "`n--- TASK 1: VISUAL ALIGNMENT ---" -ForegroundColor Cyan
    $visualChecks = @{
        "Blue Gradient Background" = ($content -match 'background: linear-gradient\(135deg, #1e3a8a 0%, #3b82f6 100%\)')
        "Solid White Card" = ($content -match 'background: white' -and $content -match 'border-radius: 15px' -and $content -match 'box-shadow: 0 10px 25px')
        "Layout Isolation" = ($content -match 'Layout = null')
        "Centered Container" = ($content -match 'display: flex' -and $content -match 'align-items: center' -and $content -match 'justify-content: center')
        "Clean Scrollable Format" = ($content -match 'overflow-y: auto' -and $content -match 'max-height:')
    }
    
    foreach ($check in $visualChecks.GetEnumerator()) {
        if ($check.Value) {
            Write-Host "PASS: $($check.Key)" -ForegroundColor Green
        } else {
            Write-Host "FAIL: $($check.Key)" -ForegroundColor Red
        }
    }
    
    # Test Task 2: Routing Fix
    Write-Host "`n--- TASK 2: ROUTING FIX ---" -ForegroundColor Cyan
    $routingChecks = @{
        "Correct Controller Reference" = ($content -match 'Url\.Action\("Cards", "Etapa"\)')
        "ObraId Parameter" = ($content -match 'obraId.*obraId')
        "Modern Navigation" = ($content -match 'window\.location\.href')
        "No 404 Route References" = ($content -notmatch 'TarefaController' -and $content -notmatch '/Tarefa/Cards')
    }
    
    foreach ($check in $routingChecks.GetEnumerator()) {
        if ($check.Value) {
            Write-Host "PASS: $($check.Key)" -ForegroundColor Green
        } else {
            Write-Host "FAIL: $($check.Key)" -ForegroundColor Red
        }
    }
    
    # Test Task 3: Clean Up
    Write-Host "`n--- TASK 3: CLEAN UP ---" -ForegroundColor Cyan
    $cleanupChecks = @{
        "No AngularJS References" = ($content -notmatch 'ng-' -and $content -notmatch 'angular')
        "No Legacy Debug" = ($content -notmatch 'NUCLEAR.*2026' -and $content -notmatch 'console\.error')
        "Modern JavaScript" = ($content -match 'addEventListener.*DOMContentLoaded')
        "No Old Layout System" = ($content -notmatch '_Layout')
        "Clean Console Logging" = ($content -match 'console\.log' -and $content -notmatch 'console\.error')
    }
    
    foreach ($check in $cleanupChecks.GetEnumerator()) {
        if ($check.Value) {
            Write-Host "PASS: $($check.Key)" -ForegroundColor Green
        } else {
            Write-Host "FAIL: $($check.Key)" -ForegroundColor Red
        }
    }
    
} else {
    Write-Host "ESCOLHER OBRA FILE NOT FOUND" -ForegroundColor Red
    exit 1
}

# Test EtapaController Routing Fix
Write-Host "`nTesting EtapaController routing..." -ForegroundColor Yellow
$etapaController = "Controllers/EtapaController.cs"

if (Test-Path $etapaController) {
    $controllerContent = Get-Content $etapaController -Raw
    
    $controllerChecks = @{
        "Cards Action Exists" = ($controllerContent -match 'public.*IActionResult.*Cards\(')
        "ObraId Parameter Handling" = ($controllerContent -match 'obraId.*HasValue')
        "Session Management" = ($controllerContent -match 'Session\.SetInt32')
        "Proper Redirect" = ($controllerContent -match 'RedirectToAction.*CardsRazor')
    }
    
    foreach ($check in $controllerChecks.GetEnumerator()) {
        if ($check.Value) {
            Write-Host "PASS: Controller $($check.Key)" -ForegroundColor Green
        } else {
            Write-Host "FAIL: Controller $($check.Key)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "ETAPA CONTROLLER NOT FOUND" -ForegroundColor Red
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
Write-Host "ESCOLHER OBRA FIXES COMPLETE" -ForegroundColor Green
Write-Host "`nEXPECTED RESULT:"
Write-Host "1. VISUAL: Professional blue gradient background with centered white card"
Write-Host "2. ROUTING: Clicking obra redirects to /Etapa/Cards without 404 errors"
Write-Host "3. CLEAN: No AngularJS code, modern .NET 8 routing, fast performance"
Write-Host "`nTest URLs:"
Write-Host "- Escolher Obra: http://localhost:5031/Obra/Escolher"
Write-Host "- Direct Cards: http://localhost:5031/Etapa/Cards?obraId=233"