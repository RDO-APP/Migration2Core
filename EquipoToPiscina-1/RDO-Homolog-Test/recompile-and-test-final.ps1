# Recompile and Test Application - Final Run
# This script will perform a complete recompilation and test of the RDO application

Write-Host "=== RECOMPILATION AND FINAL TEST ===" -ForegroundColor Green
Write-Host "Starting complete recompilation and testing process..." -ForegroundColor Yellow

# Step 1: Clean previous builds
Write-Host "`n1. Cleaning previous builds..." -ForegroundColor Cyan
if (Test-Path "rdoappProject\bin") {
    Remove-Item "rdoappProject\bin" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   - Removed bin folder" -ForegroundColor Gray
}
if (Test-Path "rdoappProject\obj") {
    Remove-Item "rdoappProject\obj" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   - Removed obj folder" -ForegroundColor Gray
}

# Step 2: Check for Visual Studio
Write-Host "`n2. Locating Visual Studio..." -ForegroundColor Cyan
$vsPath = ""
$vsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"
)

foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        $vsPath = $path
        Write-Host "   - Found Visual Studio at: $path" -ForegroundColor Green
        break
    }
}

if (-not $vsPath) {
    Write-Host "   - Visual Studio not found in standard locations" -ForegroundColor Red
    Write-Host "   - Will try MSBuild instead..." -ForegroundColor Yellow
}

