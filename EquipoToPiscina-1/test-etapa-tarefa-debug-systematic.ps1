#!/usr/bin/env pwsh

Write-Host "🔍 TESTE SISTEMÁTICO: Etapa/Tarefa Empty Page" -ForegroundColor Yellow
Write-Host "Seguindo o plano de 4 pontos específicos" -ForegroundColor Yellow
Write-Host "=" * 70

Write-Host "`n📋 APLICAÇÃO RODANDO EM: http://localhost:5031" -ForegroundColor Cyan

Write-Host "`n🎯 PLANO DE TESTE SISTEMÁTICO:" -ForegroundColor Cyan

Write-Host "`n1️⃣ VERIFICAR OBRAIDNO MÉTODO ESCOLHER" -ForegroundColor Yellow
Write-Host "   • Acesse: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "   • Faça login com: ricardo / 123456" -ForegroundColor White
Write-Host "   • Escolha uma obra" -ForegroundColor White
Write-Host "   • Verifique logs no console: 'ObraId X salvo na sessão'" -ForegroundColor White

Write-Host "`n2️⃣ VERIFICAR FILTRO POR COLABORADORID" -ForegroundColor Yellow
Write-Host "   • Acesse: http://localhost:5031/Obra/EtapasDebug" -ForegroundColor White
Write-Host "   • Verifique logs do EtapaService no console:" -ForegroundColor White
Write-Host "     - 'ColaboradorId recebido: X'" -ForegroundColor Gray
Write-Host "     - 'Etapas encontradas no banco: X'" -ForegroundColor Gray
Write-Host "     - 'Tarefas APÓS filtro por colaborador: X'" -ForegroundColor Gray

Write-Host "`n3️⃣ VERIFICAR INCLUDE DAS TAREFAS" -ForegroundColor Yellow
Write-Host "   • Já verificado - está correto no código" -ForegroundColor White

Write-Host "`n4️⃣ VERIFICAR ÍCONES DE STATUS" -ForegroundColor Yellow
Write-Host "   • Compare http://localhost:5031/Obra/Etapas (versão normal)" -ForegroundColor White
Write-Host "   • Com http://localhost:5031/Obra/EtapasDebug (versão simplificada)" -ForegroundColor White
Write-Host "   • Se EtapasDebug funcionar e Etapas não = problema nos ícones" -ForegroundColor White

Write-Host "`n🌐 URLS PARA TESTAR:" -ForegroundColor Cyan
Write-Host "• Login: http://localhost:5031/Auth/Login" -ForegroundColor White
Write-Host "• Obras: http://localhost:5031/Obra/Escolher" -ForegroundColor White
Write-Host "• Etapas Normal: http://localhost:5031/Obra/Etapas" -ForegroundColor White
Write-Host "• Etapas Debug: http://localhost:5031/Obra/EtapasDebug" -ForegroundColor White

Write-Host "`n📊 LOGS ESPERADOS (Console):" -ForegroundColor Cyan
Write-Host "=== DEBUG EtapaService.ObterEtapasViewModelAsync ===" -ForegroundColor Gray
Write-Host "ObraId recebido: 1" -ForegroundColor Gray
Write-Host "ColaboradorId recebido: 123" -ForegroundColor Gray
Write-Host "Etapas encontradas no banco: 5" -ForegroundColor Gray
Write-Host "=== RESULTADO FINAL: 5 etapas no ViewModel ===" -ForegroundColor Gray

Write-Host "`n🔍 POSSÍVEIS RESULTADOS:" -ForegroundColor Cyan
Write-Host "• Se 'Etapas encontradas no banco: 0' - Nao ha dados" -ForegroundColor White
Write-Host "• Se 'Tarefas APOS filtro: 0' - Filtro colaborador eliminando tudo" -ForegroundColor White
Write-Host "• Se EtapasDebug funciona mas Etapas nao - Problema nos icones" -ForegroundColor White
Write-Host "• Se ambos nao funcionam - Problema no service/controller" -ForegroundColor White

Write-Host "`n🎯 ABRA O NAVEGADOR E TESTE AS URLS ACIMA!" -ForegroundColor Green
Write-Host "Monitore os logs no console onde a aplicação está rodando." -ForegroundColor Green

# Abrir navegador automaticamente
Start-Process "http://localhost:5031/Auth/Login"