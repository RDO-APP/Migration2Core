# Simple Logo Path Fix Test
Write-Host "Testing Blazor Logo Path Fix..." -ForegroundColor Cyan

# Check files exist
$logoExists = Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/images/logo.jpg"
$userExists = Test-Path "RDO-NET8-Migration/RdoApp.Core/wwwroot/Assets/images/user.png"

Write-Host "Logo file exists: $logoExists" -ForegroundColor $(if($logoExists){"Green"}else{"Red"})
Write-Host "User image exists: $userExists" -ForegroundColor $(if($userExists){"Green"}else{"Red"})

# Check for tilde paths in components
$components = @(
    "RDO-NET8-Migration/RdoApp.Core/Components/LoginPage.razor",
    "RDO-NET8-Migration/RdoApp.Core/Components/HeaderEscolher.razor",
    "RDO-NET8-Migration/RdoApp.Core/Components/HeaderEtapaTarefa.razor"
)

foreach ($component in $components) {
    if (Test-Path $component) {
        $content = Get-Content $component -Raw
        $tildeCount = ([regex]::Matches($content, "~/")).Count
        $componentName = Split-Path $component -Leaf
        
        if ($tildeCount -eq 0) {
            Write-Host "${componentName}: No tilde paths (GOOD)" -ForegroundColor Green
        } else {
            Write-Host "${componentName}: $tildeCount tilde paths found (NEEDS FIX)" -ForegroundColor Red
        }
    }
}

# Test build
Write-Host "`nTesting build..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"
$buildOutput = dotnet build --configuration Release 2>&1
$buildSuccess = $LASTEXITCODE -eq 0

if ($buildSuccess) {
    Write-Host "Build: SUCCESS" -ForegroundColor Green
} else {
    Write-Host "Build: FAILED" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Gray
}

Set-Location "../.."

Write-Host "`nLogo path fix test completed!" -ForegroundColor Cyan