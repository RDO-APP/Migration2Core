# PROCURAR VISUAL STUDIO NAS PASTAS EM PORTUGUES

Write-Host "=== PROCURANDO VISUAL STUDIO ===" -ForegroundColor Yellow
Write-Host "Verificando pastas em portugues..." -ForegroundColor Cyan
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
        Write-Host "✓ ENCONTRADO!" -ForegroundColor Green
        Write-Host "  Caminho: $caminho" -ForegroundColor White
        $encontrado = $true
        $caminhoEncontrado = $caminho
        
        # Obter informacoes do arquivo
        try {
            $info = Get-ItemProperty $caminho
            Write-Host "  Versao: $($info.VersionInfo.FileVersion)" -ForegroundColor White
            Write-Host "  Tamanho: $([math]::Round($info.Length / 1MB, 2)) MB" -ForegroundColor White
        } catch {
            Write-Host "  (Informacoes nao disponiveis)" -ForegroundColor Gray
        }
        
        break
    } else {
        Write-Host "  Nao encontrado" -ForegroundColor Red
    }
}

Write-Host ""

if ($encontrado) {
    Write-Host "=== VISUAL STUDIO ENCONTRADO! ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "DESEJA ABRIR COMO ADMINISTRADOR AGORA? (s/n)" -ForegroundColor Yellow
    $resposta = Read-Host
    
    if ($resposta -eq "s" -or $resposta -eq "S") {
        Write-Host ""
        Write-Host "Abrindo Visual Studio como Administrador..." -ForegroundColor Cyan
        
        try {
            Start-Process -FilePath $caminhoEncontrado -Verb RunAs
            Write-Host "✓ Visual Studio aberto como Administrador!" -ForegroundColor Green
            Write-Host ""
            Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
            Write-Host "1. Verifique se tem '(Administrador)' no titulo" -ForegroundColor White
            Write-Host "2. Abra o projeto: rdoappProject\rdoappProject.sln" -ForegroundColor White
            Write-Host "3. Compilar > Recompilar Solucao" -ForegroundColor White
            Write-Host "4. F5 para executar e testar" -ForegroundColor White
            
        } catch {
            Write-Host "✗ Erro ao abrir: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host ""
            Write-Host "ALTERNATIVA MANUAL:" -ForegroundColor Yellow
            Write-Host "1. Abra o Explorador de Arquivos" -ForegroundColor White
            Write-Host "2. Navegue ate: $caminhoEncontrado" -ForegroundColor White
            Write-Host "3. Clique direito em devenv.exe" -ForegroundColor White
            Write-Host "4. Executar como administrador" -ForegroundColor White
        }
    } else {
        Write-Host ""
        Write-Host "OK! Para abrir manualmente:" -ForegroundColor Yellow
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
    Write-Host "POSSIBILIDADES:" -ForegroundColor Yellow
    Write-Host "1. Visual Studio nao esta instalado" -ForegroundColor White
    Write-Host "2. Esta instalado em local diferente" -ForegroundColor White
    Write-Host "3. Instalacao incompleta" -ForegroundColor White
    Write-Host ""
    Write-Host "SOLUCAO: Use o Visual Studio Installer para verificar" -ForegroundColor Cyan
}

Write-Host ""