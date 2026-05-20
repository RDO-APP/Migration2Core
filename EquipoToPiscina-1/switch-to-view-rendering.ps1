# Switch from ContentResult to View Rendering
# Use this AFTER confirming ContentResult works
# This will restore normal View rendering with hot-reload disabled

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SWITCH TO VIEW RENDERING" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will modify ObraController.cs to use View rendering" -ForegroundColor Yellow
Write-Host "instead of ContentResult." -ForegroundColor Yellow
Write-Host ""
Write-Host "Prerequisites:" -ForegroundColor Yellow
Write-Host "  1. ContentResult test passed (blue screen visible)" -ForegroundColor White
Write-Host "  2. December 2025 backup restored with model type fix" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Modifying ObraController.cs..." -ForegroundColor Yellow

$controllerFile = "RDO-NET8-Migration\RdoApp.Core\Controllers\ObraController.cs"

if (-not (Test-Path $controllerFile)) {
    Write-Host "✗ Controller file not found" -ForegroundColor Red
    exit 1
}

# Read controller content
$content = Get-Content $controllerFile -Raw

# Replace ContentResult approach with View rendering
$oldPattern = @'
                // CRITICAL FIX: Return ContentResult to bypass Blazor middleware
                // This proves the controller works and middleware is the blocker
                var html = @"<!DOCTYPE html>
<html>
<head>
    <title>MOTOR TEST - ContentResult</title>
    <style>
        body {
            background: #0066FF;
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            font-family: Arial, sans-serif;
        }
        .container {
            text-align: center;
            color: white;
        }
        h1 {
            font-size: 72px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
            margin-bottom: 20px;
        }
        .info {
            font-size: 24px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class='container'>
        <h1>✅ MOTOR IS RUNNING</h1>
        <div class='info'>Controller: Working</div>
        <div class='info'>Service: Working</div>
        <div class='info'>Obras Loaded: " + obrasList.Count + @"</div>
        <div class='info'>User: " + userName + @"</div>
        <div class='info'>Method: ContentResult (bypasses middleware)</div>
    </div>
</body>
</html>";
                
                _logger.LogInformation("=== RETURNING CONTENTRESULT ===");
                return Content(html, "text/html");
'@

$newPattern = @'
                // CRITICAL: Set selection mode flag for layout
                ViewBag.IsObraSelection = true;
                ViewBag.CurrentObra = null; // No obra selected yet
                
                ViewBag.UsuarioNome = userName;
                ViewBag.FiltroUnidade = filtroUnidade;
                ViewBag.FiltroMunicipio = filtroMunicipio;
                
                _logger.LogInformation("=== RETURNING VIEW ===");
                return View(obrasList);
'@

if ($content -match [regex]::Escape($oldPattern)) {
    $content = $content -replace [regex]::Escape($oldPattern), $newPattern
    Set-Content $controllerFile -Value $content -NoNewline
    
    Write-Host "✓ Controller modified to use View rendering" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✅ SWITCH COMPLETE" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "IMPORTANT:" -ForegroundColor Yellow
    Write-Host "  You MUST run the server with hot-reload disabled:" -ForegroundColor White
    Write-Host ""
    Write-Host "  cd RDO-NET8-Migration\RdoApp.Core" -ForegroundColor Cyan
    Write-Host "  dotnet run --no-hot-reload" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  OR set environment variable:" -ForegroundColor White
    Write-Host "  `$env:DOTNET_WATCH_SUPPRESS_BROWSER_REFRESH='1'" -ForegroundColor Cyan
    Write-Host "  dotnet run" -ForegroundColor Cyan
    Write-Host ""
    
} else {
    Write-Host "✗ Could not find ContentResult pattern in controller" -ForegroundColor Red
    Write-Host "  The controller may have already been modified" -ForegroundColor Yellow
    Write-Host "  or the pattern has changed" -ForegroundColor Yellow
}
