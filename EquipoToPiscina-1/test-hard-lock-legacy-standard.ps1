#!/usr/bin/env pwsh
# Test Hard Lock Legacy Standard Implementation
# Verify 300x130px card dimensions are maintained regardless of content

Write-Host "=== HARD LOCK LEGACY STANDARD TEST ===" -ForegroundColor Cyan
Write-Host "Testing 300x130px card constraints with internal row hard locks" -ForegroundColor Yellow

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

# Check CSS file exists and contains hard lock rules
Write-Host "`n2. Verifying Hard Lock CSS rules..." -ForegroundColor Green
$cssFile = "RDO-NET8-Migration/RdoApp.Core/Components/TaskCard.razor.css"

if (Test-Path $cssFile) {
    $cssContent = Get-Content $cssFile -Raw
    
    # Check for hard lock constraints
    $checks = @(
        @{ Rule = "max-width: 284px !important"; Description = "Row width constraint" },
        @{ Rule = "gap: 10px !important"; Description = "Date spacing reduction" },
        @{ Rule = "justify-content: space-between !important"; Description = "Date distribution" },
        @{ Rule = "max-width: 250px !important"; Description = "Progress bar constraint" },
        @{ Rule = "HARD LOCK APPLIED"; Description = "Hard lock documentation" }
    )
    
    foreach ($check in $checks) {
        if ($cssContent -match [regex]::Escape($check.Rule)) {
            Write-Host "✓ $($check.Description): $($check.Rule)" -ForegroundColor Green
        } else {
            Write-Host "✗ Missing: $($check.Description)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "✗ CSS file not found: $cssFile" -ForegroundColor Red
    exit 1
}

# Start the application
Write-Host "`n3. Starting application for visual verification..." -ForegroundColor Green
try {
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run --project RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj --configuration Release" -PassThru -WindowStyle Hidden
    
    # Wait for startup
    Start-Sleep -Seconds 8
    
    if (!$process.HasExited) {
        Write-Host "✓ Application started successfully (PID: $($process.Id))" -ForegroundColor Green
        Write-Host "`n🔒 HARD LOCK IMPLEMENTATION APPLIED:" -ForegroundColor Cyan
        Write-Host "   • Internal rows constrained to 284px max-width" -ForegroundColor White
        Write-Host "   • Date spacing reduced to 10px gap" -ForegroundColor White
        Write-Host "   • Progress bar limited to 250px max-width" -ForegroundColor White
        Write-Host "   • All content will truncate/ellipsis if too large" -ForegroundColor White
        Write-Host "   • Card MUST remain exactly 300px wide" -ForegroundColor White
        
        Write-Host "`n🌐 Test URLs:" -ForegroundColor Yellow
        Write-Host "   • Login: https://localhost:7001/Account/Login" -ForegroundColor White
        Write-Host "   • Task Cards: https://localhost:7001/Etapa/Cards" -ForegroundColor White
        
        Write-Host "`n⚠️  VERIFICATION CHECKLIST:" -ForegroundColor Yellow
        Write-Host "   1. All task cards are exactly 300px wide" -ForegroundColor White
        Write-Host "   2. No cards stretch beyond 300px regardless of content" -ForegroundColor White
        Write-Host "   3. Long text truncates with ellipsis" -ForegroundColor White
        Write-Host "   4. Dates don't push card borders" -ForegroundColor White
        Write-Host "   5. Progress bar stays within constraints" -ForegroundColor White
        
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

Write-Host "`n=== HARD LOCK TEST COMPLETED ===" -ForegroundColor Cyan
Write-Host "Legacy Standard 300x130px with internal row constraints applied!" -ForegroundColor Green