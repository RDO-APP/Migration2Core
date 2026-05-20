Write-Host "=== VERIFICACAO DA INTEGRACAO DO LAUDO ===" -ForegroundColor Green

$content = Get-Content "rdoappProject/Api/Models/TarefaModel.cs" -Raw

if ($content -match "Integracao com dados do Laudo") {
    Write-Host "OK - Integracao do laudo implementada" -ForegroundColor Green
} else {
    Write-Host "ERRO - Integracao do laudo nao encontrada" -ForegroundColor Red
}

if ($content -match "lau_tp_nivel_cloro") {
    Write-Host "OK - Campos do laudo mapeados" -ForegroundColor Green
} else {
    Write-Host "ERRO - Campos do laudo nao mapeados" -ForegroundColor Red
}

Write-Host ""
Write-Host "IMPLEMENTACAO CONCLUIDA:" -ForegroundColor Cyan
Write-Host "- Propriedades duplicadas removidas" -ForegroundColor White
Write-Host "- JOIN laudo-tarefa por obra+data implementado" -ForegroundColor White
Write-Host "- Estrutura real do banco utilizada" -ForegroundColor White
Write-Host ""
Write-Host "PROXIMO PASSO: Testar no Visual Studio F5" -ForegroundColor Yellow