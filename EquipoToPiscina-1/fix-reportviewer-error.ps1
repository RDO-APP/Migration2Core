# Script para corrigir erro do Microsoft ReportViewer

Write-Host "=== CORRIGINDO ERRO DO MICROSOFT REPORTVIEWER ===" -ForegroundColor Green

# Verificar se o projeto existe
$projectPath = "RDO-Homolog-Test/rdoappProject"
if (!(Test-Path $projectPath)) {
    Write-Host "ERRO: Projeto não encontrado em $projectPath" -ForegroundColor Red
    exit 1
}

Write-Host "1. Verificando packages.config..." -ForegroundColor Yellow
$packagesConfig = "$projectPath/packages.config"

if (Test-Path $packagesConfig) {
    $content = Get-Content $packagesConfig
    Write-Host "Packages.config encontrado. Conteúdo:" -ForegroundColor Green
    $content | Select-String "ReportViewer" | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
} else {
    Write-Host "packages.config não encontrado" -ForegroundColor Red
}

Write-Host "`n2. Verificando Web.config..." -ForegroundColor Yellow
$webConfig = "$projectPath/Web.config"

if (Test-Path $webConfig) {
    $webContent = Get-Content $webConfig
    $reportViewerLines = $webContent | Select-String "ReportViewer"
    
    if ($reportViewerLines) {
        Write-Host "Referências do ReportViewer encontradas no Web.config:" -ForegroundColor Green
        $reportViewerLines | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
        
        Write-Host "`n3. Comentando referências problemáticas do ReportViewer..." -ForegroundColor Yellow
        
        # Fazer backup do Web.config
        Copy-Item $webConfig "$webConfig.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "Backup criado: $webConfig.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')" -ForegroundColor Green
        
        # Comentar as linhas problemáticas
        $newContent = $webContent | ForEach-Object {
            if ($_ -match "Microsoft\.ReportViewer\.Common.*Version=11\.0\.0\.0") {
                "        <!-- $_ -->"
            } elseif ($_ -match "Microsoft\.ReportViewer\.WebForms.*Version=11\.0\.0\.0") {
                "        <!-- $_ -->"
            } else {
                $_
            }
        }
        
        # Salvar o arquivo modificado
        $newContent | Set-Content $webConfig -Encoding UTF8
        Write-Host "Web.config atualizado - referências do ReportViewer comentadas" -ForegroundColor Green
        
    } else {
        Write-Host "Nenhuma referência do ReportViewer encontrada no Web.config" -ForegroundColor Yellow
    }
} else {
    Write-Host "Web.config não encontrado" -ForegroundColor Red
}

Write-Host "`n4. Verificando pasta bin..." -ForegroundColor Yellow
$binPath = "$projectPath/bin"

if (Test-Path $binPath) {
    $reportViewerDlls = Get-ChildItem $binPath -Filter "*ReportViewer*" -ErrorAction SilentlyContinue
    
    if ($reportViewerDlls) {
        Write-Host "DLLs do ReportViewer encontradas:" -ForegroundColor Green
        $reportViewerDlls | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Cyan }
    } else {
        Write-Host "Nenhuma DLL do ReportViewer encontrada na pasta bin" -ForegroundColor Yellow
    }
} else {
    Write-Host "Pasta bin não encontrada" -ForegroundColor Red
}

Write-Host "`n5. Verificando arquivo de projeto..." -ForegroundColor Yellow
$csprojFiles = Get-ChildItem $projectPath -Filter "*.csproj"

if ($csprojFiles) {
    $csprojPath = $csprojFiles[0].FullName
    $csprojContent = Get-Content $csprojPath
    $reportViewerRefs = $csprojContent | Select-String "ReportViewer"
    
    if ($reportViewerRefs) {
        Write-Host "Referências do ReportViewer no arquivo de projeto:" -ForegroundColor Green
        $reportViewerRefs | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
    } else {
        Write-Host "Nenhuma referência do ReportViewer no arquivo de projeto" -ForegroundColor Yellow
    }
}

Write-Host "`n=== CORREÇÃO CONCLUÍDA ===" -ForegroundColor Green
Write-Host "Tente compilar o projeto novamente." -ForegroundColor Yellow
Write-Host "Se ainda houver erro, execute: dotnet restore ou Update-Package -reinstall no Package Manager Console" -ForegroundColor Yellow