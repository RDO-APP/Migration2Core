# SIMPLE HTML ANALYZER
param([string]$HtmlFile = "escolher-authenticated-source.html")

Write-Host "=== HTML ANALYSIS ===" -ForegroundColor Cyan

if (!(Test-Path $HtmlFile)) {
    Write-Host "❌ File not found: $HtmlFile" -ForegroundColor Red
    Write-Host "Please save the authenticated page source as '$HtmlFile'" -ForegroundColor Yellow
    return
}

$html = Get-Content $HtmlFile -Raw -Encoding UTF8
$length = $html.Length

Write-Host "📊 File: $HtmlFile" -ForegroundColor Green
Write-Host "📊 Size: $length characters" -ForegroundColor Gray

# Key checks
Write-Host "`n🔍 KEY CHECKS:" -ForegroundColor Green

# Debug message
if ($html -match "Found.*obras.*in Model") {
    Write-Host "✅ DEBUG MESSAGE FOUND - Controller working!" -ForegroundColor Green
    if ($html -match "Found (\d+) obras in Model") {
        Write-Host "   📊 Obra count: $($matches[1])" -ForegroundColor Cyan
    }
} else {
    Write-Host "❌ DEBUG MESSAGE NOT FOUND" -ForegroundColor Red
}

# Component container
if ($html -match "rdo-obra-cards-container") {
    Write-Host "✅ COMPONENT CONTAINER FOUND" -ForegroundColor Green
} else {
    Write-Host "❌ COMPONENT CONTAINER MISSING" -ForegroundColor Red
}

# Obra grid
if ($html -match "lista-obras") {
    Write-Host "✅ OBRA GRID FOUND" -ForegroundColor Green
} else {
    Write-Host "❌ OBRA GRID MISSING" -ForegroundColor Red
}

# CSS files
if ($html -match "RdoApp\.Core\.styles\.css") {
    Write-Host "✅ BLAZOR CSS BUNDLE FOUND" -ForegroundColor Green
} else {
    Write-Host "❌ BLAZOR CSS BUNDLE MISSING" -ForegroundColor Red
}

# Blazor script
if ($html -match "blazor\.server\.js") {
    Write-Host "✅ BLAZOR SERVER SCRIPT FOUND" -ForegroundColor Green
} else {
    Write-Host "❌ BLAZOR SERVER SCRIPT MISSING" -ForegroundColor Red
}

# Main content
if ($html -match '<main[^>]*class="conteudo"[^>]*>(.*?)</main>') {
    $mainContent = $matches[1]
    $mainLength = $mainContent.Length
    Write-Host "✅ MAIN CONTENT FOUND ($mainLength chars)" -ForegroundColor Green
    
    if ($mainLength -lt 100) {
        Write-Host "   ⚠️ MAIN CONTENT IS VERY SHORT" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ MAIN CONTENT AREA NOT FOUND" -ForegroundColor Red
}

Write-Host "`n=== ANALYSIS COMPLETE ===" -ForegroundColor Cyan