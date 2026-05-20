# CORREÇÃO FINAL DO WEB.CONFIG - REMOVER TODAS AS SEÇÕES PROBLEMÁTICAS

Write-Host "🔧 LIMPEZA FINAL DO WEB.CONFIG..." -ForegroundColor Yellow

$webConfigPath = "RDO-Homolog-Test/rdoappProject/Web.config"

Write-Host "📝 Verificando seções system.codedom ativas..." -ForegroundColor Cyan

# Ler o conteúdo atual
$content = Get-Content $webConfigPath -Raw

# Verificar se ainda há seções ativas
if ($content -match '<system\.codedom>') {
    Write-Host "⚠️  AINDA HÁ SEÇÕES ATIVAS! Removendo..." -ForegroundColor Red
    
    # Remover TODAS as seções system.codedom ativas (não comentadas)
    $content = $content -replace '(?s)<system\.codedom>.*?</system\.codedom>', '<!-- system.codedom REMOVED -->'
    
    # Salvar o arquivo
    $content | Set-Content $webConfigPath -Encoding UTF8
    
    Write-Host "✅ Seções system.codedom removidas!" -ForegroundColor Green
} else {
    Write-Host "✅ Nenhuma seção system.codedom ativa encontrada!" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎯 TESTE AGORA:" -ForegroundColor Cyan
Write-Host "   1. Pressione F5 no Visual Studio" -ForegroundColor White
Write-Host "   2. A aplicação deve carregar sem erros" -ForegroundColor White
Write-Host "   3. Login: 567.065.455-20 / 1234" -ForegroundColor White

Write-Host ""
Write-Host "✅ Web.config limpo e pronto!" -ForegroundColor Green