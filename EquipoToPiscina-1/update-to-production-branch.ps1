# ATUALIZAR PARA BRANCH DE PRODUÇÃO (GILBERTO)

Write-Host "🔄 ATUALIZANDO PARA CÓDIGO DE PRODUÇÃO..." -ForegroundColor Yellow

# Verificar se temos acesso ao repositório
$repoUrl = "https://github.com/LucioRDOApp/EquipoToPiscina.git"
$branchName = "gilberto"

Write-Host "📥 Clonando branch de produção: $branchName" -ForegroundColor Cyan

# Criar pasta para código de produção
$productionPath = "RDO-Production-Gilberto"

if (Test-Path $productionPath) {
    Write-Host "⚠️  Pasta $productionPath já existe. Removendo..." -ForegroundColor Yellow
    Remove-Item $productionPath -Recurse -Force
}

# Clonar apenas a branch específica
Write-Host "📦 Clonando repositório..." -ForegroundColor Cyan
git clone -b $branchName $repoUrl $productionPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Código de produção clonado com sucesso!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
    Write-Host "1. Comparar interface moderna da branch gilberto" -ForegroundColor White
    Write-Host "2. Aplicar correções Entity Framework no código de produção" -ForegroundColor White
    Write-Host "3. Testar ambiente de homolog com código atual" -ForegroundColor White
    Write-Host "4. Aplicar melhorias na produção" -ForegroundColor White
    
    Write-Host ""
    Write-Host "📁 Código de produção em: $productionPath" -ForegroundColor Green
} else {
    Write-Host "❌ Erro ao clonar repositório!" -ForegroundColor Red
    Write-Host "Verifique:" -ForegroundColor Yellow
    Write-Host "- Acesso ao repositório" -ForegroundColor White
    Write-Host "- Conexão com internet" -ForegroundColor White
    Write-Host "- Permissões do Git" -ForegroundColor White
}

Write-Host ""
Write-Host "🎯 ESTRATÉGIA RECOMENDADA:" -ForegroundColor Green
Write-Host "1. PRIMEIRO: Teste o Web.config limpo no código atual" -ForegroundColor White
Write-Host "2. DEPOIS: Compare com código de produção (branch gilberto)" -ForegroundColor White
Write-Host "3. ENTÃO: Aplique correções no código de produção" -ForegroundColor White