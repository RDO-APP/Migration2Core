# Test Script for Homologation Environment
# Usage: .\Deploy\test-homolog.ps1

param(
    [string]$BaseUrl = "https://homolog.piscinas.rdoapp.com.br"
)

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RDO App - Homologation Test Suite    " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$testResults = @()

# Test 1: Basic connectivity
Write-Host "[1/8] Testing basic connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $BaseUrl -TimeoutSec 30 -UseBasicParsing
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✓ Application is accessible" -ForegroundColor Green
        $testResults += @{Test="Connectivity"; Status="PASS"; Details="HTTP 200"}
    } else {
        Write-Host "   ⚠ Unexpected status code: $($response.StatusCode)" -ForegroundColor Yellow
        $testResults += @{Test="Connectivity"; Status="WARN"; Details="HTTP $($response.StatusCode)"}
    }
} catch {
    Write-Host "   ✗ Connection failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += @{Test="Connectivity"; Status="FAIL"; Details=$_.Exception.Message}
}

# Test 2: Laudo index page
Write-Host "`n[2/8] Testing Laudo index page..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/laudos/index" -TimeoutSec 30 -UseBasicParsing
    if ($response.StatusCode -eq 200 -and $response.Content -notlike "*AGUARDE*") {
        Write-Host "   ✓ Laudo index page loads correctly" -ForegroundColor Green
        $testResults += @{Test="Laudo Index"; Status="PASS"; Details="Page loads without loading screen"}
    } elseif ($response.Content -like "*AGUARDE*") {
        Write-Host "   ⚠ Page shows loading screen (AGUARDE)" -ForegroundColor Yellow
        $testResults += @{Test="Laudo Index"; Status="WARN"; Details="Stuck on loading screen"}
    } else {
        Write-Host "   ✗ Unexpected response" -ForegroundColor Red
        $testResults += @{Test="Laudo Index"; Status="FAIL"; Details="HTTP $($response.StatusCode)"}
    }
} catch {
    Write-Host "   ✗ Request failed: $($_.Exception.Message)" -ForegroundColor Red
    $testResults += @{Test="Laudo Index"; Status="FAIL"; Details=$_.Exception.Message}
}

# Test 3: API endpoints
Write-Host "`n[3/8] Testing API endpoints..." -ForegroundColor Yellow
$apiEndpoints = @(
    @{Name="Usuario"; Url="$BaseUrl/api/Usuario"; ExpectedStatus=405},
    @{Name="Laudo"; Url="$BaseUrl/api/Laudo"; ExpectedStatus=405},
    @{Name="Obra"; Url="$BaseUrl/api/Obra"; ExpectedStatus=405}
)

foreach ($endpoint in $apiEndpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.Url -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq $endpoint.ExpectedStatus) {
            Write-Host "   ✓ $($endpoint.Name) API endpoint exists" -ForegroundColor Green
            $testResults += @{Test="API $($endpoint.Name)"; Status="PASS"; Details="HTTP $($response.StatusCode)"}
        } else {
            Write-Host "   ⚠ $($endpoint.Name) unexpected status: $($response.StatusCode)" -ForegroundColor Yellow
            $testResults += @{Test="API $($endpoint.Name)"; Status="WARN"; Details="HTTP $($response.StatusCode)"}
        }
    } catch {
        if ($_.Exception.Response.StatusCode -eq $endpoint.ExpectedStatus) {
            Write-Host "   ✓ $($endpoint.Name) API endpoint exists" -ForegroundColor Green
            $testResults += @{Test="API $($endpoint.Name)"; Status="PASS"; Details="HTTP $($endpoint.ExpectedStatus)"}
        } else {
            Write-Host "   ✗ $($endpoint.Name) API failed: $($_.Exception.Message)" -ForegroundColor Red
            $testResults += @{Test="API $($endpoint.Name)"; Status="FAIL"; Details=$_.Exception.Message}
        }
    }
}

# Test 4: Static resources
Write-Host "`n[4/8] Testing static resources..." -ForegroundColor Yellow
$staticResources = @(
    "$BaseUrl/Client/nav.html",
    "$BaseUrl/Client/Views/Laudos/index.html",
    "$BaseUrl/Assets/images/logo.jpg"
)

foreach ($resource in $staticResources) {
    try {
        $response = Invoke-WebRequest -Uri $resource -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✓ $(Split-Path $resource -Leaf) loads correctly" -ForegroundColor Green
            $testResults += @{Test="Static $(Split-Path $resource -Leaf)"; Status="PASS"; Details="HTTP 200"}
        } else {
            Write-Host "   ✗ $(Split-Path $resource -Leaf) failed: HTTP $($response.StatusCode)" -ForegroundColor Red
            $testResults += @{Test="Static $(Split-Path $resource -Leaf)"; Status="FAIL"; Details="HTTP $($response.StatusCode)"}
        }
    } catch {
        Write-Host "   ✗ $(Split-Path $resource -Leaf) failed: $($_.Exception.Message)" -ForegroundColor Red
        $testResults += @{Test="Static $(Split-Path $resource -Leaf)"; Status="FAIL"; Details=$_.Exception.Message}
    }
}

# Test 5: Database connectivity (indirect test via API)
Write-Host "`n[5/8] Testing database connectivity..." -ForegroundColor Yellow
# This would require a specific endpoint that tests DB connection
Write-Host "   ⚠ Database test requires manual verification" -ForegroundColor Yellow
Write-Host "     Check: Can you access /laudos/cadastro without entity errors?" -ForegroundColor Gray
$testResults += @{Test="Database"; Status="MANUAL"; Details="Requires manual verification"}

