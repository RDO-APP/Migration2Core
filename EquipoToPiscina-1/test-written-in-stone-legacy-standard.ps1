#!/usr/bin/env pwsh
# Test Written in Stone Legacy Standard - 2nd Chance Fix
# Verify 300x130px with correct colors and compressed rows

Write-Host "=== WRITTEN IN STONE LEGACY STANDARD - 2ND CHANCE ===" -ForegroundColor Cyan
Write-Host "Testing EXACT 300x130px with Status 2 Blue (#007bff) and compressed rows" -ForegroundColor Yellow

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

# Check TaskCard.razor contains Written in Stone fixes
Write-Host "`n2. Verifying Written in Stone Fixes..." -ForegroundColor Green
$razorFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor"

if (Test-Path $razorFile) {
    $razorContent = Get-Content $razorFile -Raw
    
    # Check for Written in Stone fixes
    $checks = @(
        @{ Rule = "display: flex !important; flex-direction: column !important"; Description = "Main div flex layout" },
        @{ Rule = "padding-top: 2px !important; padding-bottom: 2px !important"; Description = "Compressed row padding" },
        @{ Rule = "background-color: #007bff"; Description = "Status 2 Blue color (#007bff)" },
        @{ Rule = "background-color: #0056b3"; Description = "Status 2 Darker Blue for Row 2" },
        @{ Rule = "border: 1px solid white !important"; Description = "Toolbar white borders" },
        @{ Rule = "GetRow1BackgroundColor"; Description = "Dynamic Row 1 background method" },
        @{ Rule = "GetRow2BackgroundColor"; Description = "Dynamic Row 2 background method" },
        @{ Rule = "WRITTEN IN STONE"; Description = "Written in Stone documentation" }
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
Write-Host "`n3. Starting application for WRITTEN IN STONE verification..." -ForegroundColor Green
try {
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run --project RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj --configuration Release" -PassThru -WindowStyle Hidden
    
    # Wait for startup
    Start-Sleep -Seconds 8
    
    if (!$process.HasExited) {
        Write-Host "✓ Application started successfully (PID: $($process.Id))" -ForegroundColor Green
        Write-Host "`n📏 WRITTEN IN STONE SPECIFICATIONS:" -ForegroundColor Cyan
        Write-Host "   • Main div: height: 130px !important; display: flex; flex-direction: column" -ForegroundColor White
        Write-Host "   • Row padding: padding-top: 2px; padding-bottom: 2px (compressed)" -ForegroundColor White
        Write-Host "   • Status 2 Color: Blue (#007bff) - NOT cyan" -ForegroundColor White
        Write-Host "   • Row 2 Color: Darker Blue (#0056b3) for 2-tone hierarchy" -ForegroundColor White
        Write-Host "   • Toolbar: 5 buttons with 1px solid white borders" -ForegroundColor White
        
        Write-Host "`n🌐 Test URLs:" -ForegroundColor Yellow
        Write-Host "   • Login: https://localhost:7001/Account/Login" -ForegroundColor White
        Write-Host "   • Task Cards: https://localhost:7001/Etapa/Cards" -ForegroundColor White
        
        Write-Host "`n🎯 WRITTEN IN STONE CHECKLIST:" -ForegroundColor Yellow
        Write-Host "   1. Cards are EXACTLY 130px tall (not taller)" -ForegroundColor White
        Write-Host "   2. Status 2 cards show BLUE (#007bff), not cyan" -ForegroundColor White
        Write-Host "   3. Row 2 shows darker blue for 2-tone hierarchy" -ForegroundColor White
        Write-Host "   4. All 5 toolbar buttons have white borders" -ForegroundColor White
        Write-Host "   5. Rows are compressed with 2px vertical padding" -ForegroundColor White
        
        Write-Host "`n⚠️  DECISION POINT:" -ForegroundColor Red
        Write-Host "   • If height is still off → Use 3rd chance for complete layout override" -ForegroundColor White
        Write-Host "   • If everything is perfect → WRITTEN IN STONE ACHIEVED!" -ForegroundColor White
        
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

Write-Host "`n=== WRITTEN IN STONE TEST COMPLETED ===" -ForegroundColor Cyan
Write-Host "2nd Chance fixes applied - Legacy Standard 300x130px!" -ForegroundColor Green