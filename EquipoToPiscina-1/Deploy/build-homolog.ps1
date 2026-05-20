# Build Script for Homologation Environment
# Usage: .\Deploy\build-homolog.ps1

param(
    [string]$Configuration = "Debug"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  RDO App - Homologation Build Script  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Clean previous builds
Write-Host "[1/5] Cleaning previous builds..." -ForegroundColor Yellow
Remove-Item "rdoappClass\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "rdoappClass\obj" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "rdoappProject\bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "rdoappProject\obj" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   ✓ Clean completed" -ForegroundColor Green

# Step 2: Backup current production DLLs (if they exist)
Write-Host "`n[2/5] Creating backup of current DLLs..." -ForegroundColor Yellow
$backupFolder = "Deploy\backup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
if (Test-Path "rdoappProject\bin") {
    New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
    Copy-Item "rdoappProject\bin\*" -Destination $backupFolder -Recurse -ErrorAction SilentlyContinue
    Write-Host "   ✓ Backup created at: $backupFolder" -ForegroundColor Green
} else {
    Write-Host "   ⚠ No existing bin folder to backup" -ForegroundColor Gray
}

# Step 3: Update connection string for homolog
Write-Host "`n[3/5] Updating connection string for homolog..." -ForegroundColor Yellow
$webConfigPath = "rdoappProject\Web.config"
if (Test-Path $webConfigPath) {
    # Create backup of Web.config
    Copy-Item $webConfigPath "$webConfigPath.backup" -Force
    
    # Read and update connection string
    $webConfig = Get-Content $webConfigPath -Raw
    $webConfig = $webConfig -replace 'database=piscinas_rdoapp"', 'database=piscinas_rdoapp_homolog"'
    $webConfig = $webConfig -replace '<add key="Environment" value="Production"', '<add key="Environment" value="Homologation"'
    Set-Content $webConfigPath $webConfig
    
    Write-Host "   ✓ Connection string updated to homolog database" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Web.config not found" -ForegroundColor Red
}

# Step 4: Build the solution
Write-Host "`n[4/5] Building solution..." -ForegroundColor Yellow
Write-Host "   Note: This requires Visual Studio or MSBuild to be installed" -ForegroundColor Gray

# Try to find MSBuild
$msbuildPath = & "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" `
    -latest -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe `
    -ErrorAction SilentlyContinue | Select-Object -First 1

if ($msbuildPath) {
    Write-Host "   Found MSBuild at: $msbuildPath" -ForegroundColor Gray
    
    # Build rdoappClass first
    & $msbuildPath "rdoappClass\rdoappClass.csproj" /p:Configuration=$Configuration /t:Rebuild /v:minimal
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✓ rdoappClass built successfully" -ForegroundColor Green
        
        # Build rdoappProject
        & $msbuildPath "rdoappProject\rdoappProject.csproj" /p:Configuration=$Configuration /t:Rebuild /v:minimal
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   ✓ rdoappProject built successfully" -ForegroundColor Green
        } else {
            Write-Host "   ✗ rdoappProject build failed" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "   ✗ rdoappClass build failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ⚠ MSBuild not found. Please build manually in Visual Studio:" -ForegroundColor Yellow
    Write-Host "      1. Open solution in Visual Studio" -ForegroundColor Gray
    Write-Host "      2. Right-click rdoappModel.tt -> Run Custom Tool" -ForegroundColor Gray
    Write-Host "      3. Right-click rdoappModel.Context.tt -> Run Custom Tool" -ForegroundColor Gray
    Write-Host "      4. Build Solution (Ctrl+Shift+B)" -ForegroundColor Gray
}

# Step 5: Verify build output
Write-Host "`n[5/5] Verifying build output..." -ForegroundColor Yellow
$dllPath = "rdoappClass\bin\$Configuration\rdoappClass.dll"
if (Test-Path $dllPath) {
    $dllInfo = Get-Item $dllPath
    Write-Host "   ✓ rdoappClass.dll created" -ForegroundColor Green
    Write-Host "     Size: $($dllInfo.Length) bytes" -ForegroundColor Gray
    Write-Host "     Modified: $($dllInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "   ✗ rdoappClass.dll not found" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Build Process Complete!                " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Test the application locally" -ForegroundColor White
Write-Host "2. Run .\Deploy\test-homolog.ps1 to verify functionality" -ForegroundColor White
Write-Host "3. Deploy to homolog server using .\Deploy\deploy-homolog.ps1" -ForegroundColor White
Write-Host ""
