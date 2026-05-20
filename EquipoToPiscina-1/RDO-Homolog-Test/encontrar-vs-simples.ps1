# ENCONTRAR VISUAL STUDIO COMMUNITY 2022 - VERSÃO SIMPLES

Write-Host "=== PROCURANDO VISUAL STUDIO COMMUNITY 2022 ===" -ForegroundColor Yellow
Write-Host ""

# Caminhos mais comuns
$vsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
)

$found = $false

Write-Host "Verificando caminhos padrão..." -ForegroundColor Cyan
foreach ($path in $vsPaths) {
    Write-Host "Verificando: $path" -ForegroundColor Gray
    if (Test-Path $path) {
        Write-Host "✓ ENCONTRADO: Visual Studio Community 2022" -ForegroundColor Green
        Write-Host "  Caminho: $path" -ForegroundColor White
        $found = $true
        
        # Tentar abrir
        Write-Host ""
        Write-Host "Deseja abrir agora como Administrador? (s/n)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq "s" -or $response -eq "S") {
            Write-Host "Abrindo Visual Studio como Administrador..." -ForegroundColor Green
            Start-Process -FilePath $path -Verb RunAs
        }
        break
    }
}

if (-not $found) {
    Write-Host "✗ Visual Studio Community 2022 não encontrado nos caminhos padrão" -ForegroundColor Red
    Write-Host ""
    
    # Verificar Visual Studio Installer
    $installerPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"
    Write-Host "Verificando Visual Studio Installer..." -ForegroundColor Cyan
    
    if (Test-Path $installerPath) {
        Write-Host "✓ Visual Studio Installer encontrado" -ForegroundColor Green
        Write-Host "  Caminho: $installerPath" -ForegroundColor White
        Write-Host ""
        Write-Host "Deseja abrir o Installer para verificar a instalação? (s/n)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq "s" -or $response -eq "S") {
            Write-Host "Abrindo Visual Studio Installer..." -ForegroundColor Green
            Start-Process $installerPath -Verb RunAs
        }
    } else {
        Write-Host "✗ Visual Studio Installer também não encontrado" -ForegroundColor Red
        Write-Host ""
        Write-Host "SOLUÇÕES:" -ForegroundColor Yellow
        Write-Host "1. Baixar e instalar Visual Studio Community 2022" -ForegroundColor White
        Write-Host "2. Verificar se a atualização foi concluída" -ForegroundColor White
        Write-Host "3. Procurar manualmente no Menu Iniciar" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "ALTERNATIVAS PARA ENCONTRAR:" -ForegroundColor Cyan
Write-Host "1. Pressione Windows e digite 'Visual Studio'" -ForegroundColor White
Write-Host "2. Verifique a pasta: C:\Program Files\Microsoft Visual Studio\2022\" -ForegroundColor White
Write-Host "3. Verifique a pasta: C:\Program Files (x86)\Microsoft Visual Studio\2022\" -ForegroundColor White

Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")