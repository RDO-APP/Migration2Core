# ABRIR VISUAL STUDIO COMO ADMINISTRADOR

Write-Host "=== ABRINDO VS COMO ADMINISTRADOR ===" -ForegroundColor Yellow

# Caminho do Visual Studio
$vsPath1 = "${env:ProgramFiles}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
$vsPath2 = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"

$vsPath = $null
if (Test-Path $vsPath1) {
    $vsPath = $vsPath1
} elseif (Test-Path $vsPath2) {
    $vsPath = $vsPath2
}

if ($vsPath) {
    Write-Host "Visual Studio encontrado!" -ForegroundColor Green
    Write-Host "Caminho: $vsPath" -ForegroundColor White
    
    try {
        Write-Host "Abrindo como Administrador..." -ForegroundColor Cyan
        Start-Process -FilePath $vsPath -Verb RunAs
        
        Write-Host ""
        Write-Host "SUCESSO!" -ForegroundColor Green
        Write-Host "Visual Studio Community aberto como Administrador" -ForegroundColor White
        Write-Host ""
        Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
        Write-Host "1. Verifique se tem '(Administrador)' no titulo" -ForegroundColor White
        Write-Host "2. Abra o projeto: rdoappProject\rdoappProject.sln" -ForegroundColor White
        Write-Host "3. Compilar > Recompilar Solucao" -ForegroundColor White
        Write-Host "4. F5 para executar e testar" -ForegroundColor White
        
    } catch {
        Write-Host "Erro ao abrir: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Visual Studio Community nao encontrado!" -ForegroundColor Red
    Write-Host "Caminhos verificados:" -ForegroundColor Yellow
    Write-Host "- $vsPath1" -ForegroundColor White
    Write-Host "- $vsPath2" -ForegroundColor White
}

Write-Host ""