# Test 6: Report generation capability
Write-Host "`n[6/8] Testing report generation capability..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$BaseUrl/ReportViewerWebForm.aspx" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "   ✓ ReportViewer is accessible" -ForegroundColor Green
        $testResults += @{Test="ReportViewer"; Status="PASS"; Details="HTTP 200"}
    } else {
        Write-Host "   ⚠ ReportViewer status: $($response.StatusCode)" -ForegroundColor Yellow
        $testResults += @{Test="ReportViewer"; Status="WARN"; Details="HTTP $($response.StatusCode)"}
    }
} catch {
    if ($_.Exception.Response.StatusCode -eq 500) {
        Write-Host "   ⚠ ReportViewer returns 500 (expected without parameters)" -ForegroundColor Yellow
        $testResults += @{Test="ReportViewer"; Status="WARN"; Details="HTTP 500 - needs parameters"}
    } else {
        Write-Host "   ✗ ReportViewer failed: $($_.Exception.Message)" -ForegroundColor Red
        $testResults += @{Test="ReportViewer"; Status="FAIL"; Details=$_.Exception.Message}
    }
}

# Test 7: Configuration verification
Write-Host "`n[7/8] Verifying configuration..." -ForegroundColor Yellow
$webConfigPath = "rdoappProject\Web.config"
if (Test-Path $webConfigPath) {
    $webConfig = Get-Content $webConfigPath -Raw
    if ($webConfig -like "*piscinas_rdoapp_homolog*") {
        Write-Host "   ✓ Connection string points to homolog database" -ForegroundColor Green
        $testResults += @{Test="Config DB"; Status="PASS"; Details="Homolog database configured"}
    } else {
        Write-Host "   ✗ Connection string still points to production!" -ForegroundColor Red
        $testResults += @{Test="Config DB"; Status="FAIL"; Details="Production database in config"}
    }
    
    if ($webConfig -like "*Homologation*") {
        Write-Host "   ✓ Environment set to Homologation" -ForegroundColor Green
        $testResults += @{Test="Config Env"; Status="PASS"; Details="Environment = Homologation"}
    } else {
        Write-Host "   ⚠ Environment not explicitly set to Homologation" -ForegroundColor Yellow
        $testResults += @{Test="Config Env"; Status="WARN"; Details="Environment not set"}
    }
} else {
    Write-Host "   ✗ Web.config not found" -ForegroundColor Red
    $testResults += @{Test="Config"; Status="FAIL"; Details="Web.config not found"}
}

# Test 8: Build verification
Write-Host "`n[8/8] Verifying build output..." -ForegroundColor Yellow
$dllPath = "rdoappClass\bin\Debug\rdoappClass.dll"
if (Test-Path $dllPath) {
    $dllInfo = Get-Item $dllPath
    $age = (Get-Date) - $dllInfo.LastWriteTime
    if ($age.TotalMinutes -lt 60) {
        Write-Host "   ✓ DLL is recent (built $([math]::Round($age.TotalMinutes, 1)) minutes ago)" -ForegroundColor Green
        $testResults += @{Test="Build Output"; Status="PASS"; Details="Recent build"}
    } else {
        Write-Host "   ⚠ DLL is old (built $([math]::Round($age.TotalHours, 1)) hours ago)" -ForegroundColor Yellow
        $testResults += @{Test="Build Output"; Status="WARN"; Details="Old build"}
    }
} else {
    Write-Host "   ✗ rdoappClass.dll not found" -ForegroundColor Red
    $testResults += @{Test="Build Output"; Status="FAIL"; Details="DLL not found"}
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Results Summary                   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$passCount = ($testResults | Where-Object {$_.Status -eq "PASS"}).Count
$warnCount = ($testResults | Where-Object {$_.Status -eq "WARN"}).Count
$failCount = ($testResults | Where-Object {$_.Status -eq "FAIL"}).Count
$manualCount = ($testResults | Where-Object {$_.Status -eq "MANUAL"}).Count

Write-Host ""
Write-Host "✓ PASSED: $passCount" -ForegroundColor Green
Write-Host "⚠ WARNINGS: $warnCount" -ForegroundColor Yellow
Write-Host "✗ FAILED: $failCount" -ForegroundColor Red
Write-Host "📋 MANUAL: $manualCount" -ForegroundColor Cyan
Write-Host ""

# Detailed results
foreach ($result in $testResults) {
    $color = switch ($result.Status) {
        "PASS" { "Green" }
        "WARN" { "Yellow" }
        "FAIL" { "Red" }
        "MANUAL" { "Cyan" }
    }
    Write-Host "$($result.Test): $($result.Status) - $($result.Details)" -ForegroundColor $color
}

Write-Host ""
if ($failCount -eq 0) {
    Write-Host "🎉 Homologation environment is ready for testing!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Please fix the failed tests before proceeding." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Manual tests to perform:" -ForegroundColor Cyan
Write-Host "1. Navigate to $BaseUrl/laudos/cadastro" -ForegroundColor White
Write-Host "2. Try to create a new Laudo" -ForegroundColor White
Write-Host "3. Attempt to generate a PDF" -ForegroundColor White
Write-Host "4. Verify no 'entity not part of model' errors" -ForegroundColor White
Write-Host ""