# ENCONTRAR VISUAL STUDIO COMMUNITY 2022 APÓS REINICIALIZAÇÃO
# Script completo para localizar e verificar instalação do VS Community

Write-Host "=== PROCURANDO VISUAL STUDIO COMMUNITY 2022 ===" -ForegroundColor Yellow
Write-Host "Após reinicialização, vamos localizar onde está instalado..." -ForegroundColor Cyan
Write-Host ""

# 1. VERIFICAR CAMINHOS PADRÃO
Write-Host "1. Verificando caminhos padrão de instalação..." -ForegroundColor Cyan

$vsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
)

$foundPaths = @()
foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        $version = (Get-ItemProperty $path).VersionInfo.FileVersion
        $edition = if ($path -match "Community") { "Community" } 
                  elseif ($path -match "Professional") { "Professional" }
                  elseif ($path -match "Enterprise") { "Enterprise" }
                  else { "Desconhecida" }
        
        $foundPaths += [PSCustomObject]@{
            Path = $path
            Edition = $edition
            Version = $version
        }
        
        Write-Host "   ✓ Encontrado: Visual Studio $edition" -ForegroundColor Green
        Write-Host "     Caminho: $path" -ForegroundColor White
        Write-Host "     Versão: $version" -ForegroundColor White
        Write-Host ""
    }
}

if ($foundPaths.Count -eq 0) {
    Write-Host "   ⚠ Nenhuma instalação encontrada nos caminhos padrão" -ForegroundColor Yellow
}

# 2. PROCURAR NO REGISTRO DO WINDOWS
Write-Host "2. Procurando no Registro do Windows..." -ForegroundColor Cyan

try {
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7"
    )
    
    foreach ($regPath in $regPaths) {
        if (Test-Path $regPath) {
            $vsInstalls = Get-ItemProperty $regPath -ErrorAction SilentlyContinue
            if ($vsInstalls) {
                $vsInstalls.PSObject.Properties | Where-Object { $_.Name -match "17\." } | ForEach-Object {
                    $installPath = $_.Value
                    $devenvPath = Join-Path $installPath "Common7\IDE\devenv.exe"
                    if (Test-Path $devenvPath) {
                        Write-Host "   ✓ Encontrado no registro: $installPath" -ForegroundColor Green
                    }
                }
            }
        }
    }
} catch {
    Write-Host "   ⚠ Erro ao acessar registro: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 3. PROCURAR USANDO VSWHERE (FERRAMENTA OFICIAL MICROSOFT)
Write-Host "3. Usando vswhere (ferramenta oficial Microsoft)..." -ForegroundColor Cyan

$vswherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswherePath) {
    try {
        $vsInstances = & $vswherePath -products * -requires Microsoft.VisualStudio.Workload.ManagedDesktop -format json | ConvertFrom-Json
        
        if ($vsInstances) {
            foreach ($instance in $vsInstances) {
                $devenvPath = Join-Path $instance.installationPath "Common7\IDE\devenv.exe"
                Write-Host "   ✓ Encontrado via vswhere:" -ForegroundColor Green
                Write-Host "     Nome: $($instance.displayName)" -ForegroundColor White
                Write-Host "     Versão: $($instance.installationVersion)" -ForegroundColor White
                Write-Host "     Caminho: $devenvPath" -ForegroundColor White
                Write-Host ""
            }
        } else {
            Write-Host "   ⚠ Nenhuma instância encontrada via vswhere" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ⚠ Erro ao executar vswhere: $($_.Exception.Message)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠ vswhere.exe não encontrado" -ForegroundColor Yellow
}

# 4. PROCURAR NO MENU INICIAR
Write-Host "4. Verificando atalhos no Menu Iniciar..." -ForegroundColor Cyan

$startMenuPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
)

foreach ($startPath in $startMenuPaths) {
    if (Test-Path $startPath) {
        $vsShortcuts = Get-ChildItem -Path $startPath -Recurse -Filter "*Visual Studio*" -ErrorAction SilentlyContinue
        foreach ($shortcut in $vsShortcuts) {
            if ($shortcut.Name -match "Visual Studio.*2022") {
                Write-Host "   ✓ Atalho encontrado: $($shortcut.Name)" -ForegroundColor Green
                Write-Host "     Local: $($shortcut.FullName)" -ForegroundColor White
            }
        }
    }
}

# 5. VERIFICAR SE VISUAL STUDIO INSTALLER ESTÁ DISPONÍVEL
Write-Host ""
Write-Host "5. Verificando Visual Studio Installer..." -ForegroundColor Cyan

$installerPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"
if (Test-Path $installerPath) {
    Write-Host "   ✓ Visual Studio Installer encontrado" -ForegroundColor Green
    Write-Host "     Caminho: $installerPath" -ForegroundColor White
    Write-Host "   💡 Você pode usar o Installer para verificar/reparar a instalação" -ForegroundColor Cyan
} else {
    Write-Host "   ✗ Visual Studio Installer não encontrado" -ForegroundColor Red
}

# 6. RESUMO E PRÓXIMOS PASSOS
Write-Host ""
Write-Host "=== RESUMO ===" -ForegroundColor Green

if ($foundPaths.Count -gt 0) {
    Write-Host "✓ Visual Studio encontrado!" -ForegroundColor Green
    Write-Host ""
    Write-Host "COMO ABRIR:" -ForegroundColor Yellow
    
    $communityPath = $foundPaths | Where-Object { $_.Edition -eq "Community" } | Select-Object -First 1
    if ($communityPath) {
        Write-Host "1. MÉTODO AUTOMÁTICO:" -ForegroundColor Cyan
        Write-Host "   Execute: .\abrir-vs-como-admin.ps1" -ForegroundColor White
        Write-Host ""
        Write-Host "2. MÉTODO MANUAL:" -ForegroundColor Cyan
        Write-Host "   - Pressione Windows + R" -ForegroundColor White
        Write-Host "   - Cole: `"$($communityPath.Path)`"" -ForegroundColor White
        Write-Host "   - Pressione Ctrl+Shift+Enter (para abrir como admin)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "3. PELO MENU INICIAR:" -ForegroundColor Cyan
    Write-Host "   - Pressione Windows" -ForegroundColor White
    Write-Host "   - Digite: Visual Studio" -ForegroundColor White
    Write-Host "   - Clique direito > Executar como administrador" -ForegroundColor White
    
} else {
    Write-Host "✗ Visual Studio Community 2022 não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "POSSÍVEIS SOLUÇÕES:" -ForegroundColor Yellow
    Write-Host "1. A atualização pode não ter terminado completamente" -ForegroundColor White
    Write-Host "2. Pode ter sido desinstalado durante a atualização" -ForegroundColor White
    Write-Host "3. Pode estar em um local não padrão" -ForegroundColor White
    Write-Host ""
    Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Cyan
    Write-Host "1. Abra o Visual Studio Installer (se disponível)" -ForegroundColor White
    Write-Host "2. Verifique se Community 2022 está listado" -ForegroundColor White
    Write-Host "3. Se não estiver, reinstale o Visual Studio Community 2022" -ForegroundColor White
    
    if (Test-Path $installerPath) {
        Write-Host ""
        Write-Host "ABRIR INSTALLER AGORA? (s/n)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq "s" -or $response -eq "S") {
            Start-Process $installerPath -Verb RunAs
        }
    }
}

Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")