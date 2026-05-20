# Fix ReportViewer Compilation Errors
# This script fixes the 14 compilation errors related to ReportViewer

Write-Host "🔧 CORRIGINDO ERROS DE COMPILAÇÃO REPORTVIEWER" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Check if we need to install ReportViewer NuGet package
Write-Host ""
Write-Host "📦 VERIFICANDO PACOTES NUGET:" -ForegroundColor Cyan

$packagesConfigPath = "RDO-Homolog-Test\rdoappProject\packages.config"
if (Test-Path $packagesConfigPath) {
    $packagesContent = Get-Content $packagesConfigPath -Raw
    
    if ($packagesContent -match "Microsoft\.ReportViewer") {
        Write-Host "✅ Pacote Microsoft.ReportViewer encontrado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Pacote Microsoft.ReportViewer não encontrado" -ForegroundColor Yellow
        Write-Host "   Será necessário instalar via NuGet Package Manager" -ForegroundColor White
    }
} else {
    Write-Host "⚠️  Arquivo packages.config não encontrado" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🔧 SOLUÇÕES PARA OS 14 ERROS:" -ForegroundColor Cyan

Write-Host ""
Write-Host "ERRO: 'LocalReport' não pode ser encontrado" -ForegroundColor Red
Write-Host "SOLUÇÃO:" -ForegroundColor Green
Write-Host "1. Abra o Visual Studio" -ForegroundColor White
Write-Host "2. Vá em Ferramentas → Gerenciador de Pacotes NuGet → Console do Gerenciador de Pacotes" -ForegroundColor White
Write-Host "3. Execute o comando:" -ForegroundColor White
Write-Host "   Install-Package Microsoft.ReportViewer.WebForms -Version 11.0.3452.0" -ForegroundColor Yellow

Write-Host ""
Write-Host "ERRO: 'ReportDataSource' não pode ser encontrado" -ForegroundColor Red
Write-Host "SOLUÇÃO:" -ForegroundColor Green
Write-Host "   O mesmo pacote NuGet acima resolve este erro" -ForegroundColor White

Write-Host ""
Write-Host "ERRO: 'ReportParameter' não pode ser encontrado" -ForegroundColor Red
Write-Host "SOLUÇÃO:" -ForegroundColor Green
Write-Host "   O mesmo pacote NuGet acima resolve este erro" -ForegroundColor White

Write-Host ""
Write-Host "📋 COMANDOS ALTERNATIVOS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Se o comando acima não funcionar, tente:" -ForegroundColor White
Write-Host "Install-Package Microsoft.ReportViewer.Common -Version 11.0.3452.0" -ForegroundColor Yellow
Write-Host "Install-Package Microsoft.ReportViewer.WebForms -Version 11.0.3452.0" -ForegroundColor Yellow

Write-Host ""
Write-Host "📋 VERIFICAÇÃO MANUAL:" -ForegroundColor Cyan
Write-Host "1. No Visual Studio, clique com botão direito no projeto" -ForegroundColor White
Write-Host "2. Selecione 'Gerenciar Pacotes NuGet...'" -ForegroundColor White
Write-Host "3. Vá na aba 'Procurar'" -ForegroundColor White
Write-Host "4. Pesquise por 'Microsoft.ReportViewer.WebForms'" -ForegroundColor White
Write-Host "5. Instale a versão 11.0.3452.0" -ForegroundColor White

Write-Host ""
Write-Host "🚨 SE AINDA HOUVER PROBLEMAS:" -ForegroundColor Yellow
Write-Host "1. Feche o Visual Studio" -ForegroundColor White
Write-Host "2. Delete a pasta 'packages' do projeto" -ForegroundColor White
Write-Host "3. Abra o Visual Studio novamente" -ForegroundColor White
Write-Host "4. Clique com botão direito na Solução" -ForegroundColor White
Write-Host "5. Selecione 'Restaurar Pacotes NuGet'" -ForegroundColor White

Write-Host ""
Write-Host "✅ APÓS INSTALAR O PACOTE:" -ForegroundColor Green
Write-Host "1. Compile o projeto (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Os 14 erros devem desaparecer" -ForegroundColor White
Write-Host "3. Execute o projeto (F5)" -ForegroundColor White
Write-Host "4. Teste a geração de PDF do laudo" -ForegroundColor White

Write-Host ""
Write-Host "🎯 OBJETIVO:" -ForegroundColor Cyan
Write-Host "Resolver os 14 erros de compilação para que o botão impressora" -ForegroundColor White
Write-Host "do laudo funcione corretamente e gere o PDF." -ForegroundColor White

Write-Host ""
Write-Host "🚀 EXECUTE OS COMANDOS NUGET E TESTE NOVAMENTE!" -ForegroundColor Green