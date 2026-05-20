# ABRIR VISUAL STUDIO COMMUNITY 2022 COMO ADMINISTRADOR
# Este script abre automaticamente o VS como administrador com o projeto

Write-Host "=== ABRINDO VISUAL STUDIO COMO ADMINISTRADOR ===" -ForegroundColor Yellow
Write-Host ""

# Verificar se o script está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "⚠ Este script precisa rodar como administrador para abrir o VS como admin" -ForegroundColor Yellow
    Write-Host "Relançando como administrador..." -ForegroundColor Cyan
    
    # Relançar como administrador
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process PowerShell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

Write-Host "✓ Script rodando como administrador" -ForegroundColor Green

# Procurar Visual Studio Community 2022
$vsPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
)

$vsPath = $null
foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        $vsPath = $path
        break
    }
}

if (-not $vsPath) {
    Write-Host "✗ Visual Studio Community 2022 não encontrado!" -ForegroundColor Red
    Write-Host "Caminhos verificados:" -ForegroundColor Yellow
    foreach ($path in $vsPaths) {
        Write-Host "  - $path" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Instale o Visual Studio Community 2022 ou ajuste o caminho no script." -ForegroundColor Yellow
    pause
    exit
}

Write-Host "✓ Visual Studio encontrado: $vsPath" -ForegroundColor Green

# Verificar se o projeto existe
$projectPath = "rdoappProject\rdoappProject.sln"
if (-not (Test-Path $projectPath)) {
    Write-Host "⚠ Arquivo de projeto não encontrado: $projectPath" -ForegroundColor Yellow
    Write-Host "Abrindo Visual Studio sem projeto específico..." -ForegroundColor Cyan
    $projectPath = $null
}

# Fechar instâncias existentes do Visual Studio
Write-Host "Fechando instâncias existentes do Visual Studio..." -ForegroundColor Cyan
Get-Process -Name "devenv" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Abrir Visual Studio como administrador
Write-Host "Abrindo Visual Studio Community 2022 como Administrador..." -ForegroundColor Green

try {
    if ($projectPath) {
        # Abrir com projeto específico
        $fullProjectPath = (Resolve-Path $projectPath).Path
        Write-Host "Abrindo projeto: $fullProjectPath" -ForegroundColor White
        Start-Process -FilePath $vsPath -ArgumentList "`"$fullProjectPath`"" -Verb RunAs
    } else {
        # Abrir sem projeto
        Start-Process -FilePath $vsPath -Verb RunAs
    }
    
    Write-Host ""
    Write-Host "✓ Visual Studio sendo iniciado como Administrador!" -ForegroundColor Green
    Write-Host ""
    Write-Host "VERIFICAÇÃO:" -ForegroundColor Yellow
    Write-Host "Quando o Visual Studio abrir, verifique se a barra de título contém:" -ForegroundColor White
    Write-Host "  'Microsoft Visual Studio Community 2022 (Administrador)'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Se não mostrar '(Administrador)', feche e tente novamente." -ForegroundColor Yellow
    
} catch {
    Write-Host "✗ Erro ao abrir Visual Studio: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Tente abrir manualmente:" -ForegroundColor Yellow
    Write-Host "1. Pressione Windows + R" -ForegroundColor White
    Write-Host "2. Digite: $vsPath" -ForegroundColor White
    Write-Host "3. Pressione Ctrl+Shift+Enter (para abrir como admin)" -ForegroundColor White
}

Write-Host ""
Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")