# CORREÇÃO DEFINITIVA DO WEB.CONFIG - IMPEDIR REGENERAÇÃO

Write-Host "🔒 CORREÇÃO DEFINITIVA DO WEB.CONFIG..." -ForegroundColor Yellow

$webConfigPath = "RDO-Homolog-Test/rdoappProject/Web.config"

Write-Host "📝 Verificando e removendo TODAS as seções system.codedom..." -ForegroundColor Cyan

# Ler conteúdo atual
$content = Get-Content $webConfigPath -Raw

# Contar quantas seções existem
$matches = [regex]::Matches($content, '<system\.codedom>')
Write-Host "🔍 Encontradas $($matches.Count) seções system.codedom" -ForegroundColor Yellow

# Remover TODAS as seções system.codedom (ativas e comentadas)
$content = $content -replace '(?s)<!--.*?<system\.codedom>.*?</system\.codedom>.*?-->', '<!-- system.codedom REMOVED -->'
$content = $content -replace '(?s)<system\.codedom>.*?</system\.codedom>', '<!-- system.codedom REMOVED -->'

# Adicionar comentário de proteção
$protectionComment = @"

  <!-- ============================================ -->
  <!-- ATENÇÃO: NÃO ADICIONE system.codedom AQUI! -->
  <!-- Esta seção causa erros de CodeDom Provider  -->
  <!-- O .NET Framework usará o compilador padrão -->
  <!-- ============================================ -->

"@

$content = $content -replace '</configuration>', "$protectionComment</configuration>"

# Salvar arquivo
$content | Set-Content $webConfigPath -Encoding UTF8

Write-Host "✅ Web.config corrigido definitivamente!" -ForegroundColor Green

# Verificar se ainda há seções ativas
$newContent = Get-Content $webConfigPath -Raw
$newMatches = [regex]::Matches($newContent, '<system\.codedom>')

if ($newMatches.Count -eq 0) {
    Write-Host "✅ Nenhuma seção system.codedom ativa encontrada!" -ForegroundColor Green
} else {
    Write-Host "⚠️  AINDA HÁ $($newMatches.Count) seções ativas!" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
Write-Host "1. Feche o Visual Studio completamente" -ForegroundColor White
Write-Host "2. Abra novamente" -ForegroundColor White
Write-Host "3. Limpe a solução (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "4. Recompile (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "5. Execute (F5)" -ForegroundColor White

Write-Host ""
Write-Host "⚠️  IMPORTANTE: Se o Visual Studio adicionar system.codedom novamente:" -ForegroundColor Yellow
Write-Host "   - Vá em Projeto → Propriedades → Compilar" -ForegroundColor White
Write-Host "   - Desmarque 'Usar compilador Roslyn'" -ForegroundColor White
Write-Host "   - Ou desinstale Microsoft.CodeDom.Providers.DotNetCompilerPlatform" -ForegroundColor White