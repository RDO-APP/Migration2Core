# Script DEFINITIVO para resolver problemas de processo bloqueado
Write-Host "🛑 MATANDO TODOS OS PROCESSOS RDOAPP..." -ForegroundColor Red

# Matar TODOS os processos relacionados - mais agressivo
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | ForEach-Object {
    Write-Host "Matando processo: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Yellow
    Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
}

# Matar processos dotnet que podem estar rodando o projeto
Get-Process dotnet -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.MainWindowTitle -like "*RdoApp*" -or $_.CommandLine -like "*RdoApp*") {
        Write-Host "Matando dotnet: PID $($_.Id)" -ForegroundColor Yellow
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}

# Aguardar processos terminarem
Write-Host "⏳ Aguardando processos terminarem..." -ForegroundColor Yellow
Start-Sleep 3

# Forçar remoção de arquivos bloqueados
Write-Host "🗑️ Removendo arquivos bloqueados..." -ForegroundColor Yellow
Remove-Item -Path "bin\Debug\net8.0\RdoApp.Core.exe" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "obj\Debug\net8.0\apphost.exe" -Force -ErrorAction SilentlyContinue

Write-Host "🧹 Limpando projeto..." -ForegroundColor Yellow
dotnet clean

Write-Host "🔨 Compilando..." -ForegroundColor Yellow  
dotnet build

if ($LASTEXITCODE -eq 0) {
    Write-Host "🚀 Iniciando aplicação na porta 8000..." -ForegroundColor Green
    Write-Host "📱 Acesse: http://localhost:8000" -ForegroundColor Cyan
    dotnet run --urls "http://localhost:8000"
} else {
    Write-Host "❌ Erro na compilação!" -ForegroundColor Red
    Write-Host "💡 Tente fechar o Visual Studio e rodar novamente" -ForegroundColor Yellow
}