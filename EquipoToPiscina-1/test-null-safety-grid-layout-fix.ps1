# Test Null Safety and Grid Layout Fix Implementation
# Tests both the null reference fix and CSS Grid layout implementation

Write-Host "🔧 TESTING NULL SAFETY AND GRID LAYOUT FIX" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Test 1: Check EtapaViewModel null safety enhancements
Write-Host "`n1. CHECKING ETAPAVIEWMODEL NULL SAFETY..." -ForegroundColor Yellow
$etapaViewModelPath = "RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/EtapaViewModel.cs"

if (Test-Path $etapaViewModelPath) {
    $etapaContent = Get-Content $etapaViewModelPath -Raw
    
    $checks = @(
        @{ Name = "ValidTarefas property"; Pattern = "ValidTarefas =>" },
        @{ Name = "HasValidTarefas property"; Pattern = "HasValidTarefas =>" },
        @{ Name = "SafeIterationDebug property"; Pattern = "SafeIterationDebug =>" },
        @{ Name = "Null filtering logic"; Pattern = "Where\(t => t != null" }
    )
    
    foreach ($check in $checks) {
        if ($etapaContent -match $check.Pattern) {
            Write-Host "  ✅ $($check.Name) found" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($check.Name) missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ❌ EtapaViewModel.cs not found" -ForegroundColor Red
}

# Test 2: Check TarefaViewModel safety enhancements
Write-Host "`n2. CHECKING TAREFAVIEWMODEL SAFETY..." -ForegroundColor Yellow
$tarefaViewModelPath = "RDO-NET8-Migration/RdoApp.Core/Models/ViewModels/TarefaViewModel.cs"

if (Test-Path $tarefaViewModelPath) {
    $tarefaContent = Get-Content $tarefaViewModelPath -Raw
    
    $checks = @(
        @{ Name = "IsValid property"; Pattern = "IsValid =>" },
        @{ Name = "HasNullProperties property"; Pattern = "HasNullProperties =>" },
        @{ Name = "SafeDescricao property"; Pattern = "SafeDescricao =>" },
        @{ Name = "SafeStatusDescricao property"; Pattern = "SafeStatusDescricao =>" },
        @{ Name = "SafeStatusId property"; Pattern = "SafeStatusId =>" }
    )
    
    foreach ($check in $checks) {
        if ($tarefaContent -match $check.Pattern) {
            Write-Host "  ✅ $($check.Name) found" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($check.Name) missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ❌ TarefaViewModel.cs not found" -ForegroundColor Red
}

# Test 3: Check Accordion Partial null-safe iteration
Write-Host "`n3. CHECKING ACCORDION PARTIAL NULL SAFETY..." -ForegroundColor Yellow
$accordionPath = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_EtapaAccordionPartial.cshtml"

if (Test-Path $accordionPath) {
    $accordionContent = Get-Content $accordionPath -Raw
    
    $checks = @(
        @{ Name = "ValidTarefas usage"; Pattern = "Model\.ValidTarefas" },
        @{ Name = "HasValidTarefas check"; Pattern = "Model\.HasValidTarefas" },
        @{ Name = "Grid container class"; Pattern = "task-cards-grid-container" },
        @{ Name = "Null check in loop"; Pattern = "tarefa != null" },
        @{ Name = "Debug info display"; Pattern = "SafeIterationDebug" }
    )
    
    foreach ($check in $checks) {
        if ($accordionContent -match $check.Pattern) {
            Write-Host "  ✅ $($check.Name) found" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($check.Name) missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ❌ _EtapaAccordionPartial.cshtml not found" -ForegroundColor Red
}

# Test 4: Check CSS Grid implementation
Write-Host "`n4. CHECKING CSS GRID LAYOUT..." -ForegroundColor Yellow
$cssPath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/task-cards-compact.css"

if (Test-Path $cssPath) {
    $cssContent = Get-Content $cssPath -Raw
    
    $checks = @(
        @{ Name = "Grid container class"; Pattern = "\.task-cards-grid-container" },
        @{ Name = "Display grid"; Pattern = "display: grid" },
        @{ Name = "Grid template columns"; Pattern = "grid-template-columns.*300px" },
        @{ Name = "Gap 15px"; Pattern = "gap: 15px" },
        @{ Name = "Justify content center"; Pattern = "justify-content: center" },
        @{ Name = "Grid item constraints"; Pattern = "task-cards-grid-container.*>" }
    )
    
    foreach ($check in $checks) {
        if ($cssContent -match $check.Pattern) {
            Write-Host "  ✅ $($check.Name) found" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($check.Name) missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ❌ task-cards-compact.css not found" -ForegroundColor Red
}

# Test 5: Check TaskCard Hard Lock reinforcement
Write-Host "`n5. CHECKING TASKCARD HARD LOCK..." -ForegroundColor Yellow
$taskCardCssPath = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor.css"

if (Test-Path $taskCardCssPath) {
    $taskCardContent = Get-Content $taskCardCssPath -Raw
    
    $checks = @(
        @{ Name = "Width 300px constraint"; Pattern = "width: 300px !important" },
        @{ Name = "Min-width 300px constraint"; Pattern = "min-width: 300px !important" },
        @{ Name = "Max-width 300px constraint"; Pattern = "max-width: 300px !important" },
        @{ Name = "Height 130px constraint"; Pattern = "height: 130px !important" },
        @{ Name = "Flex shrink prevention"; Pattern = "flex-shrink: 0 !important" },
        @{ Name = "Flex grow prevention"; Pattern = "flex-grow: 0 !important" }
    )
    
    foreach ($check in $checks) {
        if ($taskCardContent -match $check.Pattern) {
            Write-Host "  ✅ $($check.Name) found" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($check.Name) missing" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  ❌ TaskCard.razor.css not found" -ForegroundColor Red
}

# Test 6: Compilation check
Write-Host "`n6. CHECKING COMPILATION..." -ForegroundColor Yellow
try {
    Push-Location "RDO-NET8-Migration/RdoApp.Core"
    $buildResult = dotnet build --no-restore --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Project compiles successfully" -ForegroundColor Green
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
Write-Host "🎯 IMPLEMENTATION SUMMARY:" -ForegroundColor Cyan
Write-Host "• NULL SAFETY FIX: Enhanced ViewModels with ValidTarefas filtering" -ForegroundColor White
Write-Host "• GRID LAYOUT FIX: Replaced flexbox with CSS Grid (300px + 15px gap)" -ForegroundColor White
Write-Host "• HARD LOCK REINFORCED: Strengthened 300x130px constraints" -ForegroundColor White
Write-Host "• LEGACY STANDARD: Maintained exact dimensions and behavior" -ForegroundColor White

Write-Host "`n🚀 Ready for testing! The task cards should now:" -ForegroundColor Green
Write-Host "  - Handle null tasks without crashing" -ForegroundColor White
Write-Host "  - Maintain exactly 300px width in grid layout" -ForegroundColor White
Write-Host "  - Display with 15px gaps and centered alignment" -ForegroundColor White
Write-Host "  - Show debug info for troubleshooting" -ForegroundColor White