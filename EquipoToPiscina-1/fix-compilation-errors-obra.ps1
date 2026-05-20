# Fix compilation errors in obra selection functionality
Write-Host "=== CORRIGINDO ERROS DE COMPILAÇÃO - OBRA SELECTION ===" -ForegroundColor Green

Write-Host "`n1. Erros corrigidos:" -ForegroundColor Yellow
Write-Host "✅ Removido DataExecucao (não existe na entidade Tarefa)" -ForegroundColor Green
Write-Host "✅ Removido PercentualConcluido (não existe na entidade Tarefa)" -ForegroundColor Green
Write-Host "✅ Substituído por DataMedicao (existe na entidade)" -ForegroundColor Green
Write-Host "✅ Substituído por QuantidadeConstruida para progresso" -ForegroundColor Green
Write-Host "✅ Adicionado Include para Status na query" -ForegroundColor Green
Write-Host "✅ Corrigido acesso a Status.Descricao" -ForegroundColor Green

Write-Host "`n2. Compilando projeto..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration/RdoApp.Core"
dotnet build --configuration Release

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilação bem-sucedida!" -ForegroundColor Green
    
    Write-Host "`n3. Propriedades da entidade Tarefa utilizadas:" -ForegroundColor Yellow
    Write-Host "- DataInicio (DateTime)" -ForegroundColor Cyan
    Write-Host "- DataPrevisaoFim (DateTime?)" -ForegroundColor Cyan
    Write-Host "- DataMedicao (DateTime) - para data de execução" -ForegroundColor Cyan
    Write-Host "- DataFim (DateTime?) - para data final" -ForegroundColor Cyan
    Write-Host "- QuantidadeConstruida (float?) - para progresso %" -ForegroundColor Cyan
    Write-Host "- Status.Descricao (string?) - para status da tarefa" -ForegroundColor Cyan
    
    Write-Host "`n4. Para testar:" -ForegroundColor Yellow
    Write-Host "- Pressione F5 no Visual Studio" -ForegroundColor Cyan
    Write-Host "- Login: CPF 567.065.455-20, Senha RXL8DjdYj6Y=" -ForegroundColor Cyan
    Write-Host "- Veja obras reais (5 por linha)" -ForegroundColor Cyan
    Write-Host "- Clique em uma obra para ver etapas/tarefas reais" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Ainda há erros de compilação!" -ForegroundColor Red
    Write-Host "Verifique os erros acima." -ForegroundColor Yellow
}

Set-Location "../.."
Write-Host "`n=== CORREÇÃO CONCLUÍDA ===" -ForegroundColor Green