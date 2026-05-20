# VERIFICAR SE VISUAL STUDIO COMMUNITY ESTA INSTALADO

Write-Host "=== VERIFICANDO VISUAL STUDIO COMMUNITY 2022 ===" -ForegroundColor Yellow
Write-Host ""

# 1. VERIFICAR CAMINHOS PADRAO
Write-Host "1. Verificando caminhos padrao..." -ForegroundColor Cyan

$vsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
)

$found = $false
foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        $version = (Get-ItemProperty $path).VersionInfo.FileVersion
        Write-Host "   ENCONTRADO: Visual Studio Community 2022" -ForegroundColor Green
        Write-Host "   Caminho: $path" -ForegroundColor White
        Write-Host "   Versao: $version" -ForegroundColor White
        $found = $true
        break
    }
}

if (-not $found) {
    Write-Host "   NAO ENCONTRADO nos caminhos padrao" -ForegroundColor Red
}

# 2. VERIFICAR VISUAL STUDIO INSTALLER
Write-Host ""
Write-Host "2. Verificando Visual Studio Installer..." -ForegroundColor Cyan

$installerPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vs_installer.exe"
if (Test-Path $installerPath) {
    Write-Host "   ENCONTRADO: Visual Studio Installer" -ForegroundColor Green
    Write-Host "   Caminho: $installerPath" -ForegroundColor White
    
    # Verificar vswhere
    $vswherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswherePath) {
        Write-Host "   Usando vswhere para detectar instalacoes..." -ForegroundColor Cyan
        try {
            $vsInstances = & $vswherePath -products * -format json | ConvertFrom-Json
            if ($vsInstances) {
                foreach ($instance in $vsInstances) {
                    if ($instance.productId -eq "Microsoft.VisualStudio.Product.Community") {
                        Write-Host "   ENCONTRADO via vswhere: Visual Studio Community" -ForegroundColor Green
                        Write-Host "   Nome: $($instance.displayName)" -ForegroundColor White
                        Write-Host "   Versao: $($instance.installationVersion)" -ForegroundColor White
                        Write-Host "   Caminho: $($instance.installationPath)" -ForegroundColor White
                        $found = $true
                    }
                }
            }
        } catch {
            Write-Host "   Erro ao executar vswhere" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "   NAO ENCONTRADO: Visual Studio Installer" -ForegroundColor Red
}

# 3. VERIFICAR PROCESSOS RODANDO
Write-Host ""
Write-Host "3. Verificando processos do Visual Studio..." -ForegroundColor Cyan

$vsProcesses = Get-Process -Name "devenv" -ErrorAction SilentlyContinue
if ($vsProcesses) {
    Write-Host "   RODANDO: Visual Studio esta executando" -ForegroundColor Green
    foreach ($process in $vsProcesses) {
        Write-Host "   PID: $($process.Id) - $($process.ProcessName)" -ForegroundColor White
    }
} else {
    Write-Host "   NAO RODANDO: Nenhum processo Visual Studio ativo" -ForegroundColor Yellow
}

# 4. VERIFICAR ATALHOS NO MENU INICIAR
Write-Host ""
Write-Host "4. Verificando atalhos no Menu Iniciar..." -ForegroundColor Cyan

$startMenuPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
)

$shortcutsFound = $false
foreach ($startPath in $startMenuPaths) {
    if (Test-Path $startPath) {
        $vsShortcuts = Get-ChildItem -Path $startPath -Recurse -Filter "*Visual Studio*2022*" -ErrorAction SilentlyContinue
        foreach ($shortcut in $vsShortcuts) {
            if ($shortcut.Name -match "Community") {
                Write-Host "   ENCONTRADO: Atalho no Menu Iniciar" -ForegroundColor Green
                Write-Host "   Nome: $($shortcut.Name)" -ForegroundColor White
                $shortcutsFound = $true
            }
        }
    }
}

if (-not $shortcutsFound) {
    Write-Host "   NAO ENCONTRADO: Atalhos no Menu Iniciar" -ForegroundColor Yellow
}

# 5. RESUMO
Write-Host ""
Write-Host "=== RESUMO ===" -ForegroundColor Green

if ($found) {
    Write-Host "VISUAL STUDIO COMMUNITY 2022 ESTA INSTALADO" -ForegroundColor Green
    Write-Host ""
    Write-Host "STATUS: Aguardando atualizacao de pacotes..." -ForegroundColor Yellow
    Write-Host "Isso e normal apos uma atualizacao do Visual Studio" -ForegroundColor White
    Write-Host ""
    Write-Host "QUANDO A ATUALIZACAO TERMINAR:" -ForegroundColor Cyan
    Write-Host "1. Feche o Visual Studio completamente" -ForegroundColor White
    Write-Host "2. Abra como Administrador" -ForegroundColor White
    Write-Host "3. Abra o projeto: rdoappProject\rdoappProject.sln" -ForegroundColor White
    Write-Host "4. Recompile completamente" -ForegroundColor White
} else {
    Write-Host "VISUAL STUDIO COMMUNITY 2022 NAO ENCONTRADO" -ForegroundColor Red
    Write-Host ""
    Write-Host "POSSIBILIDADES:" -ForegroundColor Yellow
    Write-Host "1. Ainda esta sendo instalado/atualizado" -ForegroundColor White
    Write-Host "2. Instalacao foi corrompida" -ForegroundColor White
    Write-Host "3. Precisa ser reinstalado" -ForegroundColor White
    
    if (Test-Path $installerPath) {
        Write-Host ""
        Write-Host "Use o Visual Studio Installer para verificar o status" -ForegroundColor Cyan
    }
}

Write-Host ""