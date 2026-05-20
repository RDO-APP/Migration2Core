# CHECK APPLICATION STATUS
# Verificar se a aplicação está rodando e abrir browser manualmente

Write-Host "VERIFICANDO STATUS DA APLICACAO..." -ForegroundColor Green
Write-Host "Date: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

# Check if dotnet process is running
Write-Host "STEP 1: VERIFICANDO PROCESSOS DOTNET" -ForegroundColor Magenta
$dotnetProcesses = Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue
if ($dotnetProcesses) {
    Write-Host "Aplicacao RdoApp.Core esta rodando!" -ForegroundColor Green
    foreach ($process in $dotnetProcesses) {
        Write-Host "  PID: $($process.Id) - Memoria: $([math]::Round($process.WorkingSet / 1MB, 2)) MB" -ForegroundColor Green
    }
} else {
    Write-Host "Processo RdoApp.Core nao encontrado" -ForegroundColor Yellow
    
    # Check for generic dotnet processes
    $genericDotnet = Get-Process -Name "dotnet" -ErrorAction SilentlyContinue
    if ($genericDotnet) {
        Write-Host "Processos dotnet encontrados:" -ForegroundColor Yellow
        foreach ($process in $genericDotnet) {
            Write-Host "  PID: $($process.Id) - Memoria: $([math]::Round($process.WorkingSet / 1MB, 2)) MB" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# Check if ports are listening
Write-Host "STEP 2: VERIFICANDO PORTAS EM USO" -ForegroundColor Magenta
$commonPorts = @(5000, 5001, 7201, 7202, 8080, 8443)

foreach ($port in $commonPorts) {
    try {
        $connection = Test-NetConnection -ComputerName "localhost" -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
        if ($connection) {
            Write-Host "Porta $port: ATIVA (aplicacao pode estar aqui)" -ForegroundColor Green
        } else {
            Write-Host "Porta $port: Inativa" -ForegroundColor Gray
        }
    } catch {
        Write-Host "Porta $port: Erro ao verificar" -ForegroundColor Gray
    }
}

Write-Host ""

# Try to open browser manually
Write-Host "STEP 3: TENTANDO ABRIR BROWSER MANUALMENTE" -ForegroundColor Magenta

$urls = @(
    "https://localhost:7201",
    "http://localhost:5000",
    "https://localhost:5001",
    "http://localhost:7201"
)

foreach ($url in $urls) {
    Write-Host "Testando URL: $url" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri $url -Method Head -TimeoutSec 5 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "URL ATIVA: $url" -ForegroundColor Green
            Write-Host "Abrindo browser..." -ForegroundColor Green
            Start-Process $url
            break
        }
    } catch {
        Write-Host "URL nao responde: $url" -ForegroundColor Gray
    }
}

Write-Host ""

# Manual browser opening
Write-Host "STEP 4: ABERTURA MANUAL DO BROWSER" -ForegroundColor Magenta
Write-Host "Se a aplicacao estiver rodando, tente abrir manualmente:" -ForegroundColor Yellow
Write-Host ""
Write-Host "URLs para testar:" -ForegroundColor Cyan
Write-Host "1. https://localhost:7201" -ForegroundColor Cyan
Write-Host "2. http://localhost:5000" -ForegroundColor Cyan
Write-Host "3. https://localhost:5001" -ForegroundColor Cyan
Write-Host ""

$openManual = Read-Host "Deseja que eu tente abrir o browser agora? (y/n)"
if ($openManual -eq "y" -or $openManual -eq "Y") {
    Write-Host "Abrindo browsers para todas as URLs..." -ForegroundColor Green
    Start-Process "https://localhost:7201"
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:5000"
    Start-Sleep -Seconds 2
    Start-Process "https://localhost:5001"
}

Write-Host ""

# Check Visual Studio output
Write-Host "STEP 5: INFORMACOES DO VISUAL STUDIO" -ForegroundColor Magenta
Write-Host "Baseado na saida do VS que voce mostrou:" -ForegroundColor Yellow
Write-Host "- A aplicacao carregou com sucesso" -ForegroundColor Green
Write-Host "- Todos os assemblies foram carregados" -ForegroundColor Green
Write-Host "- Nao houve erros de inicializacao" -ForegroundColor Green
Write-Host "- O problema e apenas o browser nao abrir automaticamente" -ForegroundColor Yellow

Write-Host ""
Write-Host "SOLUCOES:" -ForegroundColor Cyan
Write-Host "1. Abra o browser manualmente e va para https://localhost:7201" -ForegroundColor Cyan
Write-Host "2. Verifique se o Windows Defender nao esta bloqueando" -ForegroundColor Cyan
Write-Host "3. Tente usar modo incognito no browser" -ForegroundColor Cyan
Write-Host "4. Verifique se ha algum popup de certificado SSL" -ForegroundColor Cyan

Write-Host ""
Write-Host "TESTE RAPIDO:" -ForegroundColor Yellow
Write-Host "1. Abra seu browser" -ForegroundColor Yellow
Write-Host "2. Digite: https://localhost:7201" -ForegroundColor Yellow
Write-Host "3. Se aparecer aviso de certificado, clique 'Avancado' > 'Continuar'" -ForegroundColor Yellow
Write-Host "4. Deve aparecer a tela de login do RDO" -ForegroundColor Yellow

Write-Host ""
Write-Host "Verificacao de status concluida!" -ForegroundColor Green