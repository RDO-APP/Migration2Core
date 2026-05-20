@echo off
echo ========================================
echo    RDO APP PROCESS CLEANUP UTILITY
echo    Resolving Compilation Lock Issues
echo ========================================
echo.

echo [1/4] Stopping IIS Express processes...
taskkill /f /im "iisexpress.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ IIS Express processes stopped
) else (
    echo ℹ️  No IIS Express processes found
)

echo.
echo [2/4] Stopping .NET processes...
taskkill /f /im "dotnet.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ .NET processes stopped
) else (
    echo ℹ️  No .NET processes found
)

echo.
echo [3/4] Stopping RdoApp.Core processes...
taskkill /f /im "RdoApp.Core.exe" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ RdoApp.Core processes stopped
) else (
    echo ℹ️  No RdoApp.Core processes found
)

echo.
echo [4/4] Cleaning temporary files...
cd /d "RDO-NET8-Migration\RdoApp.Core"
if exist "bin\Debug" (
    rmdir /s /q "bin\Debug" >nul 2>&1
    echo ✅ Debug folder cleaned
)
if exist "obj" (
    rmdir /s /q "obj" >nul 2>&1
    echo ✅ Obj folder cleaned
)

echo.
echo ========================================
echo    CLEANUP COMPLETE ✅
echo    You can now compile safely
echo ========================================
echo.
echo Next steps:
echo 1. Run: dotnet build
echo 2. Run: dotnet run
echo 3. Test at: http://localhost:5031/etapa/cards-blazor/1
echo.
pause