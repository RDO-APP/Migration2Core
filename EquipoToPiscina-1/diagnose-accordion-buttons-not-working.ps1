# ACCORDION BUTTONS NOT WORKING - DIAGNOSTIC SCRIPT
# This script helps diagnose why accordion buttons are not expanding/collapsing

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   ACCORDION BUTTONS DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "BASED ON YOUR F12 CONSOLE OUTPUT:" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Bootstrap 5 loaded successfully" -ForegroundColor Green
Write-Host "✅ Bootstrap compatibility layer applied" -ForegroundColor Green
Write-Host "✅ Found 6 collapse elements" -ForegroundColor Green
Write-Host "✅ Initialized collapse for all elements" -ForegroundColor Green
Write-Host "✅ Found 7 toggle buttons" -ForegroundColor Green
Write-Host "✅ Accordion button clicked: 3 Target: #collapse-etapa-880" -ForegroundColor Green
Write-Host ""

Write-Host "PROBLEM ANALYSIS:" -ForegroundColor Red
Write-Host ""
Write-Host "The console shows that:" -ForegroundColor White
Write-Host "1. Bootstrap 5 is loaded" -ForegroundColor Gray
Write-Host "2. Collapse elements are initialized" -ForegroundColor Gray
Write-Host "3. Button click is detected" -ForegroundColor Gray
Write-Host "4. BUT... the accordion is NOT expanding" -ForegroundColor Red
Write-Host ""

Write-Host "POSSIBLE CAUSES:" -ForegroundColor Yellow
Write-Host ""
Write-Host "[CAUSE 1] CSS is hiding the expanded content" -ForegroundColor Cyan
Write-Host "  - The collapse might be working, but CSS is hiding it" -ForegroundColor Gray
Write-Host "  - Check for 'display: none !important' or 'height: 0' in CSS" -ForegroundColor Gray
Write-Host ""

Write-Host "[CAUSE 2] JavaScript is preventing default behavior" -ForegroundColor Cyan
Write-Host "  - Some JavaScript might be calling e.preventDefault()" -ForegroundColor Gray
Write-Host "  - Check for event handlers that stop propagation" -ForegroundColor Gray
Write-Host ""

Write-Host "[CAUSE 3] Bootstrap 5 data attributes conflict" -ForegroundColor Cyan
Write-Host "  - data-bs-toggle vs data-toggle conflict" -ForegroundColor Gray
Write-Host "  - Compatibility layer might not be working correctly" -ForegroundColor Gray
Write-Host ""

Write-Host "[CAUSE 4] Accordion parent conflict" -ForegroundColor Cyan
Write-Host "  - data-bs-parent might be pointing to wrong element" -ForegroundColor Gray
Write-Host "  - Check if #accordion element exists" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSTIC STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 1: Check if accordion is expanding but hidden by CSS" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, run this command:" -ForegroundColor White
Write-Host "  document.querySelector('#collapse-etapa-880').classList" -ForegroundColor Cyan
Write-Host ""
Write-Host "EXPECTED: Should show 'show' class when expanded" -ForegroundColor Gray
Write-Host "IF NOT: CSS is preventing expansion" -ForegroundColor Red
Write-Host ""

Write-Host "STEP 2: Check computed styles" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, run this command:" -ForegroundColor White
Write-Host "  getComputedStyle(document.querySelector('#collapse-etapa-880')).display" -ForegroundColor Cyan
Write-Host ""
Write-Host "EXPECTED: Should be 'block' when expanded" -ForegroundColor Gray
Write-Host "IF 'none': CSS is hiding it" -ForegroundColor Red
Write-Host ""

Write-Host "STEP 3: Manually trigger collapse" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, run this command:" -ForegroundColor White
Write-Host "  var collapse = new bootstrap.Collapse(document.querySelector('#collapse-etapa-880'))" -ForegroundColor Cyan
Write-Host "  collapse.show()" -ForegroundColor Cyan
Write-Host ""
Write-Host "IF THIS WORKS: Bootstrap is fine, button click handler is broken" -ForegroundColor Gray
Write-Host "IF THIS FAILS: Bootstrap Collapse is not working" -ForegroundColor Red
Write-Host ""

Write-Host "STEP 4: Check for JavaScript errors" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, look for:" -ForegroundColor White
Write-Host "  - Red error messages" -ForegroundColor Red
Write-Host "  - 'Uncaught' errors" -ForegroundColor Red
Write-Host "  - 'TypeError' or 'ReferenceError'" -ForegroundColor Red
Write-Host ""

Write-Host "STEP 5: Check button click handler" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, run this command:" -ForegroundColor White
Write-Host "  document.querySelector('[data-bs-target=\"#collapse-etapa-880\"]').onclick = function(e) {" -ForegroundColor Cyan
Write-Host "    console.log('Button clicked!', e);" -ForegroundColor Cyan
Write-Host "    console.log('Target:', e.target);" -ForegroundColor Cyan
Write-Host "    console.log('Current target:', e.currentTarget);" -ForegroundColor Cyan
Write-Host "  }" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then click the button and check console output" -ForegroundColor Gray
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   QUICK FIX ATTEMPTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "FIX 1: Force show accordion with JavaScript" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, run:" -ForegroundColor White
Write-Host "  document.querySelectorAll('.accordion-collapse').forEach(el => {" -ForegroundColor Cyan
Write-Host "    el.classList.add('show');" -ForegroundColor Cyan
Write-Host "    el.style.display = 'block';" -ForegroundColor Cyan
Write-Host "  });" -ForegroundColor Cyan
Write-Host ""
Write-Host "IF THIS SHOWS CONTENT: CSS/JavaScript is preventing expansion" -ForegroundColor Gray
Write-Host ""

Write-Host "FIX 2: Remove conflicting CSS" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, run:" -ForegroundColor White
Write-Host "  document.querySelectorAll('.accordion-collapse').forEach(el => {" -ForegroundColor Cyan
Write-Host "    el.style.cssText = 'display: block !important; height: auto !important;';" -ForegroundColor Cyan
Write-Host "  });" -ForegroundColor Cyan
Write-Host ""

Write-Host "FIX 3: Reinitialize Bootstrap Collapse" -ForegroundColor Yellow
Write-Host ""
Write-Host "In F12 Console, run:" -ForegroundColor White
Write-Host "  document.querySelectorAll('[data-bs-toggle=\"collapse\"]').forEach(btn => {" -ForegroundColor Cyan
Write-Host "    btn.addEventListener('click', function(e) {" -ForegroundColor Cyan
Write-Host "      e.preventDefault();" -ForegroundColor Cyan
Write-Host "      var target = this.getAttribute('data-bs-target');" -ForegroundColor Cyan
Write-Host "      var collapse = new bootstrap.Collapse(document.querySelector(target));" -ForegroundColor Cyan
Write-Host "      collapse.toggle();" -ForegroundColor Cyan
Write-Host "    });" -ForegroundColor Cyan
Write-Host "  });" -ForegroundColor Cyan
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Run the diagnostic steps above in F12 Console" -ForegroundColor White
Write-Host "2. Report back what you find:" -ForegroundColor White
Write-Host "   - Does manual collapse.show() work?" -ForegroundColor Gray
Write-Host "   - Are there any JavaScript errors?" -ForegroundColor Gray
Write-Host "   - Does the element have 'show' class when clicked?" -ForegroundColor Gray
Write-Host "   - What is the computed display style?" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Based on your findings, I'll provide the exact fix" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
