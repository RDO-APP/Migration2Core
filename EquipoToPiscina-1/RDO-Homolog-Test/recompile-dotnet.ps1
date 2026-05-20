# Recompile with .NET CLI
Write-Host "=== RECOMPILING WITH .NET CLI ===" -ForegroundColor Green

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

# Check project structure
Write-Host "2. Checking project structure..." -ForegroundColor Cyan
Set-Location "rdoappProject"

if (Test-Path "rdoappProject.csproj") {
    Write-Host "   - Found .csproj file" -ForegroundColor Green
} elseif (Test-Path "rdoappProject.sln") {
    Write-Host "   - Found .sln file" -ForegroundColor Green
} else {
    Write-Host "   - No project file found, listing contents:" -ForegroundColor Yellow
    Get-ChildItem | Select-Object Name, LastWriteTime | Format-Table
}

# Try to restore packages
Write-Host "3. Restoring packages..." -ForegroundColor Cyan
try {
    dotnet restore
    Write-Host "   - Package restore completed" -ForegroundColor Green
} catch {
    Write-Host "   - Package restore failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Try to build
Write-Host "4. Building project..." -ForegroundColor Cyan
try {
    dotnet build --configuration Release --verbosity minimal
    
    if (Test-Path "bin") {
        Write-Host "   - Build SUCCESS!" -ForegroundColor Green
        
        # List built files
        $binFiles = Get-ChildItem "bin" -Recurse -File
        Write-Host "   - Built $($binFiles.Count) files" -ForegroundColor Gray
        
        # Show some key files
        $dlls = $binFiles | Where-Object { $_.Extension -eq ".dll" }
        if ($dlls) {
            Write-Host "   - Key assemblies:" -ForegroundColor Gray
            $dlls | ForEach-Object { Write-Host "     * $($_.Name)" -ForegroundColor Gray }
        }
        
        Write-Host "`n=== BUILD SUCCESSFUL ===" -ForegroundColor Green
        Write-Host "The application has been recompiled successfully!" -ForegroundColor Yellow
        Write-Host "You can now test it by:" -ForegroundColor Cyan
        Write-Host "1. Opening Visual Studio" -ForegroundColor Gray
        Write-Host "2. Running the project (F5)" -ForegroundColor Gray
        Write-Host "3. Or deploying the bin folder to IIS" -ForegroundColor Gray
        
    } else {
        Write-Host "   - Build completed but no bin folder found" -ForegroundColor Yellow
        Write-Host "   - This might be normal for some project types" -ForegroundColor Gray
    }
    
} catch {
    Write-Host "   - Build failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   - Trying alternative build approach..." -ForegroundColor Yellow
    
    # Try with specific framework
    try {
        dotnet build --framework net48 --configuration Release
        Write-Host "   - Alternative build completed" -ForegroundColor Green
    } catch {
        Write-Host "   - Alternative build also failed" -ForegroundColor Red
    }
}

Set-Location ".."

Write-Host "`nRecompilation process completed!" -ForegroundColor Magenta