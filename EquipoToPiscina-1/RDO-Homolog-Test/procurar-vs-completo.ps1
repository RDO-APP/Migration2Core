# PROCURAR VISUAL STUDIO EM TODOS OS LOCAIS POSSIVEIS

Write-Host "=== PROCURANDO VISUAL STUDIO EM TODOS OS LOCAIS ===" -ForegroundColor Yellow
Write-Host ""

# Caminhos possiveis (portugues e ingles)
$caminhos = @(
    "C:\Arquivos de Programas\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "C:\Arquivos de Programas (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
)

$encontrado = $false
$caminhoEncontrado = ""
$versaoEncontrada = ""

foreach ($caminho in $caminhos) {
    Write-Host "Verificando: $caminho" -ForegroundColor Gray
    
    if (Test-Path $caminho) {
        Write-Host "ENCONTRADO!" -ForegroundColor Green
        $encontrado = $true
        $caminhoEncontrado = $caminho
        
        if ($caminho -like "*Community*") {
            $versaoEncontrada = "Community"
        } elseif ($caminho -like "*Professional*") {
            $versaoEncontrada = "Professional"
        }
        
        break
    } else {
        Write-Host "Nao encontrado" -ForegroundColor Red
    }
}

Write-Host ""

if ($encontrado) {
    Write-Host "=== VISUAL STUDIO $versaoEncontrada ENCONTRADO! ===" -ForegroundColor Green
    Write-Host "Caminho: $caminhoEncontrado" -ForegroundColor White
    Write-Host ""
    Write-Host "ABRINDO COMO ADMINISTRADOR..." -ForegroundColor Cyan
    
    try {
        Start-Process -FilePath $caminhoEncontrado -Verb RunAs
        Write-Host "Visual Studio $versaoEncontrada aberto como Administrador!" -ForegroundColor Green
        Write-Host ""
        Write-Host "PROXIMOS PASSOS CRITICOS:" -ForegroundColor Yellow
        Write-Host "1. Verifique se tem '(Administrador)' no titulo da janela" -ForegroundColor White
        Write-Host "2. Abra: rdoappProject\rdoappProject.sln" -ForegroundColor White
        Write-Host "3. Compilar > Limpar Solucao" -ForegroundColor White
        Write-Host "4. Compilar > Recompilar Solucao" -ForegroundColor White
        Write-Host "5. F5 para executar" -ForegroundColor White
        Write-Host "6. Teste salvar laudo e verifique F12 Console" -ForegroundColor White
        Write-Host ""
        Write-Host "DEVE APARECER NO F12:" -ForegroundColor Green
        Write-Host "=== TESTE RECOMPILACAO FUNCIONANDO ===" -ForegroundColor Cyan
        Write-Host "BACKEND RECEBEU CHAMADA - IdTarefa: [numero]" -ForegroundColor Cyan
        
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
    Write-Host "=== VISUAL STUDIO NAO ENCONTRADO EM NENHUM LOCAL ===" -ForegroundColor Red
    Write-Host ""
    Write-Host "CAMINHOS VERIFICADOS:" -ForegroundColor Yellow
    foreach ($caminho in $caminhos) {
        Write-Host "- $caminho" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "SOLUCOES:" -ForegroundColor Yellow
    Write-Host "1. Abra o Visual Studio Installer" -ForegroundColor White
    Write-Host "2. Verifique se Community esta instalado" -ForegroundColor White
    Write-Host "3. Se nao estiver, instale o Community" -ForegroundColor White
    Write-Host "4. Se estiver, clique em 'Iniciar' no Installer" -ForegroundColor White
}

Write-Host ""