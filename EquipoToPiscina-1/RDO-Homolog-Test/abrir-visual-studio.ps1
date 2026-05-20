# SCRIPT PARA ABRIR VISUAL STUDIO COM O PROJETO RDO HOMOLOG
# Abre automaticamente o projeto corrigido

Write-Host "=== ABRINDO VISUAL STUDIO - RDO HOMOLOG ===" -ForegroundColor Green
Write-Host ""

# Caminho do projeto
$projectPath = "rdoappProject\rdoappProject.csproj"

# Verificar se projeto existe
if (Test-Path $projectPath) {
    Write-Host "1. Projeto encontrado: $projectPath" -ForegroundColor Green
    
    # Tentar abrir com Visual Studio
    Write-Host "2. Abrindo Visual Studio Community..." -ForegroundColor Yellow
    
    try {
        # Abrir projeto no Visual Studio
        Start-Process -FilePath $projectPath -WindowStyle Maximized
        Write-Host "   ✅ Visual Studio abrindo..." -ForegroundColor Green
        
        # Aguardar um pouco
        Start-Sleep -Seconds 3
        
        Write-Host ""
        Write-Host "=== PRÓXIMOS PASSOS ===" -ForegroundColor Cyan
        Write-Host "1. Aguarde o Visual Studio carregar completamente"
        Write-Host "2. Verifique a Lista de Erros (View > Error List)"
        Write-Host "3. Pressione F5 para executar"
        Write-Host "4. Teste: http://localhost:[porta]/teste-ok.aspx"
        Write-Host ""
        Write-Host "🔑 CREDENCIAIS DE TESTE:" -ForegroundColor Yellow
        Write-Host "   CPF: 567.065.455-20"
        Write-Host "   Senha: 1234"
        
    } catch {
        Write-Host "   ❌ Erro ao abrir automaticamente" -ForegroundColor Red
        Write-Host ""
        Write-Host "ALTERNATIVA MANUAL:" -ForegroundColor Yellow
        Write-Host "1. Abra o Visual Studio pelo Menu Iniciar"
        Write-Host "2. File > Open > Project/Solution"
        Write-Host "3. Navegue até: $((Get-Location).Path)\$projectPath"
        Write-Host "4. Clique em Open"
    }
    
} else {
    Write-Host "❌ ERRO: Projeto não encontrado!" -ForegroundColor Red
    Write-Host "Caminho esperado: $projectPath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Verifique se você está na pasta correta:" -ForegroundColor Yellow
    Write-Host "RDO-Homolog-Test\"
}

Write-Host ""
Write-Host "📋 LEMBRETE - STATUS ATUAL:" -ForegroundColor Green
Write-Host "✅ Web.config corrigido (sem system.codedom)"
Write-Host "✅ Erro CS1519 corrigido (token '*' removido)"
Write-Host "✅ Funcionalidade laudo implementada"
Write-Host "✅ Aplicação pronta para teste"