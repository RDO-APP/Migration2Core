# FORCAR VISUAL STUDIO COMO ADMINISTRADOR

Write-Host "=== FORCANDO VISUAL STUDIO COMO ADMINISTRADOR ===" -ForegroundColor Yellow
Write-Host ""

# Fechar Visual Studio se estiver aberto
Write-Host "Fechando Visual Studio..." -ForegroundColor Cyan
try {
    Get-Process -Name "devenv" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "Visual Studio fechado" -ForegroundColor Green
} catch {
    Write-Host "Visual Studio nao estava aberto" -ForegroundColor Yellow
}

# Tentar abrir como administrador via installer
Write-Host ""
Write-Host "OPCAO 1: Abrindo installer..." -ForegroundColor Cyan
$installerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"

if (Test-Path $installerPath) {
    try {
        Start-Process -FilePath $installerPath -Verb RunAs
        Write-Host "Installer aberto COMO ADMINISTRADOR!" -ForegroundColor Green
        Write-Host ""
        Write-Host "NO INSTALLER:" -ForegroundColor Yellow
        Write-Host "1. Clique em 'Iniciar' no Visual Studio Community" -ForegroundColor White
        Write-Host "2. AGORA deve abrir como Administrador" -ForegroundColor Green
        Write-Host "3. Verifique se tem '(Administrador)' no titulo" -ForegroundColor Red
        
    } catch {
        Write-Host "Erro ao abrir installer como admin: $($_.Exception.Message)" -ForegroundColor Red
        
        Write-Host ""
        Write-Host "OPCAO 2: Tentando abrir VS diretamente..." -ForegroundColor Cyan
        
        # Tentar caminhos diretos
        $vsPaths = @(
            "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
            "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
        )
        
        $vsEncontrado = $false
        foreach ($path in $vsPaths) {
            if (Test-Path $path) {
                try {
                    Start-Process -FilePath $path -Verb RunAs
                    Write-Host "Visual Studio aberto COMO ADMINISTRADOR!" -ForegroundColor Green
                    $vsEncontrado = $true
                    break
                } catch {
                    Write-Host "Erro ao abrir: $path" -ForegroundColor Red
                }
            }
        }
        
        if (-not $vsEncontrado) {
            Write-Host ""
            Write-Host "OPCAO 3: MANUAL" -ForegroundColor Yellow
            Write-Host "1. Pressione Windows + R" -ForegroundColor White
            Write-Host "2. Digite: devenv" -ForegroundColor White
            Write-Host "3. Pressione Ctrl+Shift+Enter (abre como admin)" -ForegroundColor Red
            Write-Host "4. Ou procure 'Visual Studio' no menu Iniciar" -ForegroundColor White
            Write-Host "5. Clique direito > 'Executar como administrador'" -ForegroundColor Red
        }
    }
} else {
    Write-Host "Installer nao encontrado!" -ForegroundColor Red
}

Write-Host ""
Write-Host "DEPOIS DE ABRIR COMO ADMINISTRADOR:" -ForegroundColor Green
Write-Host "1. Titulo DEVE mostrar: 'Visual Studio 2026 (Administrador)'" -ForegroundColor Red
Write-Host "2. Abra: rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "3. Compilar > Limpar Solucao" -ForegroundColor White
Write-Host "4. Compilar > Recompilar Solucao" -ForegroundColor White
Write-Host "5. F5 para executar" -ForegroundColor White

Write-Host ""