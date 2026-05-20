# ABRIR VISUAL STUDIO VIA WINDOWS RUN

Write-Host "=== ABRINDO VISUAL STUDIO VIA WINDOWS RUN ===" -ForegroundColor Yellow
Write-Host ""

Write-Host "Abrindo Windows Run (Windows + R)..." -ForegroundColor Cyan

# Abrir Windows Run
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("^{ESC}")
Start-Sleep -Milliseconds 500
[System.Windows.Forms.SendKeys]::SendWait("{LWIN}r")

Write-Host ""
Write-Host "INSTRUCOES:" -ForegroundColor Yellow
Write-Host "1. Na janela 'Executar' que abriu:" -ForegroundColor White
Write-Host "2. Digite: devenv" -ForegroundColor Cyan
Write-Host "3. Pressione: Ctrl+Shift+Enter (isso força como administrador)" -ForegroundColor Cyan
Write-Host "4. Clique 'Sim' na janela de permissao" -ForegroundColor White
Write-Host ""
Write-Host "ALTERNATIVA:" -ForegroundColor Yellow
Write-Host "Se nao funcionar, tente:" -ForegroundColor White
Write-Host "1. Digite: cmd" -ForegroundColor Cyan
Write-Host "2. Pressione: Ctrl+Shift+Enter" -ForegroundColor Cyan
Write-Host "3. No prompt que abrir, digite: devenv" -ForegroundColor Cyan
Write-Host ""