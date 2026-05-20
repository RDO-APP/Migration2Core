# Testar Aplicação Agora
Write-Host "TESTANDO APLICAÇÃO..." -ForegroundColor Green

Set-Location "rdoappProject"

# Verificar se já tem bin
if (Test-Path "bin") {
    Write-Host "Encontrou pasta bin - tentando iniciar..." -ForegroundColor Yellow
    
    # Tentar IIS Express
    $iis = "C:\Program Files\IIS Express\iisexpress.exe"
    if (-not (Test-Path $iis)) { $iis = "C:\Program Files (x86)\IIS Express\iisexpress.exe" }
    
    if (Test-Path $iis) {
        Write-Host "Iniciando aplicação em http://localhost:8080" -ForegroundColor Cyan
        Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Gray
        & $iis /path:(Get-Location).Path /port:8080
    } else {
        Write-Host "IIS Express não encontrado" -ForegroundColor Red
        Write-Host "Abra o Visual Studio e pressione F5 para testar" -ForegroundColor Yellow
    }
} else {
    Write-Host "Pasta bin não existe - precisa compilar primeiro" -ForegroundColor Red
    Write-Host "Abra o Visual Studio, carregue o projeto e compile (Ctrl+Shift+B)" -ForegroundColor Yellow
}

Set-Location ".."