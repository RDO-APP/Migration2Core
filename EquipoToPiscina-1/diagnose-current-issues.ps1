#!/usr/bin/env pwsh
# DIAGNOSTIC SCRIPT: Check current status of hand icons and routing

Write-Host "🔍 DIAGNOSTIC: Current Issues Analysis" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$projectPath = "RDO-NET8-Migration/RdoApp.Core"

# Check 1: Verify project structure
Write-Host "`n📁 CHECK 1: Project Structure" -ForegroundColor Yellow
if (Test-Path $projectPath) {
    Write-Host "✅ Project path exists: $projectPath" -ForegroundColor Green
} else {
    Write-Host "❌ Project path NOT found: $projectPath" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Gray
    exit 1
}

# Check 2: Critical files existence
Write-Host "`n📄 CHECK 2: Critical Files" -ForegroundColor Yellow

$files = @{
    "_TaskCardPartial.cshtml" = "Views/Etapa/_TaskCardPartial.cshtml"
    "AccountController.cs" = "Controllers/AccountController.cs"
    "Program.cs" = "Program.cs"
    "EtapaController.cs" = "Controllers/EtapaController.cs"
    "TestCards.cshtml" = "Views/Etapa/TestCards.cshtml"
}

foreach ($name in $files.Keys) {
    $path = Join-Path $projectPath $files[$name]
    if (Test-Path $path) {
        $lastWrite = (Get-Item $path).LastWriteTime
        Write-Host "✅ $name exists (Modified: $lastWrite)" -ForegroundColor Green
    } else {
        Write-Host "❌ $name NOT found: $path" -ForegroundColor Red
    }
}

# Check 3: Hand icons implementation
Write-Host "`n👋 CHECK 3: Hand Icons Implementation" -ForegroundColor Yellow

$taskCardPath = Join-Path $projectPath "Views/Etapa/_TaskCardPartial.cshtml"
if (Test-Path $taskCardPath) {
    $content = Get-Content $taskCardPath -Raw
    
    # Check for hand icon switch statement
    if ($content -match "@switch \(Model\.StatusId\)") {
        Write-Host "✅ @switch statement found" -ForegroundColor Green
    } else {
        Write-Host "❌ @switch statement NOT found" -ForegroundColor Red
    }
    
    # Check for specific hand icons
    $handIcons = @(
        "fa-hand-paper-o",
        "fa-hand-rock-o", 
        "fa-hand-peace-o",
        "fa-hand-stop-o",
        "fa-hand-scissors-o"
    )
    
    foreach ($icon in $handIcons) {
        if ($content -match $icon) {
            Write-Host "✅ $icon found" -ForegroundColor Green
        } else {
            Write-Host "❌ $icon NOT found" -ForegroundColor Red
        }
    }
    
    # Check for old status bar (should NOT exist)
    if ($content -match '<div class="status">') {
        Write-Host "⚠️ Old status bar still exists (should be removed)" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Old status bar not found (good)" -ForegroundColor Green
    }
    
} else {
    Write-Host "❌ _TaskCardPartial.cshtml not found" -ForegroundColor Red
}

# Check 4: Routing middleware
Write-Host "`n🛣️ CHECK 4: Routing Middleware" -ForegroundColor Yellow

$programPath = Join-Path $projectPath "Program.cs"
if (Test-Path $programPath) {
    $content = Get-Content $programPath -Raw
    
    # Check for force redirect middleware
    if ($content -match "Force redirect to new AccountController") {
        Write-Host "✅ Force redirect middleware found" -ForegroundColor Green
    } else {
        Write-Host "❌ Force redirect middleware NOT found" -ForegroundColor Red
    }
    
    # Check for custom cookie name
    if ($content -match 'Cookie.Name = "RdoApp.Auth"') {
        Write-Host "✅ Custom cookie name found" -ForegroundColor Green
    } else {
        Write-Host "❌ Custom cookie name NOT found" -ForegroundColor Red
    }
    
    # Check for AccountController routing
    if ($content -match 'controller = "Account"') {
        Write-Host "✅ AccountController routing found" -ForegroundColor Green
    } else {
        Write-Host "❌ AccountController routing NOT found" -ForegroundColor Red
    }
    
} else {
    Write-Host "❌ Program.cs not found" -ForegroundColor Red
}

