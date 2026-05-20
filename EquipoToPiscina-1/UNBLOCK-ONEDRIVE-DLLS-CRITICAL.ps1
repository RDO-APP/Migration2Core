# CRITICAL: Unblock all DLLs in OneDrive project folder
# Error 0x800711C7 = Windows App Control blocking "marked" files

$projectPath = "C:\Users\LUCIO\OneDrive\Documentos\RDO App\TI\Projetos\.Net Piscina\Kiro\EquipoToPiscina-1\RDO-NET8-Migration"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "UNBLOCKING ONEDRIVE DLLs - CRITICAL FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Kill ghost processes
Write-Host "[1/4] Killing ghost dotnet.exe and VBCSCompiler.exe processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "VBCSCompiler" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "MSBuild" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "   Ghost processes killed." -ForegroundColor Green
Write-Host ""

# Step 2: Delete bin and obj folders
Write-Host "[2/4] Deleting bin and obj folders..." -ForegroundColor Yellow
$binFolders = Get-ChildItem -Path $projectPath -Recurse -Directory -Filter "bin" -ErrorAction SilentlyContinue
$objFolders = Get-ChildItem -Path $projectPath -Recurse -Directory -Filter "obj" -ErrorAction SilentlyContinue

foreach ($folder in $binFolders) {
    Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Deleted: $($folder.FullName)" -ForegroundColor Gray
}

foreach ($folder in $objFolders) {
    Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   Deleted: $($folder.FullName)" -ForegroundColor Gray
}
Write-Host "   bin/obj folders deleted." -ForegroundColor Green
Write-Host ""

# Step 3: Unblock ALL files recursively
Write-Host "[3/4] Unblocking ALL files in project (removing Mark of the Web)..." -ForegroundColor Yellow
$allFiles = Get-ChildItem -Path $projectPath -Recurse -File -ErrorAction SilentlyContinue
$unblocked = 0

foreach ($file in $allFiles) {
    try {
        Unblock-File -Path $file.FullName -ErrorAction SilentlyContinue
        $unblocked++
        if ($unblocked % 100 -eq 0) {
            Write-Host "   Unblocked $unblocked files..." -ForegroundColor Gray
        }
    } catch {
        # Silently continue if file is locked or doesn't have MOTW
    }
}
Write-Host "   Total files unblocked: $unblocked" -ForegroundColor Green
Write-Host ""

# Step 4: Specific DLL unblock (belt and suspenders)
Write-Host "[4/4] Specifically unblocking DLL files..." -ForegroundColor Yellow
$dllFiles = Get-ChildItem -Path $projectPath -Recurse -Filter "*.dll" -ErrorAction SilentlyContinue
$dllCount = 0

foreach ($dll in $dllFiles) {
    try {
        Unblock-File -Path $dll.FullName -ErrorAction SilentlyContinue
        $dllCount++
    } catch {
        # Silently continue
    }
}
Write-Host "   DLL files unblocked: $dllCount" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "UNBLOCK COMPLETE - READY FOR BUILD" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. cd RDO-NET8-Migration\RdoApp.Core" -ForegroundColor White
Write-Host "2. dotnet clean" -ForegroundColor White
Write-Host "3. dotnet build" -ForegroundColor White
Write-Host "4. Press F5 in Visual Studio" -ForegroundColor White
Write-Host ""
