Write-Host "CORRIGINDO INTEGRACAO HISTORICO-LAUDO" -ForegroundColor Yellow
Write-Host ""

Write-Host "PROBLEMA IDENTIFICADO:" -ForegroundColor Red
Write-Host "- Laudo salva na tabela 'laudo'" -ForegroundColor White
Write-Host "- Historico le da tabela 'tarefa'" -ForegroundColor White
Write-Host "- Tabela 'tarefa' nao tem dados do laudo" -ForegroundColor White
Write-Host "- Por isso aparecem tracos (-)" -ForegroundColor White
Write-Host ""

Write-Host "SOLUCAO:" -ForegroundColor Green
Write-Host "Modificar HistoricoTarefaViewModel para:" -ForegroundColor White
Write-Host "1. Fazer JOIN entre tarefa e laudo" -ForegroundColor White
Write-Host "2. Buscar dados do laudo por obra+data" -ForegroundColor White
Write-Host "3. Converter bit(1) para Sim/Nao" -ForegroundColor White
Write-Host "4. Manter compatibilidade com codigo existente" -ForegroundColor White
Write-Host ""

Write-Host "IMPLEMENTANDO CORRECAO..." -ForegroundColor Cyan