# Script para encontrar e abrir Visual Studio Community
Write-Host "=== PROCURANDO VISUAL STUDIO COMMUNITY ===" -ForegroundColor Yellow
Write-Host ""

# Locais comuns onde o Visual Studio pode estar instalado
$possiblePaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe"
)

$found = $false

Write-Host "Verificando locais comuns..." -ForegroundColor Cyan
foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        Write-Host "✅ ENCONTRADO: $path" -ForegroundColor Green
        $found = $true
        
        # Tentar abrir o projeto
        $projectPath = "RDO-Homolog-Test\rdoappProject\rdoappProject.sln"
        if (Test-Path $projectPath) {
            Write-Host "🚀 Abrindo projeto: $projectPath" -ForegroundColor Green
            Start-Process $path -ArgumentList $projectPath
            Write-Host "✅ Visual Studio deve abrir em alguns segundos..." -ForegroundColor Green
        } else {
            Write-Host "⚠️ Projeto não encontrado: $projectPath" -ForegroundColor Yellow
            Write-Host "🚀 Abrindo Visual Studio sem projeto..." -ForegroundColor Cyan
            Start-Process $path
        }
        break
    }
}

if (-not $found) {
    Write-Host "❌ Visual Studio Community não encontrado nos locais padrão" -ForegroundColor Red
    Write-Host ""
    Write-Host "OPÇÕES ALTERNATIVAS:" -ForegroundColor Yellow
    Write-Host "1. Procurar no Menu Iniciar por 'Visual Studio'" -ForegroundColor White
    Write-Host "2. Verificar se está instalado em outro local" -ForegroundColor White
    Write-Host "3. Baixar e instalar Visual Studio Community 2022" -ForegroundColor White
    Write-Host ""
    Write-Host "BUSCA MANUAL:" -ForegroundColor Yellow
    Write-Host "Pressione Windows + R, digite 'devenv' e pressione Enter" -ForegroundColor White
    Write-Host ""
    
    # Tentar abrir pelo comando do sistema
    Write-Host "Tentando abrir pelo comando do sistema..." -ForegroundColor Cyan
    try {
        Start-Process "devenv" -ErrorAction Stop
        Write-Host "✅ Visual Studio encontrado pelo comando do sistema!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Comando 'devenv' não encontrado" -ForegroundColor Red
        Write-Host ""
        Write-Host "DOWNLOAD VISUAL STUDIO COMMUNITY:" -ForegroundColor Yellow
        Write-Host "https://visualstudio.microsoft.com/pt-br/vs/community/" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "DEPOIS QUE ABRIR O VISUAL STUDIO:" -ForegroundColor Yellow
Write-Host "1. File > Open > Project/Solution" -ForegroundColor White
Write-Host "2. Navegar até: RDO-Homolog-Test\rdoappProject\rdoappProject.sln" -ForegroundColor White
Write-Host "3. Pressionar F5 para executar" -ForegroundColor White