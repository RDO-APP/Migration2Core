# BLANK PAGE DIAGNOSIS - Complete Analysis
# Verifies the root cause: Missing Blazor component tag helper registration

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BLANK PAGE DIAGNOSIS - ROOT CAUSE CHECK" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$viewImportsPath = "RDO-NET8-Migration/RdoApp.Core/Views/_ViewImports.cshtml"

Write-Host "Checking: $viewImportsPath" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $viewImportsPath) {
    $content = Get-Content $viewImportsPath -Raw
    
    Write-Host "FILE CONTENTS:" -ForegroundColor White
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host $content -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host ""
    
    # Check for required tag helper registrations
    Write-Host "TAG HELPER REGISTRATION CHECK:" -ForegroundColor Yellow
    Write-Host ""
    
    $checks = @(
        @{
            Name = "MVC Tag Helpers"
            Pattern = "@addTagHelper \*, Microsoft\.AspNetCore\.Mvc\.TagHelpers"
            Required = $true
        },
        @{
            Name = "Razor Tag Helpers"
            Pattern = "@addTagHelper \*, Microsoft\.AspNetCore\.Mvc\.Razor\.TagHelpers"
            Required = $true
        },
        @{
            Name = "Blazor Component Tag Helpers"
            Pattern = "@addTagHelper \*, RdoApp\.Core"
            Required = $true
        }
    )
    
    $allPassed = $true
    
    foreach ($check in $checks) {
        $found = $content -match $check.Pattern
        
        if ($found) {
            Write-Host "  ✅ $($check.Name): FOUND" -ForegroundColor Green
        } else {
            if ($check.Required) {
                Write-Host "  ❌ $($check.Name): MISSING (REQUIRED)" -ForegroundColor Red
                $allPassed = $false
            } else {
                Write-Host "  ⚠️  $($check.Name): MISSING (OPTIONAL)" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    
    if ($allPassed) {
        Write-Host "RESULT: All required tag helpers registered ✅" -ForegroundColor Green
        Write-Host "The blank page issue is NOT caused by missing tag helper registration." -ForegroundColor Green
    } else {
        Write-Host "RESULT: Missing required tag helper registration ❌" -ForegroundColor Red
        Write-Host ""
        Write-Host "ROOT CAUSE IDENTIFIED:" -ForegroundColor Yellow
        Write-Host "  The blank page at /Obra/Escolher is caused by missing:" -ForegroundColor White
        Write-Host "  @addTagHelper *, RdoApp.Core" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "This line is REQUIRED for Blazor component tag helpers to work." -ForegroundColor White
        Write-Host "Without it, <component> tags are treated as unknown HTML elements." -ForegroundColor White
        Write-Host ""
        Write-Host "FIX: Add this line to _ViewImports.cshtml:" -ForegroundColor Yellow
        Write-Host "  @addTagHelper *, RdoApp.Core" -ForegroundColor Green
    }
    
    Write-Host "========================================" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ ERROR: File not found: $viewImportsPath" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
