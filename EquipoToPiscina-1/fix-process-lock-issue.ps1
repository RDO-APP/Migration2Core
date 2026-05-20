#!/usr/bin/env pwsh

Write-Host "=== FIXING PROCESS LOCK ISSUE (PID 3188) ===" -ForegroundColor Green
Write-Host "Resolving MSB3027 error - file locked by RdoApp.Core process" -ForegroundColor Yellow

# Stop all RdoApp.Core processes
Write-Host "`n1. Stopping all RdoApp.Core processes..." -ForegroundColor Cyan
try {
    $processes = Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue
    if ($processes) {
        foreach ($process in $processes) {
            Write-Host "   Stopping process PID $($process.Id)..." -ForegroundColor Yellow
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
        Write-Host "✅ All RdoApp.Core processes stopped" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  No RdoApp.Core processes found" -ForegroundColor Blue
    }
} catch {
    Write-Host "⚠️  Error stopping processes: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Stop dotnet processes that might be holding the file
Write-Host "`n2. Stopping dotnet processes..." -ForegroundColor Cyan
try {
    $dotnetProcesses = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" -or $_.ProcessName -eq "dotnet" }
    if ($dotnetProcesses) {
        foreach ($process in $dotnetProcesses) {
            Write-Host "   Stopping dotnet process PID $($process.Id)..." -ForegroundColor Yellow
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
        Write-Host "✅ Dotnet processes stopped" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  No relevant dotnet processes found" -ForegroundColor Blue
    }
} catch {
    Write-Host "⚠️  Error stopping dotnet processes: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Wait a moment for processes to fully terminate
Write-Host "`n3. Waiting for processes to terminate..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

# Clean up bin and obj directories
Write-Host "`n4. Cleaning build directories..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

try {
    if (Test-Path "bin") {
        Remove-Item -Path "bin" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ Cleaned bin directory" -ForegroundColor Green
    }
    
    if (Test-Path "obj") {
        Remove-Item -Path "obj" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ Cleaned obj directory" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Error cleaning directories: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Restore and rebuild
Write-Host "`n5. Restoring packages..." -ForegroundColor Cyan
dotnet restore --verbosity quiet

Write-Host "`n6. Building project..." -ForegroundColor Cyan
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build successful - process lock issue resolved!" -ForegroundColor Green
} else {
    Write-Host "❌ Build failed - check for other issues" -ForegroundColor Red
}

Write-Host "`n=== PROCESS LOCK FIX COMPLETE ===" -ForegroundColor Green
Write-Host "You can now press F5 in Visual Studio to run the application." -ForegroundColor Yellow
Write-Host "The Entity Framework relationship fix is also applied." -ForegroundColor Cyan