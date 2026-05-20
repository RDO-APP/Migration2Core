# INSTALAR MICROSOFT REPORTVIEWER - CORREÇÃO DEFINITIVA

Write-Host "🔧 INSTALANDO MICROSOFT REPORTVIEWER..." -ForegroundColor Yellow

# Navegar para o projeto
Set-Location "RDO-Homolog-Test/rdoappProject"

Write-Host "📦 Instalando pacote NuGet Microsoft.ReportViewer.WebForms..." -ForegroundColor Cyan

# Instalar via NuGet Package Manager Console
# EXECUTE ESTE COMANDO NO VISUAL STUDIO:
Write-Host ""
Write-Host "EXECUTE NO VISUAL STUDIO:" -ForegroundColor Green
Write-Host "1. Abra o Visual Studio" -ForegroundColor White
Write-Host "2. Vá em Ferramentas → Gerenciador de Pacotes NuGet → Console do Gerenciador de Pacotes" -ForegroundColor White
Write-Host "3. Execute o comando:" -ForegroundColor White
Write-Host "   Install-Package Microsoft.ReportViewer.WebForms -Version 11.0.3452.0" -ForegroundColor Yellow
Write-Host ""

# Alternativa via linha de comando (pode não funcionar em projetos antigos)
Write-Host "📋 ALTERNATIVA - Comando direto (pode falhar em .NET Framework antigo):" -ForegroundColor Cyan
Write-Host "nuget install Microsoft.ReportViewer.WebForms -Version 11.0.3452.0 -OutputDirectory packages" -ForegroundColor Gray

Write-Host ""
Write-Host "⚠️  IMPORTANTE:" -ForegroundColor Red
Write-Host "   - O ReportViewer 11.0 é compatível com .NET Framework 4.0+" -ForegroundColor White
Write-Host "   - Após instalar, descomente as linhas no Web.config" -ForegroundColor White
Write-Host "   - Descomente os using statements nos arquivos .cs" -ForegroundColor White

Write-Host ""
Write-Host "🎯 APÓS INSTALAÇÃO:" -ForegroundColor Green
Write-Host "   1. Execute: .\fix-reportviewer-after-install.ps1" -ForegroundColor White
Write-Host "   2. Teste a aplicação novamente" -ForegroundColor White

Write-Host ""
Write-Host "✅ Script preparado! Execute os comandos acima." -ForegroundColor Green