# VERIFICAR SE VISUAL STUDIO FOI ATUALIZADO COM SUCESSO

Write-Host "=== VERIFICAÇÃO PÓS-ATUALIZAÇÃO VISUAL STUDIO ===" -ForegroundColor Yellow
Write-Host ""

# 1. VERIFICAR VERSÃO DO VISUAL STUDIO
Write-Host "1. Verificando versão do Visual Studio..." -ForegroundColor Cyan

$vsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
if (Test-Path $vsPath) {
    $vsVersion = (Get-ItemProperty $vsPath).VersionInfo.FileVersion
    Write-Host "   ✓ Visual Studio Community 2022 encontrado" -ForegroundColor Green
    Write-Host "   Versão: $vsVersion" -ForegroundColor White
    
    # Verificar se é uma versão recente (17.8+)
    $versionParts = $vsVersion.Split('.')
    $majorMinor = [decimal]"$($versionParts[0]).$($versionParts[1])"
    
    if ($majorMinor -ge 17.8) {
        Write-Host "   ✓ Versão atualizada (17.8+)" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Versão pode estar desatualizada" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ Visual Studio Community 2022 não encontrado" -ForegroundColor Red
}

# 2. VERIFICAR COMPONENTES .NET
Write-Host ""
Write-Host "2. Verificando componentes .NET..." -ForegroundColor Cyan

$dotnetVersions = @()
try {
    $dotnetInfo = & dotnet --list-sdks 2>$null
    if ($dotnetInfo) {
        Write-Host "   ✓ .NET SDK instalado" -ForegroundColor Green
        $dotnetInfo | ForEach-Object { Write-Host "     $_" -ForegroundColor White }
    }
} catch {
    Write-Host "   ⚠ .NET SDK não encontrado via linha de comando" -ForegroundColor Yellow
}

# Verificar .NET Framework 4.8
$net48Path = "${env:ProgramFiles(x86)}\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8"
if (Test-Path $net48Path) {
    Write-Host "   ✓ .NET Framework 4.8 instalado" -ForegroundColor Green
} else {
    Write-Host "   ⚠ .NET Framework 4.8 não encontrado" -ForegroundColor Yellow
}

# 3. VERIFICAR WORKLOADS DO VISUAL STUDIO
Write-Host ""
Write-Host "3. Verificando workloads essenciais..." -ForegroundColor Cyan

$workloadsPath = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\Extensions\Microsoft"
if (Test-Path $workloadsPath) {
    Write-Host "   ✓ Pasta de extensões encontrada" -ForegroundColor Green
    
    # Verificar se tem desenvolvimento web
    $webDevPath = "$workloadsPath\Web"
    if (Test-Path $webDevPath) {
        Write-Host "   ✓ Desenvolvimento Web instalado" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Desenvolvimento Web pode não estar instalado" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ⚠ Pasta de extensões não encontrada" -ForegroundColor Yellow
}

# 4. VERIFICAR PROCESSOS ANTIGOS
Write-Host ""
Write-Host "4. Verificando processos antigos..." -ForegroundColor Cyan

$oldProcesses = @("devenv", "iisexpress", "w3wp", "msbuild")
$foundOldProcesses = @()

foreach ($process in $oldProcesses) {
    $running = Get-Process -Name $process -ErrorAction SilentlyContinue
    if ($running) {
        $foundOldProcesses += $process
    }
}

if ($foundOldProcesses.Count -eq 0) {
    Write-Host "   ✓ Nenhum processo antigo rodando" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Processos antigos encontrados: $($foundOldProcesses -join ', ')" -ForegroundColor Yellow
    Write-Host "   Recomendado reiniciar o computador após atualização" -ForegroundColor Yellow
}

# 5. VERIFICAR CACHE LIMPO
Write-Host ""
Write-Host "5. Verificando se cache foi limpo..." -ForegroundColor Cyan

$projectBin = "rdoappProject\bin"
$projectObj = "rdoappProject\obj"

if (-not (Test-Path $projectBin)) {
    Write-Host "   ✓ Pasta bin/ não existe (limpa)" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Pasta bin/ ainda existe" -ForegroundColor Yellow
}

if (-not (Test-Path $projectObj)) {
    Write-Host "   ✓ Pasta obj/ não existe (limpa)" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Pasta obj/ ainda existe" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== RESUMO DA VERIFICAÇÃO ===" -ForegroundColor Green
Write-Host ""
Write-Host "PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Se tudo estiver ✓, execute: .\force-backend-rebuild.ps1" -ForegroundColor White
Write-Host "2. Execute: .\test-backend-debug.ps1" -ForegroundColor White
Write-Host "3. Abra VS Community 2022 COMO ADMINISTRADOR" -ForegroundColor White
Write-Host "4. Recompile o projeto completamente" -ForegroundColor White
Write-Host "5. Teste o salvamento do laudo" -ForegroundColor White
Write-Host ""
Write-Host "Se houver ⚠ warnings, considere reiniciar o computador primeiro." -ForegroundColor Yellow