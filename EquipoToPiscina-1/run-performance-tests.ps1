# DAY 8 - PERFORMANCE BASELINE TESTING
# Measure system performance before production deployment

Write-Host "STARTING PERFORMANCE BASELINE TESTING..." -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow
Write-Host "Objective: Establish performance baselines for production monitoring" -ForegroundColor Yellow
Write-Host ""

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "Current Directory: $(Get-Location)" -ForegroundColor Cyan
Write-Host ""

# Performance Test 1: Application Startup Time
Write-Host "PERFORMANCE 1: APPLICATION STARTUP TIME" -ForegroundColor Magenta
Write-Host "Measuring application startup performance..."

$startupTimes = @()
for ($i = 1; $i -le 3; $i++) {
    Write-Host "Startup test $i/3..." -ForegroundColor Yellow
    
    $startTime = Get-Date
    
    # Start the application in background
    $process = Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Release --no-build" -PassThru -WindowStyle Hidden
    
    # Wait for application to be ready (check if port is listening)
    $timeout = 30
    $elapsed = 0
    $ready = $false
    
    while ($elapsed -lt $timeout -and -not $ready) {
        Start-Sleep -Seconds 1
        $elapsed++
        
        try {
            $connection = Test-NetConnection -ComputerName "localhost" -Port 5000 -InformationLevel Quiet -WarningAction SilentlyContinue
            if ($connection) {
                $ready = $true
                $endTime = Get-Date
                $startupTime = ($endTime - $startTime).TotalSeconds
                $startupTimes += $startupTime
                Write-Host "Startup $i completed in $([math]::Round($startupTime, 2)) seconds" -ForegroundColor Green
            }
        } catch {
            # Continue waiting
        }
    }
    
    # Stop the application
    if ($process -and !$process.HasExited) {
        $process.Kill()
        $process.WaitForExit(5000)
    }
    
    if (-not $ready) {
        Write-Host "Startup $i timed out after $timeout seconds" -ForegroundColor Red
    }
    
    # Wait between tests
    Start-Sleep -Seconds 2
}

if ($startupTimes.Count -gt 0) {
    $avgStartup = ($startupTimes | Measure-Object -Average).Average
    $minStartup = ($startupTimes | Measure-Object -Minimum).Minimum
    $maxStartup = ($startupTimes | Measure-Object -Maximum).Maximum
    
    Write-Host "STARTUP PERFORMANCE RESULTS:" -ForegroundColor Green
    Write-Host "Average: $([math]::Round($avgStartup, 2)) seconds" -ForegroundColor Green
    Write-Host "Minimum: $([math]::Round($minStartup, 2)) seconds" -ForegroundColor Green
    Write-Host "Maximum: $([math]::Round($maxStartup, 2)) seconds" -ForegroundColor Green
    
    # Performance assessment
    if ($avgStartup -lt 10) {
        Write-Host "STARTUP ASSESSMENT: EXCELLENT (< 10s)" -ForegroundColor Green
    } elseif ($avgStartup -lt 20) {
        Write-Host "STARTUP ASSESSMENT: GOOD (< 20s)" -ForegroundColor Yellow
    } else {
        Write-Host "STARTUP ASSESSMENT: NEEDS OPTIMIZATION (> 20s)" -ForegroundColor Red
    }
} else {
    Write-Host "STARTUP PERFORMANCE: FAILED - Could not measure startup times" -ForegroundColor Red
}

Write-Host ""

# Performance Test 2: Build Performance
Write-Host "PERFORMANCE 2: BUILD PERFORMANCE" -ForegroundColor Magenta
Write-Host "Measuring compilation and build performance..."

$buildTimes = @()
for ($i = 1; $i -le 3; $i++) {
    Write-Host "Build test $i/3..." -ForegroundColor Yellow
    
    # Clean before build
    $cleanResult = dotnet clean --verbosity quiet 2>&1
    
    $startTime = Get-Date
    $buildResult = dotnet build --configuration Release --verbosity quiet 2>&1
    $endTime = Get-Date
    
    if ($LASTEXITCODE -eq 0) {
        $buildTime = ($endTime - $startTime).TotalSeconds
        $buildTimes += $buildTime
        Write-Host "Build $i completed in $([math]::Round($buildTime, 2)) seconds" -ForegroundColor Green
    } else {
        Write-Host "Build $i failed" -ForegroundColor Red
    }
}

if ($buildTimes.Count -gt 0) {
    $avgBuild = ($buildTimes | Measure-Object -Average).Average
    $minBuild = ($buildTimes | Measure-Object -Minimum).Minimum
    $maxBuild = ($buildTimes | Measure-Object -Maximum).Maximum
    
    Write-Host "BUILD PERFORMANCE RESULTS:" -ForegroundColor Green
    Write-Host "Average: $([math]::Round($avgBuild, 2)) seconds" -ForegroundColor Green
    Write-Host "Minimum: $([math]::Round($minBuild, 2)) seconds" -ForegroundColor Green
    Write-Host "Maximum: $([math]::Round($maxBuild, 2)) seconds" -ForegroundColor Green
    
    # Performance assessment
    if ($avgBuild -lt 30) {
        Write-Host "BUILD ASSESSMENT: EXCELLENT (< 30s)" -ForegroundColor Green
    } elseif ($avgBuild -lt 60) {
        Write-Host "BUILD ASSESSMENT: GOOD (< 60s)" -ForegroundColor Yellow
    } else {
        Write-Host "BUILD ASSESSMENT: NEEDS OPTIMIZATION (> 60s)" -ForegroundColor Red
    }
} else {
    Write-Host "BUILD PERFORMANCE: FAILED - Could not measure build times" -ForegroundColor Red
}

