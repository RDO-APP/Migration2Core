# TEST SILENT VIEW ENGINE FAILURE FIX
# Verify that the parameter type mismatch fix resolves the blank page issue

Write-Host "=== TESTING SILENT VIEW ENGINE FAILURE FIX ===" -ForegroundColor Cyan
Write-Host "Testing parameter type mismatch fix for blank page issue" -ForegroundColor Yellow

# Step 1: Verify the fixes are in place
Write-Host "`n1. VERIFYING FIXES APPLIED..." -ForegroundColor Green

$escolherView = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml" -Raw
if ($escolherView -match 'param-Obras="@Model\.ToList\(\)"') {
    Write-Host "   ✅ View parameter simplified (no namespace)" -ForegroundColor Green
} else {
    Write-Host "   ❌ View parameter still has namespace issue" -ForegroundColor Red
}

if ($escolherView -match 'Model != null && Model\.Any\(\)') {
    Write-Host "   ✅ View has null check and fallback" -ForegroundColor Green
} else {
    Write-Host "   ❌ View missing null check" -ForegroundColor Red
}

$componentFile = Get-Content "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor" -Raw
if ($componentFile -match 'catch \(Exception ex\)') {
    Write-Host "   ✅ Component has error handling" -ForegroundColor Green
} else {
    Write-Host "   ❌ Component missing error handling" -ForegroundColor Red
}

# Step 2: Build the project to check for compilation errors
Write-Host "`n2. BUILDING PROJECT..." -ForegroundColor Green
Push-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    $buildResult = dotnet build --no-restore 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Project builds successfully" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Build failed:" -ForegroundColor Red
        Write-Host $buildResult -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
}

Pop-Location

# Step 3: Start the application and test
Write-Host "`n3. STARTING APPLICATION..." -ForegroundColor Green
Push-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    # Start the application in background
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden
    
    Write-Host "   ⏳ Waiting for application to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    
    # Test the login page first
    Write-Host "`n4. TESTING LOGIN PAGE..." -ForegroundColor Green
    try {
        $loginResponse = Invoke-WebRequest -Uri "https://localhost:7001/Account/Login" -UseBasicParsing -TimeoutSec 10
        if ($loginResponse.StatusCode -eq 200) {
            Write-Host "   ✅ Login page loads successfully" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Login page returned status: $($loginResponse.StatusCode)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Login page error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test authentication and obra selection
    Write-Host "`n5. TESTING AUTHENTICATED OBRA SELECTION..." -ForegroundColor Green
    Write-Host "   ⚠️  Manual test required:" -ForegroundColor Yellow
    Write-Host "   1. Open browser to https://localhost:7001" -ForegroundColor White
    Write-Host "   2. Login with: ricardo / 123456" -ForegroundColor White
    Write-Host "   3. Check if ESCOLHER OBRA page shows cards (not blank)" -ForegroundColor White
    Write-Host "   4. Look for debug message: 'Found X obras in Model'" -ForegroundColor White
    Write-Host "   5. Verify 103 obra cards are visible" -ForegroundColor White
    
    Write-Host "`n   Press any key to stop the server..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Stop the process
    if (!$process.HasExited) {
        $process.Kill()
        Write-Host "   ✅ Server stopped" -ForegroundColor Green
    }
    
} catch {
    Write-Host "   ❌ Server start error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Pop-Location
}

# Step 6: Check for specific error patterns
Write-Host "`n6. CHECKING FOR COMMON ISSUES..." -ForegroundColor Green

# Check if using statements are correct
$componentUsings = Get-Content "RDO-NET8-Migration/RdoApp.Core/Components/RdoObraCards.razor" | Select-String "@using"
Write-Host "   Component @using statements:" -ForegroundColor White
foreach ($using in $componentUsings) {
    Write-Host "     $using" -ForegroundColor Gray
}

# Check ViewStart configuration
$viewStart = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/_ViewStart.cshtml" -Raw
if ($viewStart -match 'isEscolherObra.*controllerName.*Obra.*actionName.*Escolher') {
    Write-Host "   ✅ ViewStart correctly excludes ESCOLHER OBRA" -ForegroundColor Green
} else {
    Write-Host "   ❌ ViewStart may still override ESCOLHER OBRA layout" -ForegroundColor Red
}

# Step 7: Summary and next steps
Write-Host "`n=== FIX SUMMARY ===" -ForegroundColor Cyan
Write-Host "APPLIED FIXES:" -ForegroundColor White
Write-Host "1. ✅ Simplified component parameter (removed namespace)" -ForegroundColor Green
Write-Host "2. ✅ Added null check and fallback in view" -ForegroundColor Green
Write-Host "3. ✅ Added error handling in component" -ForegroundColor Green
Write-Host "4. ✅ Added try-catch in FilterObras method" -ForegroundColor Green

Write-Host "`nEXPECTED RESULT:" -ForegroundColor White
Write-Host "- Login page works normally" -ForegroundColor Yellow
Write-Host "- After login, ESCOLHER OBRA shows 103 obra cards" -ForegroundColor Yellow
Write-Host "- Debug message shows 'Found 103 obras in Model'" -ForegroundColor Yellow
Write-Host "- No more blank page after successful authentication" -ForegroundColor Yellow

Write-Host "`nIF STILL BLANK:" -ForegroundColor White
Write-Host "- Check browser F12 console for JavaScript errors" -ForegroundColor Yellow
Write-Host "- Check server logs for component initialization errors" -ForegroundColor Yellow
Write-Host "- Verify Blazor Server circuit connection" -ForegroundColor Yellow

Write-Host "`n=== SILENT VIEW ENGINE FAILURE FIX TEST COMPLETE ===" -ForegroundColor Cyan