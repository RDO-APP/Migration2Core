# HTML SOURCE ANALYZER
# Analyzes captured HTML to determine what's actually being rendered

param(
    [string]$HtmlFile = "escolher-authenticated-source.html"
)

Write-Host "=== HTML SOURCE ANALYZER ===" -ForegroundColor Cyan
Write-Host "Analyzing HTML output to diagnose blank page issue" -ForegroundColor Yellow

if (!(Test-Path $HtmlFile)) {
    Write-Host "❌ HTML file not found: $HtmlFile" -ForegroundColor Red
    Write-Host "Please save the page source from browser as '$HtmlFile'" -ForegroundColor Yellow
    Write-Host "" -ForegroundColor White
    Write-Host "INSTRUCTIONS TO GET HTML SOURCE:" -ForegroundColor Green
    Write-Host "1. Open browser and login to the application" -ForegroundColor White
    Write-Host "2. Navigate to ESCOLHER OBRA page" -ForegroundColor White
    Write-Host "3. Right-click anywhere on page → 'View Page Source'" -ForegroundColor White
    Write-Host "4. Copy all HTML content (Ctrl+A, Ctrl+C)" -ForegroundColor White
    Write-Host "5. Save as '$HtmlFile' in this directory" -ForegroundColor White
    Write-Host "6. Run this script again" -ForegroundColor White
    return
}

Write-Host "✅ Found HTML file: $HtmlFile" -ForegroundColor Green

# Read the HTML content
$htmlContent = Get-Content $HtmlFile -Raw -Encoding UTF8
$contentLength = $htmlContent.Length

Write-Host "`n📊 BASIC ANALYSIS:" -ForegroundColor Green
Write-Host "   File Size: $contentLength characters" -ForegroundColor Gray

if ($contentLength -lt 500) {
    Write-Host "   ⚠️  VERY SHORT HTML - Likely a redirect or error page" -ForegroundColor Red
} elseif ($contentLength -lt 2000) {
    Write-Host "   ⚠️  SHORT HTML - Possible minimal page or error" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ Substantial HTML content" -ForegroundColor Green
}

# Check for basic HTML structure
Write-Host "`n🏗️  HTML STRUCTURE ANALYSIS:" -ForegroundColor Green

$checks = @{
    "DOCTYPE" = $htmlContent -match "<!DOCTYPE"
    "HTML Tag" = $htmlContent -match "<html"
    "HEAD Section" = $htmlContent -match "<head"
    "BODY Section" = $htmlContent -match "<body"
    "Title Tag" = $htmlContent -match "<title"
}

foreach ($check in $checks.GetEnumerator()) {
    if ($check.Value) {
        Write-Host "   ✅ $($check.Key)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $($check.Key) MISSING" -ForegroundColor Red
    }
}

# Check for layout identification
Write-Host "`n📋 LAYOUT ANALYSIS:" -ForegroundColor Green

if ($htmlContent -match "LAYOUT IDENTIFICATION.*_LayoutSelection") {
    Write-Host "   ✅ Using _LayoutSelection.cshtml (CORRECT)" -ForegroundColor Green
} elseif ($htmlContent -match "_Layout") {
    Write-Host "   ⚠️  Using different layout (check which one)" -ForegroundColor Yellow
} else {
    Write-Host "   ❌ No layout identification found" -ForegroundColor Red
}

# Check for debug message
Write-Host "`n🐛 DEBUG MESSAGE ANALYSIS:" -ForegroundColor Green

if ($htmlContent -match "Found.*obras.*in Model") {
    Write-Host "   ✅ DEBUG MESSAGE FOUND - Controller is working!" -ForegroundColor Green
    
    # Extract the exact message
    if ($htmlContent -match "Found (\d+) obras in Model") {
        $obraCount = $matches[1]
        Write-Host "   📊 Obra Count: $obraCount" -ForegroundColor Cyan
    }
} else {
    Write-Host "   ❌ DEBUG MESSAGE NOT FOUND - Controller or view issue" -ForegroundColor Red
}

# Check for error messages
Write-Host "`n❌ ERROR MESSAGE ANALYSIS:" -ForegroundColor Green

$errorPatterns = @(
    "Model is NULL",
    "error",
    "exception",
    "500",
    "404",
    "unauthorized"
)

$foundErrors = @()
foreach ($pattern in $errorPatterns) {
    if ($htmlContent -match $pattern) {
        $foundErrors += $pattern
    }
}

if ($foundErrors.Count -gt 0) {
    Write-Host "   ⚠️  Found error indicators: $($foundErrors -join ', ')" -ForegroundColor Red
} else {
    Write-Host "   ✅ No obvious error messages found" -ForegroundColor Green
}

# Check for Blazor component markup
Write-Host "`n🔧 BLAZOR COMPONENT ANALYSIS:" -ForegroundColor Green

$blazorChecks = @{
    "Component Container" = $htmlContent -match "rdo-obra-cards-container"
    "Filters Section" = $htmlContent -match "rdo-filters-section"
    "Obra Grid" = $htmlContent -match "rdo-obra-grid"
    "Lista Obras" = $htmlContent -match "lista-obras"
    "Blazor Server Script" = $htmlContent -match "blazor\.server\.js"
    "Component Tag" = $htmlContent -match "<component"
}

foreach ($check in $blazorChecks.GetEnumerator()) {
    if ($check.Value) {
        Write-Host "   ✅ $($check.Key)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $($check.Key) MISSING" -ForegroundColor Red
    }
}

# Check for CSS files
Write-Host "`n🎨 CSS ANALYSIS:" -ForegroundColor Green