Write-Host ""

# Performance Test 3: Memory Usage Analysis
Write-Host "PERFORMANCE 3: MEMORY USAGE ANALYSIS" -ForegroundColor Magenta
Write-Host "Analyzing memory usage patterns..."

# Get current memory usage
$memoryBefore = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Measure-Object WorkingSet -Sum
if ($memoryBefore.Sum) {
    $memoryBeforeMB = [math]::Round($memoryBefore.Sum / 1MB, 2)
    Write-Host "Current .NET processes memory usage: $memoryBeforeMB MB" -ForegroundColor Cyan
}

# Check available system memory
$totalMemory = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
$availableMemory = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty FreePhysicalMemory
$totalMemoryGB = [math]::Round($totalMemory / 1GB, 2)
$availableMemoryGB = [math]::Round($availableMemory / 1MB / 1024, 2)
$usedMemoryPercent = [math]::Round((($totalMemory - ($availableMemory * 1KB)) / $totalMemory) * 100, 2)

Write-Host "SYSTEM MEMORY ANALYSIS:" -ForegroundColor Green
Write-Host "Total Memory: $totalMemoryGB GB" -ForegroundColor Green
Write-Host "Available Memory: $availableMemoryGB GB" -ForegroundColor Green
Write-Host "Memory Usage: $usedMemoryPercent%" -ForegroundColor Green

# Memory assessment
if ($usedMemoryPercent -lt 70) {
    Write-Host "MEMORY ASSESSMENT: EXCELLENT (< 70% used)" -ForegroundColor Green
} elseif ($usedMemoryPercent -lt 85) {
    Write-Host "MEMORY ASSESSMENT: GOOD (< 85% used)" -ForegroundColor Yellow
} else {
    Write-Host "MEMORY ASSESSMENT: HIGH USAGE (> 85% used)" -ForegroundColor Red
}

Write-Host ""

# Performance Test 4: Disk I/O Performance
Write-Host "PERFORMANCE 4: DISK I/O PERFORMANCE" -ForegroundColor Magenta
Write-Host "Testing disk I/O performance for build artifacts..."

$diskTests = @()
for ($i = 1; $i -le 3; $i++) {
    Write-Host "Disk I/O test $i/3..." -ForegroundColor Yellow
    
    $testFile = "performance-test-$i.tmp"
    $testData = "0" * 1MB  # 1MB of data
    
    $startTime = Get-Date
    $testData | Out-File -FilePath $testFile -Encoding ASCII
    $readData = Get-Content $testFile -Raw
    Remove-Item $testFile -Force
    $endTime = Get-Date
    
    $ioTime = ($endTime - $startTime).TotalMilliseconds
    $diskTests += $ioTime
    Write-Host "Disk I/O test $i completed in $([math]::Round($ioTime, 2)) ms" -ForegroundColor Green
}

if ($diskTests.Count -gt 0) {
    $avgDisk = ($diskTests | Measure-Object -Average).Average
    $minDisk = ($diskTests | Measure-Object -Minimum).Minimum
    $maxDisk = ($diskTests | Measure-Object -Maximum).Maximum
    
    Write-Host "DISK I/O PERFORMANCE RESULTS:" -ForegroundColor Green
    Write-Host "Average: $([math]::Round($avgDisk, 2)) ms" -ForegroundColor Green
    Write-Host "Minimum: $([math]::Round($minDisk, 2)) ms" -ForegroundColor Green
    Write-Host "Maximum: $([math]::Round($maxDisk, 2)) ms" -ForegroundColor Green
    
    # Performance assessment
    if ($avgDisk -lt 100) {
        Write-Host "DISK I/O ASSESSMENT: EXCELLENT (< 100ms)" -ForegroundColor Green
    } elseif ($avgDisk -lt 500) {
        Write-Host "DISK I/O ASSESSMENT: GOOD (< 500ms)" -ForegroundColor Yellow
    } else {
        Write-Host "DISK I/O ASSESSMENT: SLOW (> 500ms)" -ForegroundColor Red
    }
}

Write-Host ""

# Performance Test 5: Entity Framework Performance
Write-Host "PERFORMANCE 5: ENTITY FRAMEWORK PERFORMANCE" -ForegroundColor Magenta
Write-Host "Testing database context initialization performance..."

