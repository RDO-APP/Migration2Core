# INSTALAR MICROSOFT REPORTVIEWER VIA NUGET
# Script para instalar o ReportViewer no projeto de homologação

Write-Host "=== INSTALANDO MICROSOFT REPORTVIEWER ===" -ForegroundColor Green

# Navegar para o diretório do projeto
$projectPath = "RDO-Homolog-Test\rdoappProject"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "Navegando para: $projectPath" -ForegroundColor Yellow
} else {
    Write-Host "ERRO: Diretório do projeto não encontrado: $projectPath" -ForegroundColor Red
    exit 1
}

# Verificar se existe packages.config
if (Test-Path "packages.config") {
    Write-Host "Arquivo packages.config encontrado" -ForegroundColor Green
} else {
    Write-Host "AVISO: packages.config não encontrado" -ForegroundColor Yellow
}

# Instalar Microsoft ReportViewer
Write-Host "Instalando Microsoft.ReportViewer.WebForms..." -ForegroundColor Yellow

# Comando NuGet para instalar ReportViewer
$nugetCommand = "nuget install Microsoft.ReportViewer.WebForms -Version 11.0.3452.0 -OutputDirectory packages"

try {
    Invoke-Expression $nugetCommand
    Write-Host "Microsoft.ReportViewer.WebForms instalado com sucesso!" -ForegroundColor Green
} catch {
    Write-Host "ERRO ao instalar ReportViewer via nuget. Tentando com dotnet..." -ForegroundColor Yellow
    
    # Tentar com dotnet add package
    try {
        dotnet add package Microsoft.ReportViewer.WebForms --version 11.0.3452.0
        Write-Host "ReportViewer instalado via dotnet!" -ForegroundColor Green
    } catch {
        Write-Host "ERRO: Não foi possível instalar o ReportViewer automaticamente" -ForegroundColor Red
        Write-Host "SOLUÇÃO MANUAL:" -ForegroundColor Yellow
        Write-Host "1. Abra o Visual Studio" -ForegroundColor White
        Write-Host "2. Vá em Ferramentas > Gerenciador de Pacotes NuGet > Console do Gerenciador de Pacotes" -ForegroundColor White
        Write-Host "3. Execute: Install-Package Microsoft.ReportViewer.WebForms -Version 11.0.3452.0" -ForegroundColor White
        Write-Host "4. Ou use a interface gráfica: Ferramentas > Gerenciador de Pacotes NuGet > Gerenciar Pacotes NuGet para a Solução" -ForegroundColor White
    }
}

# Verificar se foi instalado
if (Test-Path "packages\Microsoft.ReportViewer.WebForms*") {
    Write-Host "✅ ReportViewer instalado com sucesso!" -ForegroundColor Green
    Write-Host "Agora você pode executar o projeto sem erros de compilação" -ForegroundColor Green
} else {
    Write-Host "⚠️  Instalação automática falhou. Use o Visual Studio para instalar manualmente." -ForegroundColor Yellow
}

Write-Host "`n=== PRÓXIMOS PASSOS ===" -ForegroundColor Cyan
Write-Host "1. Abra o Visual Studio" -ForegroundColor White
Write-Host "2. Compile o projeto (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "3. Execute com F5" -ForegroundColor White
Write-Host "4. Teste as funcionalidades de laudo" -ForegroundColor White

# Voltar ao diretório original
Set-Location ..\..