# DIAGNOSE VIEW NOT RENDERING - Complete Diagnostic Suite
# This script runs all diagnostics to identify why the view is not rendering

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "VIEW NOT RENDERING DIAGNOSTIC SUITE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "SITUATION:" -ForegroundColor Yellow
Write-Host "- Page is blank" -ForegroundColor White
Write-Host "- F12 Console is EMPTY (no Life Signs)" -ForegroundColor White
Write-Host "- Controller logs show '103 obras retrieved'" -ForegroundColor White
Write-Host "- Controller returns View(obras)" -ForegroundColor White
Write-Host ""

Write-Host "DIAGNOSIS: View is NOT being rendered AT ALL" -ForegroundColor Red
Write-Host ""

# Test 1: Check if view file exists
Write-Host "TEST 1: View File Existence" -ForegroundColor Green
Write-Host "---------------------------------------"
$viewPath = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
if (Test-Path $viewPath) {
    Write-Host "✅ View file exists: $viewPath" -ForegroundColor Green
} else {
    Write-Host "❌ View file NOT FOUND: $viewPath" -ForegroundColor Red
    Write-Host "This is the problem! View file is missing." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Test 2: Check view file size
Write-Host "TEST 2: View File Size" -ForegroundColor Green
Write-Host "---------------------------------------"
$viewFile = Get-Item $viewPath
Write-Host "File size: $($viewFile.Length) bytes" -ForegroundColor White
if ($viewFile.Length -eq 0) {
    Write-Host "❌ View file is EMPTY!" -ForegroundColor Red
    Write-Host "This is the problem! View file has no content." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "✅ View file has content" -ForegroundColor Green
}
Write-Host ""

# Test 3: Check for Razor syntax errors
Write-Host "TEST 3: Razor Syntax Check" -ForegroundColor Green
Write-Host "---------------------------------------"
$viewContent = Get-Content $viewPath -Raw
if ($viewContent -match "@model") {
    Write-Host "✅ @model directive found" -ForegroundColor Green
} else {
    Write-Host "⚠️ No @model directive found" -ForegroundColor Yellow
}

if ($viewContent -match "<!DOCTYPE html>") {
    Write-Host "✅ HTML structure found" -ForegroundColor Green
} else {
    Write-Host "❌ No HTML structure found" -ForegroundColor Red
}

if ($viewContent -match "Layout\s*=\s*null") {
    Write-Host "✅ Layout = null (standalone HTML)" -ForegroundColor Green
} else {
    Write-Host "⚠️ Layout is not null (uses layout)" -ForegroundColor Yellow
}
Write-Host ""

# Test 4: Check CSS file existence
Write-Host "TEST 4: CSS File Existence" -ForegroundColor Green
Write-Host "---------------------------------------"
$cssFiles = @(
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/escolher-legacy.css",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css"
)

foreach ($css in $cssFiles) {
    if (Test-Path $css) {
        Write-Host "✅ CSS file exists: $css" -ForegroundColor Green
    } else {
        Write-Host "❌ CSS file NOT FOUND: $css" -ForegroundColor Red
    }
}
Write-Host ""

# Test 5: Check Program.cs middleware configuration
Write-Host "TEST 5: Middleware Configuration" -ForegroundColor Green
Write-Host "---------------------------------------"
$programCs = "RDO-NET8-Migration/RdoApp.Core/Program.cs"
if (Test-Path $programCs) {
    $programContent = Get-Content $programCs -Raw
    
    if ($programContent -match "app\.UseStaticFiles\(\)") {
        Write-Host "✅ UseStaticFiles() configured" -ForegroundColor Green
    } else {
        Write-Host "❌ UseStaticFiles() NOT configured" -ForegroundColor Red
    }
    
    if ($programContent -match "app\.UseRouting\(\)") {
        Write-Host "✅ UseRouting() configured" -ForegroundColor Green
    } else {
        Write-Host "❌ UseRouting() NOT configured" -ForegroundColor Red
    }
    
    if ($programContent -match "app\.UseAuthentication\(\)") {
        Write-Host "✅ UseAuthentication() configured" -ForegroundColor Green
    } else {
        Write-Host "❌ UseAuthentication() NOT configured" -ForegroundColor Red
    }
    
    # Check for custom middleware
    if ($programContent -match "RESTRICTED SCOPE: Custom middleware") {
        Write-Host "⚠️ Custom middleware found" -ForegroundColor Yellow
        Write-Host "   This might be blocking the response" -ForegroundColor White
        
        # Check if /obra/ is in the skip list
        if ($programContent -match 'path\?\.StartsWith\("/obra/"') {
            Write-Host "✅ Custom middleware skips /obra/ routes" -ForegroundColor Green
        } else {
            Write-Host "❌ Custom middleware does NOT skip /obra/ routes" -ForegroundColor Red
            Write-Host "   This is likely the problem!" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "❌ Program.cs NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# Test 6: Check controller action
Write-Host "TEST 6: Controller Action Check" -ForegroundColor Green
Write-Host "---------------------------------------"
$controllerPath = "RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs"
if (Test-Path $controllerPath) {
    $controllerContent = Get-Content $controllerPath -Raw
    
    if ($controllerContent -match "public async Task<IActionResult> Escolher") {
        Write-Host "✅ Escolher action found" -ForegroundColor Green
    } else {
        Write-Host "❌ Escolher action NOT FOUND" -ForegroundColor Red
    }
    
    if ($controllerContent -match "return View\(") {
        Write-Host "✅ Returns View()" -ForegroundColor Green
    } else {
        Write-Host "❌ Does NOT return View()" -ForegroundColor Red
    }
    
    if ($controllerContent -match "\[Authorize\]") {
        Write-Host "✅ [Authorize] attribute found" -ForegroundColor Green
        Write-Host "   User must be authenticated to access" -ForegroundColor White
    } else {
        Write-Host "⚠️ No [Authorize] attribute" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ ObraController.cs NOT FOUND" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Based on the diagnostics above, the most likely causes are:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Custom middleware is blocking the response" -ForegroundColor White
Write-Host "   → Run: .\test-nuclear-bypass.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. View engine is failing silently" -ForegroundColor White
Write-Host "   → Run: .\test-nuclear-content.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Authentication is redirecting" -ForegroundColor White
Write-Host "   → Check if user is authenticated" -ForegroundColor Cyan
Write-Host "   → Check browser Network tab for redirects" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RECOMMENDED NEXT STEP" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run the Nuclear Bypass Test to see if middleware is the problem:" -ForegroundColor Yellow
Write-Host ""
Write-Host ".\test-nuclear-bypass.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will temporarily disable custom middleware and test if the page renders." -ForegroundColor White
Write-Host ""
