# TESTAR APLICAÇÃO SEM REPORTVIEWER
# Script para testar se a aplicação funciona sem ReportViewer

Write-Host "=== TESTANDO SEM REPORTVIEWER ===" -ForegroundColor Green

$webConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config"
$laudoModelPath = "RDO-Homolog-Test\rdoappProject\Api\Models\LaudoModel.cs"

# Backup dos arquivos originais
Write-Host "Fazendo backup dos arquivos..." -ForegroundColor Yellow
Copy-Item $webConfigPath "$webConfigPath.backup" -Force
Copy-Item $laudoModelPath "$laudoModelPath.backup" -Force

Write-Host "Arquivos de backup criados:" -ForegroundColor Green
Write-Host "- $webConfigPath.backup" -ForegroundColor White
Write-Host "- $laudoModelPath.backup" -ForegroundColor White

Write-Host "`n=== INSTRUÇÕES MANUAIS ===" -ForegroundColor Cyan
Write-Host "1. COMENTE AS LINHAS DO REPORTVIEWER NO WEB.CONFIG:" -ForegroundColor Yellow
Write-Host "   <!-- <add assembly=`"Microsoft.ReportViewer.Common...`" /> -->" -ForegroundColor White
Write-Host "   <!-- <add assembly=`"Microsoft.ReportViewer.WebForms...`" /> -->" -ForegroundColor White
Write-Host "   <!-- <add name=`"ReportViewerWebControlHandler`"... /> -->" -ForegroundColor White

Write-Host "`n2. COMENTE O USING NO LAUDOMODEL.CS:" -ForegroundColor Yellow
Write-Host "   // using Microsoft.Reporting.WebForms;" -ForegroundColor White

Write-Host "`n3. DESABILITE OS MÉTODOS PDF:" -ForegroundColor Yellow
Write-Host "   Adicione 'throw new NotImplementedException();' nos métodos:" -ForegroundColor White
Write-Host "   - GerarDocumentoRdo()" -ForegroundColor White
Write-Host "   - GenerateReport()" -ForegroundColor White

Write-Host "`n4. TESTE A APLICAÇÃO:" -ForegroundColor Yellow
Write-Host "   - Compile (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "   - Execute (F5)" -ForegroundColor White
Write-Host "   - Login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "   - Teste páginas de laudo (sem PDF)" -ForegroundColor White

Write-Host "`n5. PARA RESTAURAR:" -ForegroundColor Yellow
Write-Host "   Copy-Item `"$webConfigPath.backup`" `"$webConfigPath`" -Force" -ForegroundColor White
Write-Host "   Copy-Item `"$laudoModelPath.backup`" `"$laudoModelPath`" -Force" -ForegroundColor White

Write-Host "`n=== OBJETIVO ===" -ForegroundColor Magenta
Write-Host "Verificar se o problema é APENAS o ReportViewer ou se há outros erros" -ForegroundColor Yellow
Write-Host "Se funcionar sem ReportViewer, o problema é só a instalação do pacote" -ForegroundColor Green