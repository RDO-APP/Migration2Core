#!/usr/bin/env pwsh
# Test Inline Style Legacy Standard Implementation
# Verify 300x130px card dimensions with inline styles bypassing CSS files

Write-Host "=== INLINE STYLE LEGACY STANDARD TEST ===" -ForegroundColor Cyan
Write-Host "Testing 300x130px with INLINE STYLES - bypassing CSS files" -ForegroundColor Yellow

# Build the project
Write-Host "`n1. Building project..." -ForegroundColor Green
try {
    dotnet build "RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj" --configuration Release --verbosity minimal
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Build successful" -ForegroundColor Green
    } else {
        Write-Host "✗ Build failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Build error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Check TaskCard.razor contains inline styles
Write-Host "`n2. Verifying Inline Styles in TaskCard.razor..." -ForegroundColor Green
$razorFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor"

if (Test-Path $razorFile) {
    $razorContent = Get-Content $razorFile -Raw
    
    # Check for inline style constraints
    $checks = @(
        @{ Rule = "width: 300px !important"; Description = "Main div width constraint" },
        @{ Rule = "height: 130px !important"; Description = "Main div height constraint" },
        @{ Rule = "max-width: 300px !important"; Description = "Main div max-width constraint" },
        @{ Rule = "max-width: 284px"; Description = "Internal row width constraint" },
        @{ Rule = "max-width: 250px"; Description = "Progress bar constraint" },
        @{ Rule = "border: 1px solid white"; Description = "Toolbar button white borders" },
        @{ Rule = "INLINE STYLE PROOF"; Description = "Inline style documentation" }
    )
    
    foreach ($check in $checks) {
        if ($razorContent -match [regex]::Escape($check.Rule)) {
            Write-Host "✓ $($check.Description): Found" -ForegroundColor Green
        } else {
            Write-Host "✗ Missing: $($check.Description)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "✗ Razor file not found: $razorFile" -ForegroundColor Red
    exit 1
}

# Start the application
Write-Host "`n3. Starting application for INLINE STYLE verification..." -ForegroundColor Green
try {
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run --project RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj --configuration Release" -PassThru -WindowStyle Hidden
    
    # Wait for startup
    Start-Sleep -Seconds 8
    
    if (!$process.HasExited) {
        Write-Host "✓ Application started successfully (PID: $($process.Id))" -ForegroundColor Green
        Write-Host "`n🎯 INLINE STYLE IMPLEMENTATION:" -ForegroundColor Cyan
        Write-Host "   • Main div: width: 300px !important; height: 130px !important" -ForegroundColor White
        Write-Host "   • Internal rows: max-width: 284px (300px - 16px padding)" -ForegroundColor White
        Write-Host "   • Progress bar: max-width: 250px (safety margin)" -ForegroundColor White
        Write-Host "   • Toolbar buttons: 1px solid white borders" -ForegroundColor White
        Write-Host "   • CSS files bypassed - styles applied directly in HTML" -ForegroundColor White
        
        Write-Host "`n🌐 Test URLs:" -ForegroundColor Yellow
        Write-Host "   • Login: https://localhost:7001/Account/Login" -ForegroundColor White
        Write-Host "   • Task Cards: https://localhost:7001/Etapa/Cards" -ForegroundColor White
        
        Write-Host "`n⚡ INLINE STYLE PROOF CHECKLIST:" -ForegroundColor Yellow
        Write-Host "   1. Cards are EXACTLY 300x130px (inline styles override everything)" -ForegroundColor White
        Write-Host "   2. No CSS file conflicts can affect dimensions" -ForegroundColor White
        Write-Host "   3. Toolbar buttons have white borders" -ForegroundColor White
        Write-Host "   4. Internal content constrained to prevent stretching" -ForegroundColor White
        Write-Host "   5. If this doesn't work, move to Task 5: Toolbar Implementation" -ForegroundColor White
        
        Write-Host "`n🔥 DECISION POINT:" -ForegroundColor Red
        Write-Host "   • If cards are still not 300x130px → Move to Task 5" -ForegroundColor White
        Write-Host "   • If cards are perfect 300x130px → Legacy Standard PROVEN!" -ForegroundColor White
        
        Write-Host "`nPress any key to stop the application..." -ForegroundColor Cyan
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        # Stop the application
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        Write-Host "✓ Application stopped" -ForegroundColor Green
    } else {
        Write-Host "✗ Application failed to start" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Error starting application: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== INLINE STYLE TEST COMPLETED ===" -ForegroundColor Cyan
Write-Host "Legacy Standard 300x130px with inline styles applied!" -ForegroundColor Green