# Layout Constraint Test - 220px x 180px Dimensions
# Verifies if browser respects our Hard Lock constraints

Write-Host "🧪 LAYOUT CONSTRAINT TEST - 220px x 180px" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

Write-Host "`n📐 Testing if browser respects dimension constraints..." -ForegroundColor Yellow
Write-Host "Expected Results:" -ForegroundColor White
Write-Host "  • Cards should be NARROWER (220px vs 300px)" -ForegroundColor Green
Write-Host "  • Cards should be TALLER (180px vs 130px)" -ForegroundColor Green
Write-Host "  • More cards should fit per row (due to narrower width)" -ForegroundColor Green
Write-Host "  • Grid should use 220px columns with 15px gaps" -ForegroundColor Green

# Test 1: Check TaskCard CSS dimensions
Write-Host "`n1. CHECKING TASKCARD CSS DIMENSIONS..." -ForegroundColor Yellow
$taskCardCssPath = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor.css"

if (Test-Path $taskCardCssPath) {
    $taskCardContent = Get-Content $taskCardCssPath -Raw
    
    $checks = @(
        @{ Name = "Width 220px"; Pattern = "width: 220px !important"; Expected = "220px" },
        @{ Name = "Height 180px"; Pattern = "height: 180px !important"; Expected = "180px" },
        @{ Name = "Min-width 220px"; Pattern = "min-width: 220px !important"; Expected = "220px" },
        @{ Name = "Max-width 220px"; Pattern = "max-width: 220px !important"; Expected = "220px" },
        @{ Name = "Min-height 180px"; Pattern = "min-height: 180px !important"; Expected = "180px" },
        @{ Name = "Max-height 180px"; Pattern = "max-height: 180px !important"; Expected = "180px" }
    )
    
    foreach ($check in $checks) {
        if ($taskCardContent -match $check.Pattern) {
            Write-Host "  ✅ $($check.Name) = $($check.Expected)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($check.Name) not found" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ❌ TaskCard.razor.css not found" -ForegroundColor Red
}

# Test 2: Check Grid Container CSS
Write-Host "`n2. CHECKING GRID CONTAINER CSS..." -ForegroundColor Yellow
$cssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/task-cards-compact.css"

if (Test-Path $cssPath) {
    $cssContent = Get-Content $cssPath -Raw
    
    $checks = @(
        @{ Name = "Grid columns 220px"; Pattern = "repeat\(auto-fill, 220px\)"; Expected = "220px columns" },
        @{ Name = "Grid item width 220px"; Pattern = "width: 220px !important"; Expected = "220px" },
        @{ Name = "Grid item max-width 220px"; Pattern = "max-width: 220px !important"; Expected = "220px" },
        @{ Name = "Grid gap 15px"; Pattern = "gap: 15px !important"; Expected = "15px" }
    )
    
    foreach ($check in $checks) {
        if ($cssContent -match $check.Pattern) {
            Write-Host "  ✅ $($check.Name) = $($check.Expected)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($check.Name) not found" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ❌ task-cards-compact.css not found" -ForegroundColor Red
}

# Test 3: Compilation check
Write-Host "`n3. CHECKING COMPILATION..." -ForegroundColor Yellow
try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Project compiles successfully with test dimensions" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Compilation errors found:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "  ⚠️  Could not test compilation: $($_.Exception.Message)" -ForegroundColor Yellow
} finally {
    Pop-Location
}

Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "🎯 CONSTRAINT TEST SUMMARY:" -ForegroundColor Cyan
Write-Host "• CARD DIMENSIONS: Changed to 220px x 180px" -ForegroundColor White
Write-Host "• GRID COLUMNS: Changed to repeat(auto-fill, 220px)" -ForegroundColor White
Write-Host "• EXPECTED BEHAVIOR: Cards should be narrower and taller" -ForegroundColor White

Write-Host "`n🚀 BROWSER TEST INSTRUCTIONS:" -ForegroundColor Green
Write-Host "1. Run the application (dotnet run or F5)" -ForegroundColor White
Write-Host "2. Navigate to the task cards page" -ForegroundColor White
Write-Host "3. Observe if cards are:" -ForegroundColor White
Write-Host "   - NARROWER than before (220px vs 300px)" -ForegroundColor Yellow
Write-Host "   - TALLER than before (180px vs 130px)" -ForegroundColor Yellow
Write-Host "   - More cards fitting per row" -ForegroundColor Yellow
Write-Host "4. Use browser dev tools to inspect actual dimensions" -ForegroundColor White

Write-Host "`n⚠️  REMEMBER: Revert to 300x130px after testing!" -ForegroundColor Red