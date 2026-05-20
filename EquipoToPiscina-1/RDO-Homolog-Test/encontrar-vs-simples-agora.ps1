# ENCONTRAR VISUAL STUDIO EM PORTUGUES - VERSAO SIMPLES

Write-Host "=== PROCURANDO VISUAL STUDIO ===" -ForegroundColor Yellow
Write-Host ""

# Caminhos em portugues
$caminhos = @(
    "C:\Arquivos de Programas\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "C:\Arquivos de Programas (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
)

$encontrado = $false
$caminhoEncontrado = ""

foreach ($caminho in $caminhos) {
    Write-Host "Verificando: $caminho" -ForegroundColor Gray
    
    if (Test-Path $caminho) {
        Write-Host "ENCONTRADO!" -ForegroundColor Green
        $encontrado = $true
        $caminhoEncontrado = $caminho
        break
    } else {
        Write-Host "Nao encontrado" -ForegroundColor Red
    }
}

Write-Host ""

if ($encontrado) {
    Write-Host "=== VISUAL STUDIO ENCONTRADO! ===" -ForegroundColor Green
    Write-Host "Caminho: $caminhoEncontrado" -ForegroundColor White
    Write-Host ""
    Write-Host "ABRINDO COMO ADMINISTRADOR..." -ForegroundColor Cyan
    
    try {
        Start-Process -FilePath $caminhoEncontrado -Verb RunAs
        Write-Host "Visual Studio aberto como Administrador!" -ForegroundColor Green
        Write-Host ""
        Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
        Write-Host "1. Verifique se tem '(Administrador)' no titulo" -ForegroundColor White
        Write-Host "2. Abra o projeto: rdoappProject\rdoappProject.sln" -ForegroundColor White
        Write-Host "3. Compilar > Limpar Solucao" -ForegroundColor White
        Write-Host "4. Compilar > Recompilar Solucao" -ForegroundColor White
        Write-Host "5. F5 para executar e testar" -ForegroundColor White
        
    } catch {
        Write-Host "Erro ao abrir: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "ALTERNATIVA MANUAL:" -ForegroundColor Yellow
        Write-Host "1. Abra o Explorador de Arquivos" -ForegroundColor White
        Write-Host "2. Navegue ate: $caminhoEncontrado" -ForegroundColor White
        Write-Host "3. Clique direito em devenv.exe" -ForegroundColor White
        Write-Host "4. Executar como administrador" -ForegroundColor White
    }
    
} else {
    Write-Host "=== VISUAL STUDIO NAO ENCONTRADO ===" -ForegroundColor Red
    Write-Host ""
    Write-Host "CAMINHOS VERIFICADOS:" -ForegroundColor Yellow
    foreach ($caminho in $caminhos) {
        Write-Host "- $caminho" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "SOLUCAO: Use o Visual Studio Installer" -ForegroundColor Cyan
}

Write-Host ""