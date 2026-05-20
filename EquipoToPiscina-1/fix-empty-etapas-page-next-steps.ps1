#!/usr/bin/env pwsh

Write-Host "🔍 Fix: Página Etapas/Tarefas Vazia - Próximos Passos" -ForegroundColor Yellow
Write-Host "=" * 70

Write-Host "`n📋 ANÁLISE COMPLETA CRIADA:" -ForegroundColor Cyan
Write-Host "Arquivo: ETAPA-TAREFA-EMPTY-PAGE-ANALYSIS.md" -ForegroundColor Green

Write-Host "`n🎯 PRÓXIMOS PASSOS OBRIGATÓRIOS:" -ForegroundColor Cyan

Write-Host "`n1️⃣ VERIFICAR DADOS NO BANCO (CRÍTICO)" -ForegroundColor Yellow
Write-Host "   Execute no DBeaver: investigate-empty-etapas-page.sql" -ForegroundColor White
Write-Host "   Verifique se há etapas para obra 1" -ForegroundColor White

Write-Host "`n2️⃣ PARAR PROCESSO ATUAL" -ForegroundColor Yellow
Write-Host "   Feche o Visual Studio ou aplicação em execução" -ForegroundColor White
Write-Host "   Ou execute: taskkill /F /IM RdoApp.Core.exe" -ForegroundColor White

Write-Host "`n3️⃣ EXECUTAR COM DEBUG LOGS" -ForegroundColor Yellow
Write-Host "   cd RDO-NET8-Migration/RdoApp.Core" -ForegroundColor White
Write-Host "   dotnet run" -ForegroundColor White
Write-Host "   Acesse: https://localhost:7001" -ForegroundColor White
Write-Host "   Faça login e vá para Etapas/Tarefas" -ForegroundColor White
Write-Host "   Verifique logs no console" -ForegroundColor White

Write-Host "`n📊 LOGS ESPERADOS:" -ForegroundColor Cyan
Write-Host "   === INÍCIO DEBUG ETAPAS ===" -ForegroundColor Gray
Write-Host "   UserIdClaim: [valor]" -ForegroundColor Gray
Write-Host "   ColaboradorId extraído: [número]" -ForegroundColor Gray
Write-Host "   ObraId: [número]" -ForegroundColor Gray
Write-Host "   Total de etapas no banco: [número]" -ForegroundColor Gray
Write-Host "   Etapas para obra X: [número]" -ForegroundColor Gray
Write-Host "   Resultado: [número] etapas retornadas" -ForegroundColor Gray
Write-Host "   === FIM DEBUG ETAPAS ===" -ForegroundColor Gray

Write-Host "`n🔍 POSSÍVEIS RESULTADOS:" -ForegroundColor Cyan
Write-Host "   • Se 'Total de etapas no banco: 0' → Não há dados" -ForegroundColor White
Write-Host "   • Se 'Etapas para obra X: 0' → Obra não tem etapas" -ForegroundColor White
Write-Host "   • Se 'Resultado: 0 etapas retornadas' → Problema no service" -ForegroundColor White

Write-Host "`n✅ MODIFICAÇÕES JÁ APLICADAS:" -ForegroundColor Green
Write-Host "   • Debug logs adicionados ao ObraController.Etapas()" -ForegroundColor White
Write-Host "   • Using statements adicionados" -ForegroundColor White
Write-Host "   • SQL de investigação criado" -ForegroundColor White

Write-Host "`n🎯 EXECUTE OS PASSOS ACIMA E REPORTE OS RESULTADOS!" -ForegroundColor Green