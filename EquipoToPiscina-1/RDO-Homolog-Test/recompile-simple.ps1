# Simple Recompile and Test Script
Write-Host "=== RECOMPILING APPLICATION ===" -ForegroundColor Green

# Clean build folders
Write-Host "1. Cleaning build folders..." -ForegroundColor Cyan
if (Test-Path "rdoappProject\bin") {
    Remove-Item "rdoappProject\bin" -Recurse -Force
    Write-Host "   - Removed bin folder" -ForegroundColor Gray
}
if (Test-Path "rdoappProject\obj") {
    Remove-Item "rdoappProject\obj" -Recurse -Force
    Write-Host "   - Removed obj folder" -ForegroundColor Gray
}

# Find MSBuild
Write-Host "2. Finding MSBuild..." -ForegroundColor Cyan
$msbuildPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe"
)

$msbuildPath = ""
foreach ($path in $msbuildPaths) {
    if (Test-Path $path) {
        $msbuildPath = $path
        Write-Host "   - Found MSBuild at: $path" -ForegroundColor Green
        break
    }
}

if (-not $msbuildPath) {
    Write-Host "   - MSBuild not found!" -ForegroundColor Red
    exit 1
}

# Build project
Write-Host "3. Building project..." -ForegroundColor Cyan
try {
    Set-Location "rdoappProject"
    & $msbuildPath "rdoappProject.csproj" /p:Configuration=Release /p:Platform="Any CPU" /verbosity:minimal
    Set-Location ".."
    
    if (Test-Path "rdoappProject\bin") {
        Write-Host "   - Build SUCCESS!" -ForegroundColor Green
        
        # List built files
        $binFiles = Get-ChildItem "rdoappProject\bin" -Recurse -File
        Write-Host "   - Built $($binFiles.Count) files" -ForegroundColor Gray
        
        # Start IIS Express
        Write-Host "4. Starting application..." -ForegroundColor Cyan
        $iisPath = "${env:ProgramFiles}\IIS Express\iisexpress.exe"
        if (-not (Test-Path $iisPath)) {
            $iisPath = "${env:ProgramFiles(x86)}\IIS Express\iisexpress.exe"
        }
        
        if (Test-Path $iisPath) {
            $projectPath = (Get-Location).Path + "\rdoappProject"
            Write-Host "   - Starting on http://localhost:8080" -ForegroundColor Yellow
            Write-Host "   - Press Ctrl+C to stop" -ForegroundColor Gray
            
            & $iisPath /path:$projectPath /port:8080
        } else {
            Write-Host "   - IIS Express not found, but build was successful" -ForegroundColor Yellow
            Write-Host "   - You can deploy the bin folder contents manually" -ForegroundColor Gray
        }
    } else {
        Write-Host "   - Build FAILED - no bin folder created" -ForegroundColor Red
    }
} catch {
    Write-Host "   - Build ERROR: $($_.Exception.Message)" -ForegroundColor Red
}