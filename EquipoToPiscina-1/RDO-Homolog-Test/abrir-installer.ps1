# ABRIR VISUAL STUDIO INSTALLER PARA VERIFICAR STATUS

Write-Host "=== ABRINDO VISUAL STUDIO INSTALLER ===" -ForegroundColor Yellow

$installerPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"

if (Test-Path $installerPath) {
    Write-Host "Abrindo Visual Studio Installer..." -ForegroundColor Green
    Write-Host "Caminho: $installerPath" -ForegroundColor White
    
    try {
        Start-Process $installerPath
        Write-Host ""
        Write-Host "VERIFIQUE NO INSTALLER:" -ForegroundColor Yellow
        Write-Host "1. Se Visual Studio Community 2022 aparece na lista" -ForegroundColor White
        Write-Host "2. Se esta com status 'Instalando' ou 'Atualizando'" -ForegroundColor White
        Write-Host "3. Se ha alguma barra de progresso ativa" -ForegroundColor White
        Write-Host "4. Se precisa clicar em 'Instalar' ou 'Atualizar'" -ForegroundColor White
        Write-Host ""
        Write-Host "SE ESTIVER INSTALANDO/ATUALIZANDO:" -ForegroundColor Cyan
        Write-Host "- Aguarde o processo terminar completamente" -ForegroundColor White
        Write-Host "- Pode demorar 30 minutos a 2 horas" -ForegroundColor White
        Write-Host "- Nao interrompa o processo" -ForegroundColor White
        Write-Host ""
        Write-Host "QUANDO TERMINAR:" -ForegroundColor Green
        Write-Host "- Execute novamente: .\verificar-vs-instalado.ps1" -ForegroundColor White
        Write-Host "- Deve aparecer como 'ENCONTRADO'" -ForegroundColor White
    } catch {
        Write-Host "Erro ao abrir installer: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Visual Studio Installer nao encontrado!" -ForegroundColor Red
}

Write-Host ""