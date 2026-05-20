# REABRIR VISUAL STUDIO COMO ADMINISTRADOR

Write-Host "=== REABRINDO VISUAL STUDIO COMO ADMINISTRADOR ===" -ForegroundColor Yellow
Write-Host ""

# Parar processos existentes
Write-Host "Parando processos existentes..." -ForegroundColor Cyan
try {
    Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name "w3wp" -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "Processos IIS finalizados" -ForegroundColor Green
} catch {
    Write-Host "Processos IIS nao encontrados" -ForegroundColor Yellow
}

# Tentar abrir Visual Studio Installer
Write-Host ""
Write-Host "Abrindo Visual Studio Installer..." -ForegroundColor Cyan

$installerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
if (Test-Path $installerPath) {
    try {
        Start-Process -FilePath $installerPath
        Write-Host "Visual Studio Installer aberto!" -ForegroundColor Green
        Write-Host ""
        Write-Host "NO INSTALLER:" -ForegroundColor Yellow
        Write-Host "1. Procure 'Visual Studio Community 2022'" -ForegroundColor White
        Write-Host "2. Clique em 'Iniciar'" -ForegroundColor White
        Write-Host "3. IMPORTANTE: Verifique se tem '(Administrador)' no titulo" -ForegroundColor Red
        Write-Host "4. Se NAO tiver, feche e clique direito > 'Executar como administrador'" -ForegroundColor Red
        Write-Host ""
        Write-Host "DEPOIS DE ABRIR COMO ADMINISTRADOR:" -ForegroundColor Green
        Write-Host "1. Abra: rdoappProject\rdoappProject.sln" -ForegroundColor White
        Write-Host "2. F5 para executar" -ForegroundColor White
        Write-Host "3. Teste novamente a aplicacao" -ForegroundColor White
        
    } catch {
        Write-Host "Erro ao abrir installer: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Installer nao encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "ALTERNATIVA:" -ForegroundColor Yellow
    Write-Host "1. Pressione Windows + R" -ForegroundColor White
    Write-Host "2. Digite: devenv" -ForegroundColor White
    Write-Host "3. Se nao funcionar, procure 'Visual Studio' no menu Iniciar" -ForegroundColor White
    Write-Host "4. Clique direito > 'Executar como administrador'" -ForegroundColor White
}

Write-Host ""