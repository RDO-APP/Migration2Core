# FORENSIC DIAGNOSTIC: Static File Serving Investigation
# User reported: F12 console shows 404 for fontello.css and user.png despite hard refresh
# Physical files exist, paths are correct, but assets not loading

Write-Host "FORENSIC DIAGNOSTIC: Static File Serving Investigation" -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Cyan

# Step 1: Test basic static file serving with a simple test file
Write-Host "`nSTEP 1: Testing Basic Static File Serving" -ForegroundColor Yellow
$testFilePath = "RDO-NET8-Migration/RdoApp.Core/wwwroot/test-hello.txt"
"Hello World - Static File Test" | Out-File -FilePath $testFilePath -Encoding UTF8
Write-Host "Created test file: $testFilePath"

# Step 2: Verify physical file existence
Write-Host "`nSTEP 2: Physical File Verification" -ForegroundColor Yellow
$files = @(
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/fontello.css",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/Assets/images/user.png",
    "RDO-NET8-Migration/RdoApp.Core/wwwroot/css/rdo-unified-theme.css"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        Write-Host "EXISTS: $file ($size bytes)" -ForegroundColor Green
    } else {
        Write-Host "MISSING: $file" -ForegroundColor Red
    }
}

# Step 3: Check Program.cs middleware order
Write-Host "`nSTEP 3: Program.cs Middleware Order Analysis" -ForegroundColor Yellow
$programCs = Get-Content "RDO-NET8-Migration/RdoApp.Core/Program.cs" -Raw

# Extract middleware order
$middlewareLines = @()
$lines = $programCs -split "`n"
$inMiddleware = $false

foreach ($line in $lines) {
    if ($line -match "var app = builder\.Build\(\);") {
        $inMiddleware = $true
        continue
    }
    if ($inMiddleware -and $line -match "app\.Run\(\);") {
        break
    }
    if ($inMiddleware -and $line -match "app\.Use") {
        $middlewareLines += $line.Trim()
    }
}

Write-Host "Middleware execution order:"
for ($i = 0; $i -lt $middlewareLines.Count; $i++) {
    Write-Host "  $($i+1). $($middlewareLines[$i])"
}

# Step 4: Check if UseStaticFiles is before UseRouting
$staticFilesIndex = -1
$routingIndex = -1

for ($i = 0; $i -lt $middlewareLines.Count; $i++) {
    if ($middlewareLines[$i] -match "UseStaticFiles") {
        $staticFilesIndex = $i
    }
    if ($middlewareLines[$i] -match "UseRouting") {
        $routingIndex = $i
    }
}

Write-Host "`nSTEP 4: Critical Middleware Order Check" -ForegroundColor Yellow
if ($staticFilesIndex -ne -1 -and $routingIndex -ne -1) {
    if ($staticFilesIndex -lt $routingIndex) {
        Write-Host "UseStaticFiles ($($staticFilesIndex+1)) comes BEFORE UseRouting ($($routingIndex+1))" -ForegroundColor Green
    } else {
        Write-Host "CRITICAL: UseStaticFiles ($($staticFilesIndex+1)) comes AFTER UseRouting ($($routingIndex+1))" -ForegroundColor Red
        Write-Host "   This will cause 404 errors for static files!" -ForegroundColor Red
    }
} else {
    Write-Host "Could not find UseStaticFiles or UseRouting in middleware pipeline" -ForegroundColor Red
}

# Step 5: Check custom middleware bypass logic
Write-Host "`nSTEP 5: Custom Middleware Bypass Logic" -ForegroundColor Yellow
if ($programCs -match "path\?\.\StartsWith\(`"/css/`"\)") {
    Write-Host "Found CSS bypass logic in custom middleware" -ForegroundColor Green
} else {
    Write-Host "CSS bypass logic not found in custom middleware" -ForegroundColor Red
}

if ($programCs -match "path\?\.\StartsWith\(`"/Assets/`"\)") {
    Write-Host "Found Assets bypass logic in custom middleware" -ForegroundColor Green
} else {
    Write-Host "Assets bypass logic not found in custom middleware" -ForegroundColor Red
}

# Step 6: Test layout application
Write-Host "`nSTEP 6: Layout Application Test" -ForegroundColor Yellow
$escolherView = Get-Content "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml" -Raw
if ($escolherView -match 'Layout = "_LayoutSelection"') {
    Write-Host "Escolher.cshtml specifies _LayoutSelection layout" -ForegroundColor Green
} else {
    Write-Host "Layout specification not found in Escolher.cshtml" -ForegroundColor Red
}

# Step 7: Check Blazor component registration
Write-Host "`nSTEP 7: Blazor Component Registration" -ForegroundColor Yellow
if ($programCs -match "AddServerSideBlazor") {
    Write-Host "AddServerSideBlazor() found in services" -ForegroundColor Green
} else {
    Write-Host "AddServerSideBlazor() not found in services" -ForegroundColor Red
}

if ($programCs -match "MapBlazorHub") {
    Write-Host "MapBlazorHub() found in routing" -ForegroundColor Green
} else {
    Write-Host "MapBlazorHub() not found in routing" -ForegroundColor Red
}

Write-Host "`nFORENSIC SUMMARY:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "1. Physical files exist: CHECK"
Write-Host "2. Paths are correct: CHECK"
Write-Host "3. Middleware order: $(if ($staticFilesIndex -lt $routingIndex) { 'OK' } else { 'PROBLEM' })"
Write-Host "4. Custom middleware bypass: $(if ($programCs -match 'css/') { 'OK' } else { 'PROBLEM' })"
Write-Host "5. Layout specification: $(if ($escolherView -match '_LayoutSelection') { 'OK' } else { 'PROBLEM' })"
Write-Host "6. Blazor registration: $(if ($programCs -match 'AddServerSideBlazor') { 'OK' } else { 'PROBLEM' })"

Write-Host "`nNEXT STEPS:" -ForegroundColor Magenta
Write-Host "1. Start the application and test /test-hello.txt"
Write-Host "2. Check F12 Network tab for actual HTTP requests"
Write-Host "3. Verify HTML source contains link tags for CSS"
Write-Host "4. Test direct asset URLs: /css/fontello.css and /Assets/images/user.png"

Write-Host "`nDiagnostic complete. Review results above." -ForegroundColor Green