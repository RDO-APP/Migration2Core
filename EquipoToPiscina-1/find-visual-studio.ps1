# Find Visual Studio installations
Write-Host "🔍 SEARCHING FOR VISUAL STUDIO INSTALLATIONS" -ForegroundColor Yellow
Write-Host ""

# Method 1: Check common installation paths
Write-Host "1️⃣  Checking common installation paths..." -ForegroundColor Green
$commonPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.exe"
)

$foundPaths = @()
foreach ($path in $commonPaths) {
    if (Test-Path $path) {
        Write-Host "   ✅ Found: $path" -ForegroundColor Green
        $foundPaths += $path
    } else {
        Write-Host "   ❌ Not found: $path" -ForegroundColor Red
    }
}

# Method 2: Use vswhere.exe (Visual Studio installer tool)
Write-Host ""
Write-Host "2️⃣  Using vswhere.exe to find installations..." -ForegroundColor Green
$vswherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswherePath) {
    Write-Host "   ✅ vswhere.exe found" -ForegroundColor Green
    try {
        $vsInstances = & $vswherePath -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($vsInstances) {
            foreach ($instance in $vsInstances) {
                $devenvPath = Join-Path $instance "Common7\IDE\devenv.exe"
                if (Test-Path $devenvPath) {
                    Write-Host "   ✅ Found via vswhere: $devenvPath" -ForegroundColor Green
                    $foundPaths += $devenvPath
                }
            }
        } else {
            Write-Host "   ❌ No Visual Studio instances found via vswhere" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Error running vswhere: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   ❌ vswhere.exe not found at: $vswherePath" -ForegroundColor Red
}

# Method 3: Search in registry
Write-Host ""
Write-Host "3️⃣  Checking Windows Registry..." -ForegroundColor Green
try {
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7"
    )
    
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            $regKeys = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
            if ($regKeys) {
                $regKeys.PSObject.Properties | Where-Object { $_.Name -match "^\d+\.\d+$" } | ForEach-Object {
                    $vsPath = $_.Value
                    $devenvPath = Join-Path $vsPath "Common7\IDE\devenv.exe"
                    if (Test-Path $devenvPath) {
                        Write-Host "   ✅ Found in registry: $devenvPath" -ForegroundColor Green
                        $foundPaths += $devenvPath
                    }
                }
            }
        }
    }
} catch {
    Write-Host "   ❌ Error checking registry: $($_.Exception.Message)" -ForegroundColor Red
}

# Method 4: Search entire Program Files
Write-Host ""
Write-Host "4️⃣  Searching entire Program Files (this may take a moment)..." -ForegroundColor Green
try {
    $searchPaths = @(
        $env:ProgramFiles,
        ${env:ProgramFiles(x86)}
    )
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $devenvFiles = Get-ChildItem -Path $searchPath -Recurse -Name "devenv.exe" -ErrorAction SilentlyContinue | Where-Object { $_ -like "*Visual Studio*" }
            foreach ($file in $devenvFiles) {
                $fullPath = Join-Path $searchPath $file
                Write-Host "   ✅ Found by search: $fullPath" -ForegroundColor Green
                $foundPaths += $fullPath
            }
        }
    }
} catch {
    Write-Host "   ❌ Error during file search: $($_.Exception.Message)" -ForegroundColor Red
}

# Summary
Write-Host ""
Write-Host "📋 SUMMARY:" -ForegroundColor Cyan
if ($foundPaths.Count -gt 0) {
    Write-Host "   Found $($foundPaths.Count) Visual Studio installation(s):" -ForegroundColor Green
    $uniquePaths = $foundPaths | Sort-Object | Get-Unique
    for ($i = 0; $i -lt $uniquePaths.Count; $i++) {
        Write-Host "   $($i + 1). $($uniquePaths[$i])" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "🔧 WHY AUTO-DETECTION FAILED:" -ForegroundColor Yellow
    Write-Host "   The script only checked: ${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe" -ForegroundColor White
    Write-Host "   Your Visual Studio might be:" -ForegroundColor White
    Write-Host "   • Installed in a different edition (Professional/Enterprise)" -ForegroundColor White
    Write-Host "   • Installed in a different version (2019/2017)" -ForegroundColor White
    Write-Host "   • Installed in a custom location" -ForegroundColor White
    Write-Host "   • Installed as Visual Studio Code (not Visual Studio)" -ForegroundColor White
    
} else {
    Write-Host "   ❌ No Visual Studio installations found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "🤔 POSSIBLE REASONS:" -ForegroundColor Yellow
    Write-Host "   • Visual Studio is not installed" -ForegroundColor White
    Write-Host "   • Only Visual Studio Code is installed (different product)" -ForegroundColor White
    Write-Host "   • Visual Studio is installed but devenv.exe is missing" -ForegroundColor White
    Write-Host "   • Installation is corrupted" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 SOLUTIONS:" -ForegroundColor Cyan
    Write-Host "   1. Install Visual Studio Community (free): https://visualstudio.microsoft.com/vs/community/" -ForegroundColor White
    Write-Host "   2. Or use Visual Studio Code with C# extension" -ForegroundColor White
    Write-Host "   3. Or open the project manually by double-clicking RdoApp.Core.sln" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
if ($foundPaths.Count -gt 0) {
    Write-Host "   You can now open Visual Studio manually and load the solution:" -ForegroundColor White
    Write-Host "   File → Open → Project/Solution → RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.sln" -ForegroundColor White
} else {
    Write-Host "   1. Install Visual Studio Community from Microsoft" -ForegroundColor White
    Write-Host "   2. Or double-click RdoApp.Core.sln to open with default program" -ForegroundColor White
}