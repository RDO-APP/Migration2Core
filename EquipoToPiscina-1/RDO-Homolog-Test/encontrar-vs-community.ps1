# Script para encontrar especificamente Visual Studio COMMUNITY
Write-Host "=== PROCURANDO VISUAL STUDIO COMMUNITY ===" -ForegroundColor Yellow
Write-Host ""

# Verificar se VS Community está instalado
$communityPaths = @(
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe",
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"
)

$foundCommunity = $false

Write-Host "Procurando Visual Studio COMMUNITY..." -ForegroundColor Cyan
foreach ($path in $communityPaths) {
    Write-Host "Verificando: $path" -ForegroundColor Gray
    if (Test-Path $path) {
        Write-Host "✅ VISUAL STUDIO COMMUNITY ENCONTRADO!" -ForegroundColor Green
        Write-Host "📍 Local: $path" -ForegroundColor Green
        $foundCommunity = $true
        
        # Abrir VS Community com o projeto
        $projectPath = "RDO-Homolog-Test\rdoappProject\rdoappProject.sln"
        if (Test-Path $projectPath) {
            Write-Host "🚀 Abrindo projeto no VS Community..." -ForegroundColor Green
            Start-Process $path -ArgumentList $projectPath
            Write-Host "✅ Visual Studio Community deve abrir em alguns segundos!" -ForegroundColor Green
        } else {
            Write-Host "🚀 Abrindo VS Community..." -ForegroundColor Green
            Start-Process $path
        }
        break
    }
}

if (-not $foundCommunity) {
    Write-Host "❌ Visual Studio Community NÃO encontrado" -ForegroundColor Red
    Write-Host ""
    Write-Host "OPÇÕES:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1️⃣ PROCURAR NO MENU INICIAR:" -ForegroundColor Cyan
    Write-Host "   - Pressione Windows" -ForegroundColor White
    Write-Host "   - Digite: 'Visual Studio Community'" -ForegroundColor White
    Write-Host "   - Clique se aparecer na lista" -ForegroundColor White
    Write-Host ""
    Write-Host "2️⃣ USAR O VISUAL STUDIO QUE JÁ ABRIU:" -ForegroundColor Cyan
    Write-Host "   - O VS que abriu pode funcionar também" -ForegroundColor White
    Write-Host "   - Tente abrir o projeto nele" -ForegroundColor White
    Write-Host ""
    Write-Host "3️⃣ BAIXAR VS COMMUNITY (GRATUITO):" -ForegroundColor Cyan
    Write-Host "   - https://visualstudio.microsoft.com/pt-br/vs/community/" -ForegroundColor White
    Write-Host "   - Download gratuito da Microsoft" -ForegroundColor White
    Write-Host ""
    
    # Verificar outras versões instaladas
    Write-Host "OUTRAS VERSÕES ENCONTRADAS:" -ForegroundColor Yellow
    $otherVersions = @(
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
        "${env:ProgramFiles}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
    )
    
    foreach ($path in $otherVersions) {
        if (Test-Path $path) {
            $version = if ($path -match "Professional") { "Professional" } else { "Enterprise" }
            Write-Host "✅ Visual Studio $version encontrado: $path" -ForegroundColor Cyan
        }
    }
}

Write-Host ""
Write-Host "PRÓXIMO PASSO:" -ForegroundColor Yellow
Write-Host "Me diga qual Visual Studio você quer usar!" -ForegroundColor White