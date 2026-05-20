# RESTAURAR NUGET E INSTALAR REPORTVIEWER
# Script para resolver problemas de NuGet e instalar ReportViewer

Write-Host "=== CORRIGINDO NUGET E INSTALANDO REPORTVIEWER ===" -ForegroundColor Green

# Passo 1: Restaurar pacotes NuGet
Write-Host "`n1. RESTAURANDO PACOTES NUGET..." -ForegroundColor Yellow

# No Console do Package Manager, execute:
Write-Host "Execute estes comandos no Console do Package Manager do Visual Studio:" -ForegroundColor Cyan
Write-Host "PM> Update-Package -reinstall" -ForegroundColor White
Write-Host "PM> Restore-Package" -ForegroundColor White
Write-Host "`nOu use o menu:" -ForegroundColor Cyan
Write-Host "Ferramentas > Gerenciador de Pacotes NuGet > Restaurar Pacotes NuGet" -ForegroundColor White

Write-Host "`n2. ALTERNATIVA: RESTAURAR VIA SOLUTION EXPLORER" -ForegroundColor Yellow
Write-Host "- Clique com botão direito na Solution" -ForegroundColor White
Write-Host "- Selecione 'Restore NuGet Packages'" -ForegroundColor White

Write-Host "`n3. DEPOIS DE RESTAURAR, INSTALE O REPORTVIEWER:" -ForegroundColor Yellow
Write-Host "PM> Install-Package Microsoft.ReportViewer.WebForms -Version 11.0.3452.0" -ForegroundColor White

Write-Host "`n4. SE AINDA DER ERRO, TENTE VERSÃO MAIS NOVA:" -ForegroundColor Yellow
Write-Host "PM> Install-Package Microsoft.ReportViewer.WebForms" -ForegroundColor White

Write-Host "`n5. ALTERNATIVA: INTERFACE GRÁFICA" -ForegroundColor Yellow
Write-Host "- Ferramentas > Gerenciador de Pacotes NuGet > Gerenciar Pacotes NuGet para a Solução" -ForegroundColor White
Write-Host "- Aba 'Procurar'" -ForegroundColor White
Write-Host "- Pesquise: Microsoft.ReportViewer.WebForms" -ForegroundColor White
Write-Host "- Instale a versão mais recente" -ForegroundColor White

Write-Host "`n=== SOLUÇÃO RÁPIDA ===" -ForegroundColor Magenta
Write-Host "Se nada funcionar, teste SEM ReportViewer primeiro:" -ForegroundColor Yellow
Write-Host "1. Comente as referências do ReportViewer no Web.config" -ForegroundColor White
Write-Host "2. Comente o 'using Microsoft.Reporting.WebForms' no LaudoModel.cs" -ForegroundColor White
Write-Host "3. Desabilite a geração de PDF temporariamente" -ForegroundColor White
Write-Host "4. Teste se a aplicação carrega e as funcionalidades básicas funcionam" -ForegroundColor White

Write-Host "`n=== COMANDOS PARA COPIAR ===" -ForegroundColor Green
Write-Host "Update-Package -reinstall" -ForegroundColor Cyan
Write-Host "Install-Package Microsoft.ReportViewer.WebForms -Version 11.0.3452.0" -ForegroundColor Cyan