$cssFiles = @{
    "Fontello CSS" = $htmlContent -match "fontello\.css"
    "Unified Theme CSS" = $htmlContent -match "rdo-unified-theme\.css"
    "Site CSS" = $htmlContent -match "site\.css"
    "Blazor Styles" = $htmlContent -match "RdoApp\.Core\.styles\.css"
    "Font Awesome" = $htmlContent -match "font-awesome"
}

foreach ($css in $cssFiles.GetEnumerator()) {
    if ($css.Value) {
        Write-Host "   ✅ $($css.Key)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $($css.Key) MISSING" -ForegroundColor Red
    }
}

# Check for JavaScript
Write-Host "`n📜 JAVASCRIPT ANALYSIS:" -ForegroundColor Green

$jsChecks = @{
    "RDO Obra Cards JS" = $htmlContent -match "rdoObraCards"
    "Submit Function" = $htmlContent -match "submitObraSelection"
    "Blazor Server Script" = $htmlContent -match "_framework/blazor\.server\.js"
}

foreach ($js in $jsChecks.GetEnumerator()) {
    if ($js.Value) {
        Write-Host "   ✅ $($js.Key)" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $($js.Key) MISSING" -ForegroundColor Red
    }
}

# Extract and analyze the main content area
Write-Host "`n📄 MAIN CONTENT ANALYSIS:" -ForegroundColor Green

if ($htmlContent -match '<main[^>]*class="conteudo"[^>]*>(.*?)</main>') {
    $mainContent = $matches[1]
    $mainContentLength = $mainContent.Length
    
    Write-Host "   📊 Main Content Length: $mainContentLength characters" -ForegroundColor Gray
    
    if ($mainContentLength -lt 50) {
        Write-Host "   ❌ MAIN CONTENT IS EMPTY OR VERY SHORT" -ForegroundColor Red
        Write-Host "   🔍 Content: '$($mainContent.Trim())'" -ForegroundColor Yellow
    } elseif ($mainContent -match "Found.*obras") {
        Write-Host "   ✅ Main content contains debug message" -ForegroundColor Green
        if ($mainContent -match "rdo-obra-cards-container") {
            Write-Host "   ✅ Main content contains component markup" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Main content missing component markup" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  Main content exists but no debug message" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ Could not find main content area" -ForegroundColor Red
}

# Generate diagnosis
Write-Host "`n🔬 DIAGNOSIS:" -ForegroundColor Cyan

if ($htmlContent -match "Found.*obras.*in Model" -and $htmlContent -match "rdo-obra-cards-container") {
    Write-Host "   ✅ CONTROLLER AND VIEW WORKING - Component markup present" -ForegroundColor Green
    Write-Host "   🎯 LIKELY CAUSE: CSS loading failure or component styling issue" -ForegroundColor Yellow
    Write-Host "   🔧 CHECK: F12 Network tab for CSS 404 errors" -ForegroundColor Cyan
} elseif ($htmlContent -match "Found.*obras.*in Model") {
    Write-Host "   ⚠️  CONTROLLER WORKING - View partially working" -ForegroundColor Yellow
    Write-Host "   🎯 LIKELY CAUSE: Blazor component not rendering" -ForegroundColor Yellow
    Write-Host "   🔧 CHECK: Component parameter binding or initialization failure" -ForegroundColor Cyan
} elseif ($htmlContent -match "login|Login|unauthorized") {
    Write-Host "   🔄 REDIRECTED TO LOGIN - Authentication issue" -ForegroundColor Yellow
    Write-Host "   🔧 CHECK: Login with correct credentials first" -ForegroundColor Cyan
} elseif ($contentLength -lt 1000) {
    Write-Host "   ❌ MINIMAL HTML - Server or routing issue" -ForegroundColor Red
    Write-Host "   🔧 CHECK: Server logs and routing configuration" -ForegroundColor Cyan
} else {
    Write-Host "   ❓ UNCLEAR - Need more investigation" -ForegroundColor Yellow
    Write-Host "   🔧 CHECK: F12 Console for JavaScript errors" -ForegroundColor Cyan
}

# Save analysis report
$analysisReport = @"
# HTML SOURCE ANALYSIS REPORT
Generated: $(Get-Date)
File: $HtmlFile
Size: $contentLength characters

## Key Findings
- Debug Message: $(if ($htmlContent -match "Found.*obras.*in Model") { "FOUND ✅" } else { "MISSING ❌" })
- Component Markup: $(if ($htmlContent -match "rdo-obra-cards-container") { "FOUND ✅" } else { "MISSING ❌" })
- Blazor Script: $(if ($htmlContent -match "blazor\.server\.js") { "FOUND ✅" } else { "MISSING ❌" })
- CSS Files: $(if ($htmlContent -match "RdoApp\.Core\.styles\.css") { "FOUND ✅" } else { "MISSING ❌" })

## Next Steps
$(if ($htmlContent -match "Found.*obras.*in Model" -and $htmlContent -match "rdo-obra-cards-container") {
"1. Check F12 Network tab for CSS loading failures
2. Verify _content/RdoApp.Core/RdoApp.Core.styles.css loads successfully
3. Check if component styles are being applied"
} elseif ($htmlContent -match "Found.*obras.*in Model") {
"1. Component not rendering - check Blazor Server connection
2. Verify component parameter binding
3. Check F12 Console for component errors"
} else {
"1. Controller or view issue - debug message missing
2. Check server logs for exceptions
3. Verify authentication and routing"
})
"@

$analysisReport | Out-File -FilePath "html-analysis-report.md" -Encoding UTF8
Write-Host "`n💾 Analysis saved to: html-analysis-report.md" -ForegroundColor Green

Write-Host "`n=== HTML ANALYSIS COMPLETE ===" -ForegroundColor Cyan