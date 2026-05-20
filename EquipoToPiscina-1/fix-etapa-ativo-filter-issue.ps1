# Fix the Etapa Ativo filter issue
Write-Host "=== FIXING ETAPA ATIVO FILTER ISSUE ===" -ForegroundColor Yellow

Write-Host "The issue: DBeaver shows 4 etapas, but website shows 0" -ForegroundColor Red
Write-Host "Suspected cause: Missing or incorrect Ativo filter" -ForegroundColor Red

Write-Host ""
Write-Host "=== ANALYSIS ===" -ForegroundColor Cyan
Write-Host "1. Current EtapaService.cs does NOT have !e.Ativo filter" -ForegroundColor White
Write-Host "2. Gemini confirmed the filter exists on line 43" -ForegroundColor White
Write-Host "3. This suggests either:" -ForegroundColor White
Write-Host "   - The file was modified since Gemini read it" -ForegroundColor Gray
Write-Host "   - There are different versions of the file" -ForegroundColor Gray
Write-Host "   - The Ativo field is missing from Etapa entity" -ForegroundColor Gray

Write-Host ""
Write-Host "=== SOLUTION ===" -ForegroundColor Green
Write-Host "Since DBeaver shows etapas exist but website shows 0," -ForegroundColor White
Write-Host "the current query WITHOUT !e.Ativo filter should work." -ForegroundColor White
Write-Host ""
Write-Host "The real issue is likely in the foreach loop processing" -ForegroundColor Yellow
Write-Host "where etapasViewModel is being built." -ForegroundColor Yellow

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Run the application with debug logs" -ForegroundColor White
Write-Host "2. Check console output to see:" -ForegroundColor White
Write-Host "   - How many etapas are found in database" -ForegroundColor Gray
Write-Host "   - How many tasks each etapa has" -ForegroundColor Gray
Write-Host "   - How many tasks pass the authorization filter" -ForegroundColor Gray
Write-Host "   - Final count of etapas in ViewModel" -ForegroundColor Gray

Write-Host ""
Write-Host "Run: .\test-etapa-debug-now.ps1" -ForegroundColor Green