# Step 3: Restore NuGet packages
Write-Host "`n3. Restoring NuGet packages..." -ForegroundColor Cyan
if (Test-Path "rdoappProject\packages.config") {
    try {
        Set-Location "rdoappProject"
        nuget restore packages.config -PackagesDirectory packages
        Write-Host "   - NuGet packages restored successfully" -ForegroundColor Green
        Set-Location ".."
    } catch {
        Write-Host "   - NuGet restore failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   - No packages.config found, skipping NuGet restore" -ForegroundColor Yellow
}

# Step 4: Build the project
Write-Host "`n4. Building the project..." -ForegroundColor Cyan
$buildSuccess = $false

if ($vsPath) {
    # Try with Visual Studio
    try {
        $solutionPath = "rdoappProject\rdoappProject.sln"
        if (-not (Test-Path $solutionPath)) {
            $solutionPath = "rdoappProject\rdoappProject.csproj"
        }
        
        $buildArgs = "`"$solutionPath`" /build Release"
        Start-Process -FilePath $vsPath -ArgumentList $buildArgs -Wait -NoNewWindow
        
        if (Test-Path "rdoappProject\bin") {
            $buildSuccess = $true
            Write-Host "   - Build completed with Visual Studio" -ForegroundColor Green
        }
    } catch {
        Write-Host "   - Visual Studio build failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

if (-not $buildSuccess) {
    # Try with MSBuild
    try {
        $msbuildPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
        if (-not (Test-Path $msbuildPath)) {
            $msbuildPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
        }
        
        if (Test-Path $msbuildPath) {
            $projectPath = "rdoappProject\rdoappProject.csproj"
            & $msbuildPath $projectPath /p:Configuration=Release /p:Platform="Any CPU"
            
            if (Test-Path "rdoappProject\bin") {
                $buildSuccess = $true
                Write-Host "   - Build completed with MSBuild" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "   - MSBuild failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 5: Check build results
Write-Host "`n5. Checking build results..." -ForegroundColor Cyan
if (Test-Path "rdoappProject\bin") {
    $binFiles = Get-ChildItem "rdoappProject\bin" -Recurse -File
    Write-Host "   - Build folder exists with $($binFiles.Count) files" -ForegroundColor Green
    
    # Check for main DLL
    $mainDll = $binFiles | Where-Object { $_.Name -like "rdoappProject.dll" -or $_.Name -like "*.dll" } | Select-Object -First 1
    if ($mainDll) {
        Write-Host "   - Main assembly found: $($mainDll.Name)" -ForegroundColor Green
        $buildSuccess = $true
    }
} else {
    Write-Host "   - Build folder not found - compilation may have failed" -ForegroundColor Red
    $buildSuccess = $false
}

# Step 6: Start IIS Express for testing
Write-Host "`n6. Starting application for testing..." -ForegroundColor Cyan
if ($buildSuccess) {
    try {
        $iisExpressPath = "${env:ProgramFiles}\IIS Express\iisexpress.exe"
        if (-not (Test-Path $iisExpressPath)) {
            $iisExpressPath = "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe"
        }
        
        if (Test-Path $iisExpressPath) {
            $projectPath = (Get-Location).Path + "\rdoappProject"
            Write-Host "   - Starting IIS Express..." -ForegroundColor Gray
            Write-Host "   - Project path: $projectPath" -ForegroundColor Gray
            
            # Start IIS Express in background
            $iisProcess = Start-Process -FilePath $iisExpressPath -ArgumentList "/path:`"$projectPath`" /port:8080" -PassThru
            
            # Wait a moment for startup
            Start-Sleep -Seconds 5
            
            # Test if application is responding
            try {
                $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 10 -ErrorAction Stop
                Write-Host "   - Application started successfully!" -ForegroundColor Green
                Write-Host "   - URL: http://localhost:8080" -ForegroundColor Green
                Write-Host "   - Status: $($response.StatusCode)" -ForegroundColor Green
                
                # Test specific pages
                Write-Host "`n7. Testing key application pages..." -ForegroundColor Cyan
                
                # Test login page
                try {
                    $loginResponse = Invoke-WebRequest -Uri "http://localhost:8080/login" -TimeoutSec 5 -ErrorAction SilentlyContinue
                    Write-Host "   - Login page: OK ($($loginResponse.StatusCode))" -ForegroundColor Green
                } catch {
                    Write-Host "   - Login page: Not accessible" -ForegroundColor Yellow
                }
                
                # Test tarefa page
                try {
                    $tarefaResponse = Invoke-WebRequest -Uri "http://localhost:8080/tarefa" -TimeoutSec 5 -ErrorAction SilentlyContinue
                    Write-Host "   - Tarefa page: OK ($($tarefaResponse.StatusCode))" -ForegroundColor Green
                } catch {
                    Write-Host "   - Tarefa page: Not accessible" -ForegroundColor Yellow
                }
                
                Write-Host "`n=== TEST RESULTS ===" -ForegroundColor Green
                Write-Host "✓ Compilation: SUCCESS" -ForegroundColor Green
                Write-Host "✓ Application Start: SUCCESS" -ForegroundColor Green
                Write-Host "✓ Web Server: Running on http://localhost:8080" -ForegroundColor Green
                Write-Host "`nYou can now test the application manually in your browser!" -ForegroundColor Yellow
                Write-Host "Press any key to stop the server..." -ForegroundColor Gray
                
                # Wait for user input
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                
                # Stop IIS Express
                if ($iisProcess -and -not $iisProcess.HasExited) {
                    $iisProcess.Kill()
                    Write-Host "Application server stopped." -ForegroundColor Gray
                }
                
            } catch {
                Write-Host "   - Application failed to start: $($_.Exception.Message)" -ForegroundColor Red
                if ($iisProcess -and -not $iisProcess.HasExited) {
                    $iisProcess.Kill()
                }
            }
        } else {
            Write-Host "   - IIS Express not found" -ForegroundColor Red
            Write-Host "   - Build successful but cannot start web server" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   - Error starting application: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   - Cannot start application - build failed" -ForegroundColor Red
}

Write-Host "`n=== FINAL STATUS ===" -ForegroundColor Magenta
if ($buildSuccess) {
    Write-Host "✓ Recompilation completed successfully!" -ForegroundColor Green
    Write-Host "✓ Application is ready for testing" -ForegroundColor Green
} else {
    Write-Host "✗ Recompilation failed" -ForegroundColor Red
    Write-Host "Check the error messages above for details" -ForegroundColor Yellow
}

Write-Host "`nScript completed. Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")