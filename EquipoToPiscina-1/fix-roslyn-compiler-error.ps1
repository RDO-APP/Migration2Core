# Fix Roslyn Compiler Error in RDO Homolog Test Environment
# This script resolves the "Não foi possível localizar uma parte do caminho 'roslyn\csc.exe'" error

Write-Host "🔧 FIXING ROSLYN COMPILER ERROR..." -ForegroundColor Yellow
Write-Host ""

# Navigate to the project directory
$projectPath = "RDO-Homolog-Test\rdoappProject"
if (!(Test-Path $projectPath)) {
    Write-Host "❌ Project path not found: $projectPath" -ForegroundColor Red
    exit 1
}

Write-Host "📁 Project path found: $projectPath" -ForegroundColor Green

# Check if roslyn folder exists
$roslynPath = "$projectPath\bin\roslyn"
if (!(Test-Path $roslynPath)) {
    Write-Host "📁 Creating roslyn directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $roslynPath -Force | Out-Null
    Write-Host "✅ Roslyn directory created" -ForegroundColor Green
} else {
    Write-Host "📁 Roslyn directory already exists" -ForegroundColor Green
}

# Install Microsoft.CodeDom.Providers.DotNetCompilerPlatform package if needed
Write-Host "📦 Checking NuGet packages..." -ForegroundColor Yellow

# Check packages.config
$packagesConfig = "$projectPath\packages.config"
if (Test-Path $packagesConfig) {
    $content = Get-Content $packagesConfig -Raw
    if ($content -notmatch "Microsoft.CodeDom.Providers.DotNetCompilerPlatform") {
        Write-Host "⚠️  Microsoft.CodeDom.Providers.DotNetCompilerPlatform not found in packages.config" -ForegroundColor Yellow
        Write-Host "💡 You may need to install this package via NuGet Package Manager in Visual Studio" -ForegroundColor Cyan
    } else {
        Write-Host "✅ Microsoft.CodeDom.Providers.DotNetCompilerPlatform found in packages.config" -ForegroundColor Green
    }
}

# Alternative solution: Disable Roslyn compiler in Web.config
Write-Host "🔧 Applying Web.config fix..." -ForegroundColor Yellow

$webConfigPath = "$projectPath\Web.config"
if (Test-Path $webConfigPath) {
    $webConfig = Get-Content $webConfigPath -Raw
    
    # Check if the fix is already applied
    if ($webConfig -match 'codeSubDirectories.*roslyn') {
        Write-Host "✅ Web.config already contains Roslyn fix" -ForegroundColor Green
    } else {
        # Apply the fix by adding compilation settings
        $compilationFix = @"
  <system.web>
    <compilation debug="true" targetFramework="4.8" tempDirectory="~/App_Data/Temp/">
      <assemblies>
        <add assembly="*" />
      </assemblies>
    </compilation>
"@
        
        # Backup original Web.config
        Copy-Item $webConfigPath "$webConfigPath.backup" -Force
        Write-Host "📋 Web.config backed up" -ForegroundColor Green
        
        # The fix will be applied manually since Web.config structure varies
        Write-Host "💡 Manual Web.config fix needed - see instructions below" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "🎯 ROSLYN COMPILER ERROR SOLUTIONS:" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "SOLUTION 1: Clean and Rebuild" -ForegroundColor Yellow
Write-Host "1. In Visual Studio: Build → Clean Solution" -ForegroundColor White
Write-Host "2. Build → Rebuild Solution" -ForegroundColor White
Write-Host "3. Press F5 to run" -ForegroundColor White
Write-Host ""
Write-Host "SOLUTION 2: NuGet Package Restore" -ForegroundColor Yellow
Write-Host "1. Right-click Solution → Restore NuGet Packages" -ForegroundColor White
Write-Host "2. Build → Rebuild Solution" -ForegroundColor White
Write-Host ""
Write-Host "SOLUTION 3: Manual Roslyn Fix" -ForegroundColor Yellow
Write-Host "1. Delete bin and obj folders" -ForegroundColor White
Write-Host "2. In Package Manager Console run:" -ForegroundColor White
Write-Host "   Update-Package Microsoft.CodeDom.Providers.DotNetCompilerPlatform -Reinstall" -ForegroundColor Cyan
Write-Host ""
Write-Host "SOLUTION 4: Web.config Modification" -ForegroundColor Yellow
Write-Host "Add this to <system.web> section in Web.config:" -ForegroundColor White
Write-Host "<compilation debug='true' targetFramework='4.8' tempDirectory='~/App_Data/Temp/' />" -ForegroundColor Cyan
Write-Host ""
Write-Host "🚀 Try SOLUTION 1 first - it usually resolves the issue!" -ForegroundColor Green
Write-Host ""