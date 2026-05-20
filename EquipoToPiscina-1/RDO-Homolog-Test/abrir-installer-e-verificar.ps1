# ABRIR VISUAL STUDIO INSTALLER E VERIFICAR INSTALACAO

Write-Host "=== ABRINDO VISUAL STUDIO INSTALLER ===" -ForegroundColor Yellow
Write-Host ""

# Tentar encontrar o installer
$installerPaths = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe",
    "C:\Arquivos de Programas (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
)

$installerEncontrado = $false
$installerPath = ""

foreach ($path in $installerPaths) {
    if (Test-Path $path) {
        $installerEncontrado = $true
        $installerPath = $path
        break
    }
}

if ($installerEncontrado) {
    Write-Host "Installer encontrado: $installerPath" -ForegroundColor Green
    Write-Host "Abrindo Visual Studio Installer..." -ForegroundColor Cyan
    
    try {
        Start-Process -FilePath $installerPath
        Write-Host "Visual Studio Installer aberto!" -ForegroundColor Green
        Write-Host ""
        Write-Host "INSTRUCOES NO INSTALLER:" -ForegroundColor Yellow
        Write-Host "1. Procure por 'Visual Studio Community 2022'" -ForegroundColor White
        Write-Host "2. Se estiver instalado, clique em 'Iniciar'" -ForegroundColor White
        Write-Host "3. Se nao estiver instalado, clique em 'Instalar'" -ForegroundColor White
        Write-Host "4. Quando abrir o VS, verifique se tem '(Administrador)' no titulo" -ForegroundColor White
        Write-Host "5. Se nao tiver, feche e clique direito > 'Executar como administrador'" -ForegroundColor White
        Write-Host ""
        Write-Host "DEPOIS DE ABRIR COMO ADMINISTRADOR:" -ForegroundColor Green
        Write-Host "1. Abra: rdoappProject\rdoappProject.sln" -ForegroundColor White
        Write-Host "2. Compilar > Limpar Solucao" -ForegroundColor White
        Write-Host "3. Compilar > Recompilar Solucao" -ForegroundColor White
        Write-Host "4. F5 para executar" -ForegroundColor White
        Write-Host "5. Teste salvar laudo e verifique F12 Console" -ForegroundColor White
        
    } catch {
        Write-Host "Erro ao abrir installer: $($_.Exception.Message)" -ForegroundColor Red
    }
    
} else {
    Write-Host "Visual Studio Installer nao encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "SOLUCAO ALTERNATIVA:" -ForegroundColor Yellow
    Write-Host "1. Pressione Windows + R" -ForegroundColor White
    Write-Host "2. Digite: appwiz.cpl" -ForegroundColor White
    Write-Host "3. Procure por 'Microsoft Visual Studio'" -ForegroundColor White
    Write-Host "4. Se encontrar, clique direito > Alterar" -ForegroundColor White
    Write-Host "5. Ou baixe o installer do site da Microsoft" -ForegroundColor White
}

Write-Host ""