# Check 5: Test endpoint
Write-Host "`n🧪 CHECK 5: Test Endpoint" -ForegroundColor Yellow

$etapaControllerPath = Join-Path $projectPath "Controllers/EtapaController.cs"
if (Test-Path $etapaControllerPath) {
    $content = Get-Content $etapaControllerPath -Raw
    
    if ($content -match 'Route\("etapa/test"\)') {
        Write-Host "✅ Test endpoint found (/etapa/test)" -ForegroundColor Green
    } else {
        Write-Host "❌ Test endpoint NOT found" -ForegroundColor Red
    }
    
    if ($content -match "TestCards") {
        Write-Host "✅ TestCards action found" -ForegroundColor Green
    } else {
        Write-Host "❌ TestCards action NOT found" -ForegroundColor Red
    }
} else {
    Write-Host "❌ EtapaController.cs not found" -ForegroundColor Red
}

# Check 6: Compilation status
Write-Host "`n🔨 CHECK 6: Compilation Status" -ForegroundColor Yellow

$binPath = Join-Path $projectPath "bin"
$objPath = Join-Path $projectPath "obj"

if (Test-Path $binPath) {
    Write-Host "⚠️ bin folder exists (may contain old compiled views)" -ForegroundColor Yellow
    $binSize = (Get-ChildItem $binPath -Recurse | Measure-Object -Property Length -Sum).Sum
    Write-Host "   Size: $([math]::Round($binSize/1MB, 2)) MB" -ForegroundColor Gray
} else {
    Write-Host "✅ bin folder not found (good for fresh compile)" -ForegroundColor Green
}

if (Test-Path $objPath) {
    Write-Host "⚠️ obj folder exists (may contain old compiled views)" -ForegroundColor Yellow
    $objSize = (Get-ChildItem $objPath -Recurse | Measure-Object -Property Length -Sum).Sum
    Write-Host "   Size: $([math]::Round($objSize/1MB, 2)) MB" -ForegroundColor Gray
} else {
    Write-Host "✅ obj folder not found (good for fresh compile)" -ForegroundColor Green
}

# Check 7: Running processes
Write-Host "`n🏃 CHECK 7: Running Processes" -ForegroundColor Yellow

$processes = @("iisexpress", "dotnet", "RdoApp")
foreach ($proc in $processes) {
    $running = Get-Process -Name "*$proc*" -ErrorAction SilentlyContinue
    if ($running) {
        Write-Host "⚠️ $proc processes running: $($running.Count)" -ForegroundColor Yellow
        foreach ($p in $running) {
            Write-Host "   PID: $($p.Id), Name: $($p.ProcessName)" -ForegroundColor Gray
        }
    } else {
        Write-Host "✅ No $proc processes running" -ForegroundColor Green
    }
}

# Summary and recommendations
Write-Host "`n📋 SUMMARY & RECOMMENDATIONS" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

Write-Host "`n🎯 LIKELY ISSUES:" -ForegroundColor Yellow
Write-Host "1. View compilation cache (bin/obj folders exist)" -ForegroundColor White
Write-Host "2. Browser cache (old sessions/cookies)" -ForegroundColor White
Write-Host "3. Wrong URL (accessing AngularJS instead of Razor)" -ForegroundColor White
Write-Host "4. FontAwesome CSS not loaded" -ForegroundColor White

Write-Host "`n🔧 RECOMMENDED ACTIONS:" -ForegroundColor Yellow
Write-Host "1. Run: .\fix-hand-icons-and-routing-complete.ps1" -ForegroundColor White
Write-Host "2. Use INCOGNITO browser mode" -ForegroundColor White
Write-Host "3. Navigate to: https://localhost:7201/etapa/test" -ForegroundColor White
Write-Host "4. Check browser console (F12) for errors" -ForegroundColor White

Write-Host "`n🚨 CRITICAL URLS TO TEST:" -ForegroundColor Red
Write-Host "- Root: https://localhost:7201/ (should redirect to /Account/Login)" -ForegroundColor White
Write-Host "- Login: https://localhost:7201/Account/Login (new Razor login)" -ForegroundColor White
Write-Host "- Test: https://localhost:7201/etapa/test (hand icons test)" -ForegroundColor White
Write-Host "- Cards: https://localhost:7201/Etapa/Cards (main cards view)" -ForegroundColor White

Write-Host "`nDiagnostic completed!" -ForegroundColor Cyan