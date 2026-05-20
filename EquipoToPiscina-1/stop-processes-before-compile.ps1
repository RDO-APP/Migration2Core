# PREVENÇÃO: Execute sempre antes de compilar
# Para evitar o erro "arquivo bloqueado por processo"

Write-Host "🛡️  PARANDO PROCESSOS ANTES DE COMPILAR..." -ForegroundColor Cyan

# Parar todos os processos que podem bloquear a compilação
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue  
Get-Process -Name "iisexpress" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Aguardar um momento
Start-Sleep -Seconds 2

Write-Host "✅ PROCESSOS PARADOS - SEGURO PARA COMPILAR!" -ForegroundColor Green
Write-Host ""
Write-Host "Agora você pode executar:" -ForegroundColor White
Write-Host "   dotnet clean" -ForegroundColor Yellow
Write-Host "   dotnet build" -ForegroundColor Yellow
Write-Host "   dotnet run" -ForegroundColor Yellow