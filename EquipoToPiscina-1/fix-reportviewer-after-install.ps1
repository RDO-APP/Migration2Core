# REATIVAR REPORTVIEWER APÓS INSTALAÇÃO

Write-Host "🔧 REATIVANDO REPORTVIEWER NO WEB.CONFIG..." -ForegroundColor Yellow

$webConfigPath = "RDO-Homolog-Test/rdoappProject/Web.config"

Write-Host "📝 Descomentando assemblies ReportViewer..." -ForegroundColor Cyan

# Descomentar assemblies
(Get-Content $webConfigPath) -replace 
    '<!-- <add assembly="Microsoft.ReportViewer.Common', 
    '<add assembly="Microsoft.ReportViewer.Common' |
Set-Content $webConfigPath

(Get-Content $webConfigPath) -replace 
    'PublicKeyToken=89845DCD8080CC91" /> -->', 
    'PublicKeyToken=89845DCD8080CC91" />' |
Set-Content $webConfigPath

Write-Host "📝 Descomentando handlers ReportViewer..." -ForegroundColor Cyan

# Descomentar httpHandlers
(Get-Content $webConfigPath) -replace 
    '<!-- <add path="Reserved.ReportViewerWebControl.axd"', 
    '<add path="Reserved.ReportViewerWebControl.axd"' |
Set-Content $webConfigPath

(Get-Content $webConfigPath) -replace 
    'validate="false" /> -->', 
    'validate="false" />' |
Set-Content $webConfigPath

# Descomentar system.webServer handlers
(Get-Content $webConfigPath) -replace 
    '<!-- <add name="ReportViewerWebControlHandler"', 
    '<add name="ReportViewerWebControlHandler"' |
Set-Content $webConfigPath

(Get-Content $webConfigPath) -replace 
    'PublicKeyToken=89845dcd8080cc91" /> -->', 
    'PublicKeyToken=89845dcd8080cc91" />' |
Set-Content $webConfigPath

# Descomentar binding redirects
(Get-Content $webConfigPath) -replace 
    '<!-- <dependentAssembly>', 
    '<dependentAssembly>' |
Set-Content $webConfigPath

(Get-Content $webConfigPath) -replace 
    '</dependentAssembly> -->', 
    '</dependentAssembly>' |
Set-Content $webConfigPath

Write-Host "📝 Descomentando using statements..." -ForegroundColor Cyan

# Descomentar using statements
$laudoModelPath = "RDO-Homolog-Test/rdoappProject/Api/Models/LaudoModel.cs"
$tarefaModelPath = "RDO-Homolog-Test/rdoappProject/Api/Models/TarefaModel.cs"

(Get-Content $laudoModelPath) -replace 
    '// using Microsoft.Reporting.WebForms;', 
    'using Microsoft.Reporting.WebForms;' |
Set-Content $laudoModelPath

(Get-Content $tarefaModelPath) -replace 
    '// using Microsoft.Reporting.WebForms;', 
    'using Microsoft.Reporting.WebForms;' |
Set-Content $tarefaModelPath

Write-Host ""
Write-Host "✅ REPORTVIEWER REATIVADO COM SUCESSO!" -ForegroundColor Green
Write-Host "🎯 Agora teste a aplicação novamente (F5)" -ForegroundColor Cyan