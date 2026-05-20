# Abrir projeto RDO-NET8-Migration com todas as mudanças salvas
# Todas as correções do Dia 8 estão aplicadas

Write-Host "🎯 ABRINDO PROJETO COM MUDANÇAS SALVAS" -ForegroundColor Green
Write-Host ""
Write-Host "✅ CORREÇÕES APLICADAS:" -ForegroundColor Yellow
Write-Host "  - OBRA entity: campos corretos (obr_ds_logradouro, etc.)" -ForegroundColor White
Write-Host "  - Login: senha correta (RXL8DjqVj6Y=)" -ForegroundColor White
Write-Host "  - Mapeamentos: todos os campos essenciais adicionados" -ForegroundColor White
Write-Host ""

$projectPath = "RDO-NET8-Migration\RdoApp.Core\RdoApp.Core.csproj"

if (Test-Path $projectPath) {
    Write-Host "📂 Abrindo projeto: $projectPath" -ForegroundColor Cyan
    Start-Process "devenv.exe" -ArgumentList $projectPath
    Write-Host "✅ Visual Studio Community iniciado!" -ForegroundColor Green
} else {
    Write-Host "❌ Projeto não encontrado: $projectPath" -ForegroundColor Red
    Write-Host "📍 Diretório atual:" -ForegroundColor Yellow
    Get-Location
}