# Recompile with Visual Studio
Write-Host "=== RECOMPILING WITH VISUAL STUDIO ===" -ForegroundColor Green

# Find Visual Studio
$vsPath = "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.exe"
if (Test-Path $vsPath) {
    Write-Host "1. Found Visual Studio at: $vsPath" -ForegroundColor Green
} else {
    Write-Host "1. Visual Studio not found!" -ForegroundColor Red
    exit 1
}

# Clean build folders
Write-Host "2. Cleaning build folders..." -ForegroundColor Cyan
Set-Location "rdoappProject"

if (Test-Path "bin") {
    Remove-Item "bin" -Recurse -Force
    Write-Host "   - Removed bin folder" -ForegroundColor Gray
}
if (Test-Path "obj") {
    Remove-Item "obj" -Recurse -Force
    Write-Host "   - Removed obj folder" -ForegroundColor Gray
}

# Build with Visual Studio
Write-Host "3. Building project with Visual Studio..." -ForegroundColor Cyan
try {
    # Use devenv to build the project
    $buildArgs = "rdoappProject.csproj /build Release"
    $process = Start-Process -FilePath $vsPath -ArgumentList $buildArgs -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Host "   - Build process completed successfully" -ForegroundColor Green
    } else {
        Write-Host "   - Build process returned exit code: $($process.ExitCode)" -ForegroundColor Yellow
    }
    
    # Check if build was successful
    if (Test-Path "bin") {
        Write-Host "   - Build SUCCESS! Bin folder created" -ForegroundColor Green
        
        # List built files
        $binFiles = Get-ChildItem "bin" -Recurse -File
        Write-Host "   - Built $($binFiles.Count) files" -ForegroundColor Gray
        
        # Show key files
        $dlls = $binFiles | Where-Object { $_.Extension -eq ".dll" }
        $exes = $binFiles | Where-Object { $_.Extension -eq ".exe" }
        
        if ($dlls) {
            Write-Host "   - DLL files:" -ForegroundColor Gray
            $dlls | Select-Object -First 5 | ForEach-Object { Write-Host "     * $($_.Name)" -ForegroundColor Gray }
        }
        
        if ($exes) {
            Write-Host "   - EXE files:" -ForegroundColor Gray
            $exes | ForEach-Object { Write-Host "     * $($_.Name)" -ForegroundColor Gray }
        }
        
        Write-Host "`n=== BUILD SUCCESSFUL ===" -ForegroundColor Green
        Write-Host "The application has been recompiled!" -ForegroundColor Yellow
        
        # Try to start the application
        Write-Host "4. Attempting to start application..." -ForegroundColor Cyan
        
        # Look for IIS Express
        $iisPath = "C:\Program Files\IIS Express\iisexpress.exe"
        if (-not (Test-Path $iisPath)) {
            $iisPath = "C:\Program Files (x86)\IIS Express\iisexpress.exe"
        }
        
        if (Test-Path $iisPath) {
            $projectPath = (Get-Location).Path
            Write-Host "   - Starting IIS Express on port 8080..." -ForegroundColor Yellow
            Write-Host "   - URL: http://localhost:8080" -ForegroundColor Green
            Write-Host "   - Press Ctrl+C to stop the server" -ForegroundColor Gray
            
            # Start IIS Express
            & $iisPath /path:$projectPath /port:8080
            
        } else {
            Write-Host "   - IIS Express not found" -ForegroundColor Yellow
            Write-Host "   - You can test the application by:" -ForegroundColor Cyan
            Write-Host "     1. Opening Visual Studio" -ForegroundColor Gray
            Write-Host "     2. Opening the project" -ForegroundColor Gray
            Write-Host "     3. Pressing F5 to run" -ForegroundColor Gray
        }
        
    } else {
        Write-Host "   - Build may have failed - no bin folder created" -ForegroundColor Red
        Write-Host "   - Check Visual Studio for error details" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "   - Error during build: $($_.Exception.Message)" -ForegroundColor Red
}

Set-Location ".."
Write-Host "`nRecompilation process completed!" -ForegroundColor Magenta