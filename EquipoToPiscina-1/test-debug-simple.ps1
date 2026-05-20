#!/usr/bin/env pwsh

Write-Host "DEBUG SISTEMATICO: Etapa/Tarefa Empty Page" -ForegroundColor Yellow
Write-Host "Aplicacao rodando em: http://localhost:5031" -ForegroundColor Cyan

Write-Host "`nURLs para testar:" -ForegroundColor Cyan
Write-Host "Login: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "Obras: http://localhost:5031/Obra/Escolher" -ForegroundColor White
Write-Host "Etapas Normal: http://localhost:5031/Obra/Etapas" -ForegroundColor White
Write-Host "Etapas Debug: http://localhost:5031/Obra/EtapasDebug" -ForegroundColor White

Write-Host "`nPlano de teste:" -ForegroundColor Yellow
Write-Host "1. Faca login com: ricardo / 123456" -ForegroundColor White
Write-Host "2. Escolha uma obra" -ForegroundColor White
Write-Host "3. Acesse /Obra/EtapasDebug primeiro" -ForegroundColor White
Write-Host "4. Verifique os logs no console da aplicacao" -ForegroundColor White
Write-Host "5. Compare com /Obra/Etapas" -ForegroundColor White

Write-Host "`nLogs esperados:" -ForegroundColor Cyan
Write-Host "=== DEBUG EtapaService.ObterEtapasViewModelAsync ===" -ForegroundColor Gray
Write-Host "ObraId recebido: X" -ForegroundColor Gray
Write-Host "ColaboradorId recebido: X" -ForegroundColor Gray
Write-Host "Etapas encontradas no banco: X" -ForegroundColor Gray

# Abrir navegador
Start-Process "http://localhost:5031/Auth/Login"