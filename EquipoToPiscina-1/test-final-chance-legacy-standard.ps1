#!/usr/bin/env pwsh
# Test Final Chance Legacy Standard - 3rd and LAST attempt
# Verify 300x130px solid block aligned to left with visible background

Write-Host "=== FINAL CHANCE LEGACY STANDARD - 3RD ATTEMPT ===" -ForegroundColor Red
Write-Host "LAST CHANCE: 300x130px solid block, left-aligned, visible background" -ForegroundColor Yellow

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

# Check all final chance fixes
Write-Host "`n2. Verifying Final Chance Fixes..." -ForegroundColor Green

# Check parent container
$parentFile = "RDO-NET8-Migration/RdoApp.Core/Views/Etapa/_EtapaAccordionPartial.cshtml"
if (Test-Path $parentFile) {
    $parentContent = Get-Content $parentFile -Raw
    if ($parentContent -match "justify-content: start !important") {
        Write-Host "✓ Parent: justify-content: start !important" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing: justify-content: start !important" -ForegroundColor Red
    }
    if ($parentContent -match "padding-left: 20px !important") {
        Write-Host "✓ Parent: padding-left: 20px !important" -ForegroundColor Green
    } else {
        Write-Host "✗ Missing: padding-left: 20px !important" -ForegroundColor Red
    }
}

# Check TaskCard
$razorFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor"
if (Test-Path $razorFile) {
    $razorContent = Get-Content $razorFile -Raw
    
    $checks = @(
        @{ Rule = "flex: none !important"; Description = "No flex-grow" },
        @{ Rule = "display: block !important"; Description = "Block display" },
        @{ Rule = "background-color: #f8f9fa !important"; Description = "Temporary background" },
        @{ Rule = "margin-top: auto !important"; Description = "Progress bar pushed to bottom" },
        @{ Rule = "3RD AND FINAL CHANCE"; Description = "Final chance documentation" }
    )
    
    foreach ($check in $checks) {
        if ($razorContent -match [regex]::Escape($check.Rule)) {
            Write-Host "✓ TaskCard: $($check.Description)" -ForegroundColor Green
        } else {
            Write-Host "✗ Missing: $($check.Description)" -ForegroundColor Red
        }
    }
}

# Start the application
Write-Host "`n3. Starting application for FINAL CHANCE verification..." -ForegroundColor Green
try {
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run --project RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj --configuration Release" -PassThru -WindowStyle Hidden
    
    # Wait for startup
    Start-Sleep -Seconds 8
    
    if (!$process.HasExited) {
        Write-Host "✓ Application started successfully (PID: $($process.Id))" -ForegroundColor Green
        Write-Host "`n🎯 FINAL CHANCE SPECIFICATIONS:" -ForegroundColor Red
        Write-Host "   • Cards aligned to LEFT (20px from margin)" -ForegroundColor White
        Write-Host "   • Solid 300x130px block (flex: none, display: block)" -ForegroundColor White
        Write-Host "   • Temporary gray background (#f8f9fa) to see exact 130px limit" -ForegroundColor White
        Write-Host "   • Progress bar pushed to bottom (margin-top: auto)" -ForegroundColor White
        Write-Host "   • No flex-grow, no centering, no floating" -ForegroundColor White
        
        Write-Host "`n🌐 Test URLs:" -ForegroundColor Yellow
        Write-Host "   • Login: https://localhost:7001/Account/Login" -ForegroundColor White
        Write-Host "   • Task Cards: https://localhost:7001/Etapa/Cards" -ForegroundColor White
        
        Write-Host "`n🔥 FINAL DECISION CRITERIA:" -ForegroundColor Red
        Write-Host "   1. Cards are compact 300x130px solid blocks" -ForegroundColor White
        Write-Host "   2. Cards are aligned close to LEFT margin (not centered)" -ForegroundColor White
        Write-Host "   3. Gray background shows EXACT 130px height limit" -ForegroundColor White
        Write-Host "   4. Progress bar is at the BOTTOM of the 130px box" -ForegroundColor White
        Write-Host "   5. No floating, no extra space, solid geometry" -ForegroundColor White
        
        Write-Host "`n⚠️  FINAL ULTIMATUM:" -ForegroundColor Red
        Write-Host "   • SUCCESS → Remove gray background, Legacy Standard COMPLETE" -ForegroundColor Green
        Write-Host "   • FAILURE → DONE with layout, move to Button Logic immediately" -ForegroundColor Red
        
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

Write-Host "`n=== FINAL CHANCE TEST COMPLETED ===" -ForegroundColor Red
Write-Host "This was the 3rd and FINAL attempt at 300x130px Legacy Standard!" -ForegroundColor Yellow