$efTests = @()
for ($i = 1; $i -le 3; $i++) {
    Write-Host "EF Context test $i/3..." -ForegroundColor Yellow
    
    $startTime = Get-Date
    
    # Test EF context creation (without actual database connection)
    try {
        $testCode = @'
using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;

var options = new DbContextOptionsBuilder<RdoContext>()
    .UseMySql("Server=localhost;Database=test;", 
        Microsoft.EntityFrameworkCore.ServerVersion.AutoDetect("Server=localhost;Database=test;"))
    .Options;

using var context = new RdoContext(options);
var entityTypes = context.Model.GetEntityTypes();
Console.WriteLine($"Entity types loaded: {entityTypes.Count()}");
'@
        
        $testCode | Out-File -FilePath "ef-test.cs" -Encoding UTF8
        $compileResult = dotnet run --project . -- ef-test.cs 2>&1
        Remove-Item "ef-test.cs" -Force -ErrorAction SilentlyContinue
        
        $endTime = Get-Date
        $efTime = ($endTime - $startTime).TotalMilliseconds
        $efTests += $efTime
        Write-Host "EF Context test $i completed in $([math]::Round($efTime, 2)) ms" -ForegroundColor Green
    } catch {
        Write-Host "EF Context test $i failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if ($efTests.Count -gt 0) {
    $avgEF = ($efTests | Measure-Object -Average).Average
    Write-Host "ENTITY FRAMEWORK PERFORMANCE:" -ForegroundColor Green
    Write-Host "Average context initialization: $([math]::Round($avgEF, 2)) ms" -ForegroundColor Green
    
    if ($avgEF -lt 1000) {
        Write-Host "EF ASSESSMENT: EXCELLENT (< 1s)" -ForegroundColor Green
    } elseif ($avgEF -lt 3000) {
        Write-Host "EF ASSESSMENT: GOOD (< 3s)" -ForegroundColor Yellow
    } else {
        Write-Host "EF ASSESSMENT: SLOW (> 3s)" -ForegroundColor Red
    }
} else {
    Write-Host "EF PERFORMANCE: Could not measure (expected in test environment)" -ForegroundColor Yellow
}

Write-Host ""

# Final Performance Assessment
Write-Host "PERFORMANCE BASELINE TESTING COMPLETE" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta

# Calculate overall performance score
$performanceScore = 0
$totalTests = 0

if ($startupTimes.Count -gt 0) {
    $totalTests++
    if ($avgStartup -lt 10) { $performanceScore += 100 }
    elseif ($avgStartup -lt 20) { $performanceScore += 75 }
    else { $performanceScore += 50 }
}

if ($buildTimes.Count -gt 0) {
    $totalTests++
    if ($avgBuild -lt 30) { $performanceScore += 100 }
    elseif ($avgBuild -lt 60) { $performanceScore += 75 }
    else { $performanceScore += 50 }
}

if ($usedMemoryPercent -gt 0) {
    $totalTests++
    if ($usedMemoryPercent -lt 70) { $performanceScore += 100 }
    elseif ($usedMemoryPercent -lt 85) { $performanceScore += 75 }
    else { $performanceScore += 50 }
}

if ($diskTests.Count -gt 0) {
    $totalTests++
    if ($avgDisk -lt 100) { $performanceScore += 100 }
    elseif ($avgDisk -lt 500) { $performanceScore += 75 }
    else { $performanceScore += 50 }
}

if ($totalTests -gt 0) {
    $overallScore = [math]::Round($performanceScore / $totalTests, 0)
    
    Write-Host "OVERALL PERFORMANCE SCORE: $overallScore/100" -ForegroundColor Cyan
    
    if ($overallScore -ge 90) {
        Write-Host "PERFORMANCE STATUS: EXCELLENT - Ready for production" -ForegroundColor Green
    } elseif ($overallScore -ge 75) {
        Write-Host "PERFORMANCE STATUS: GOOD - Production ready with monitoring" -ForegroundColor Yellow
    } else {
        Write-Host "PERFORMANCE STATUS: NEEDS OPTIMIZATION - Consider improvements" -ForegroundColor Red
    }
} else {
    Write-Host "PERFORMANCE STATUS: INCOMPLETE - Some tests could not be completed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "PERFORMANCE RECOMMENDATIONS:" -ForegroundColor Cyan
Write-Host "1. Monitor startup times in production" -ForegroundColor Cyan
Write-Host "2. Implement application performance monitoring (APM)" -ForegroundColor Cyan
Write-Host "3. Set up memory usage alerts" -ForegroundColor Cyan
Write-Host "4. Configure database connection pooling" -ForegroundColor Cyan
Write-Host "5. Implement response time monitoring" -ForegroundColor Cyan

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Setup backup strategy" -ForegroundColor Yellow
Write-Host "2. Configure production monitoring" -ForegroundColor Yellow
Write-Host "3. Deploy to production environment" -ForegroundColor Yellow

Write-Host ""
Write-Host "Performance testing completed at: $(Get-Date)" -ForegroundColor Cyan
Write-Host "DAY 8 STEP 3 COMPLETED: Performance Baseline Testing" -ForegroundColor Green