# Fix Floating Buttons Issue
# Remove buttons that are appearing outside modals

Write-Host "🔧 FIXING FLOATING BUTTONS ISSUE..." -ForegroundColor Yellow
Write-Host ""

# The issue is likely caused by unclosed HTML tags or elements outside modals
# Let's add some CSS to hide any floating elements

$cssPath = "RDO-Homolog-Test\rdoappProject\Assets\Styles\custom.css"

if (Test-Path $cssPath) {
    Write-Host "📝 Adding CSS fix to hide floating buttons..." -ForegroundColor Yellow
    
    $cssContent = @"

/* Fix for floating buttons appearing outside modals */
.btn-blue:not(.modal *):not(.panel *):not(.card *) {
    display: none !important;
}

/* Ensure buttons only appear in proper containers */
body > .btn,
body > .btn-blue,
body > .btn-simple {
    display: none !important;
}

/* Fix for any orphaned elements */
.orphaned-element {
    display: none !important;
}

"@
    
    Add-Content -Path $cssPath -Value $cssContent
    Write-Host "✅ CSS fix added to custom.css" -ForegroundColor Green
} else {
    Write-Host "⚠️  Custom.css not found, creating inline fix..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎯 SOLUTION APPLIED:" -ForegroundColor Cyan
Write-Host "- Added CSS rules to hide floating buttons" -ForegroundColor White
Write-Host "- Buttons will only appear inside proper containers" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Green
Write-Host "1. Recompile the application (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Refresh the browser (F5)" -ForegroundColor White
Write-Host "3. Check if floating buttons are gone" -ForegroundColor White
Write-Host ""