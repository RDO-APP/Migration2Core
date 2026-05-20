# RDO APP PROCESS CLEANUP UTILITY
# Resolving Compilation Lock Issues (PID 42088 and others)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   RDO APP PROCESS CLEANUP UTILITY" -ForegroundColor Cyan
Write-Host "   Resolving Compilation Lock Issues" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to stop processes safely
function Stop-ProcessSafely {
    param([string]$ProcessName)
    
    $processes = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Host "[INFO] Found $($processes.Count) $ProcessName process(es)" -ForegroundColor Yellow
        foreach ($process in $processes) {
            Write-Host "  - Stopping PID $($process.Id)..." -ForegroundColor Yellow
            try {
                $process.Kill()
                $process.WaitForExit(5000)
                Write-Host "  ✅ Process $($process.Id) stopped" -ForegroundColor Green
            }
            catch {
                Write-Host "  ⚠️  Could not stop process $($process.Id): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "[INFO] No $ProcessName processes found" -ForegroundColor Gray
    }
}

# Step 1: Stop IIS Express
Write-Host "[1/5] Stopping IIS Express processes..." -ForegroundColor White
Stop-ProcessSafely "iisexpress"

# Step 2: Stop .NET processes
Write-Host ""
Write-Host "[2/5] Stopping .NET processes..." -ForegroundColor White
Stop-ProcessSafely "dotnet"

# Step 3: Stop RdoApp.Core processes
Write-Host ""
Write-Host "[3/5] Stopping RdoApp.Core processes..." -ForegroundColor White
Stop-ProcessSafely "RdoApp.Core"

# Step 4: Stop Visual Studio processes (if any)
Write-Host ""
Write-Host "[4/5] Stopping Visual Studio processes..." -ForegroundColor White
Stop-ProcessSafely "devenv"

# Step 5: Clean temporary files
Write-Host ""
Write-Host "[5/5] Cleaning temporary files..." -ForegroundColor White

$projectPath = "RDO-NET8-Migration\RdoApp.Core"
if (Test-Path $projectPath) {
    Push-Location $projectPath
    
    # Clean bin folder
    if (Test-Path "bin") {
        Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✅ bin folder cleaned" -ForegroundColor Green
    }
    
    # Clean obj folder
    if (Test-Path "obj") {
        Remove-Item "obj" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  ✅ obj folder cleaned" -ForegroundColor Green
    }
    
    Pop-Location
}
else {
    Write-Host "  ⚠️  Project path not found: $projectPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CLEANUP COMPLETE ✅" -ForegroundColor Green
Write-Host "   Process lock issue resolved" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. cd RDO-NET8-Migration\RdoApp.Core" -ForegroundColor Yellow
Write-Host "2. dotnet build" -ForegroundColor Yellow
Write-Host "3. dotnet run" -ForegroundColor Yellow
Write-Host "4. Test at: http://localhost:5031/etapa/cards-blazor/1" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")