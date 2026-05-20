# INSTALAR VISUAL STUDIO COMMUNITY 2022

Write-Host "=== INSTALANDO VISUAL STUDIO COMMUNITY 2022 ===" -ForegroundColor Yellow
Write-Host ""

# Verificar se installer existe
$installerPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"

if (Test-Path $installerPath) {
    Write-Host "Visual Studio Installer encontrado!" -ForegroundColor Green
    Write-Host "Caminho: $installerPath" -ForegroundColor White
    Write-Host ""
    
    Write-Host "ABRINDO INSTALLER PARA INSTALACAO..." -ForegroundColor Cyan
    Write-Host ""
    
    # Abrir installer
    Start-Process $installerPath -Verb RunAs
    
    Write-Host "=== INSTRUCOES NO INSTALLER ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. PROCURE por 'Visual Studio Community 2022'" -ForegroundColor White
    Write-Host "   - Se nao aparecer, clique em 'Disponivel'" -ForegroundColor Gray
    Write-Host "   - Deve estar listado como gratuito" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. CLIQUE EM 'INSTALAR' no Community 2022" -ForegroundColor White
    Write-Host ""
    Write-Host "3. SELECIONE OS WORKLOADS NECESSARIOS:" -ForegroundColor White
    Write-Host "   [X] ASP.NET e desenvolvimento Web" -ForegroundColor Cyan
    Write-Host "   [X] Desenvolvimento para desktop do .NET" -ForegroundColor Cyan
    Write-Host "   [X] Ferramentas de dados e armazenamento" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. CLIQUE EM 'INSTALAR'" -ForegroundColor White
    Write-Host ""
    Write-Host "5. AGUARDE A INSTALACAO (pode demorar 1-2 horas)" -ForegroundColor Yellow
    Write-Host "   - Nao feche o installer" -ForegroundColor Gray
    Write-Host "   - Nao desligue o computador" -ForegroundColor Gray
    Write-Host "   - Mantenha conexao com internet" -ForegroundColor Gray
    Write-Host ""
    Write-Host "6. QUANDO TERMINAR:" -ForegroundColor Green
    Write-Host "   - Execute: .\verificar-vs-instalado.ps1" -ForegroundColor White
    Write-Host "   - Deve aparecer como 'ENCONTRADO'" -ForegroundColor White
    Write-Host ""
    
} else {
    Write-Host "Visual Studio Installer NAO encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUCAO: Baixar e instalar Visual Studio Installer" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Acesse: https://visualstudio.microsoft.com/downloads/" -ForegroundColor White
    Write-Host "2. Clique em 'Download gratuito' no Community" -ForegroundColor White
    Write-Host "3. Execute o arquivo baixado" -ForegroundColor White
    Write-Host "4. Siga as instrucoes de instalacao" -ForegroundColor White
    Write-Host ""
    
    Write-Host "DESEJA ABRIR O SITE AGORA? (s/n)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq "s" -or $response -eq "S") {
        Start-Process "https://visualstudio.microsoft.com/downloads/"
    }
}

Write-Host ""
Write-Host "=== IMPORTANTE ===" -ForegroundColor Red
Write-Host "NAO CONTINUE com o projeto ate o Visual Studio estar instalado!" -ForegroundColor White
Write-Host "A instalacao e essencial para compilar o codigo C#" -ForegroundColor White
Write-Host ""