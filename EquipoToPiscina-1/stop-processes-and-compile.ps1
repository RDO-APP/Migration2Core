Write-Host "=== PARANDO PROCESSOS E COMPILANDO ===" -ForegroundColor Green
Write-Host ""

# Parar todos os processos RdoApp.Core
Write-Host "🛑 Parando processos RdoApp.Core..." -ForegroundColor Yellow
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Parar processos dotnet relacionados
Write-Host "🛑 Parando processos dotnet..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowTitle -like "*RdoApp*" } | Stop-Process -Force
Start-Sleep -Seconds 2

# Navegar para o projeto
Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Limpar build anterior
Write-Host "🧹 Limpando build anterior..." -ForegroundColor Cyan
dotnet clean --verbosity quiet

# Compilar
Write-Host "🔧 Compilando projeto..." -ForegroundColor Cyan
dotnet build --no-restore --verbosity minimal

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ COMPILACAO BEM-SUCEDIDA!" -ForegroundColor Green
    Write-Host ""
    Write-Host "=== PROXIMOS PASSOS ===" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 🚀 Abra o Visual Studio" -ForegroundColor White
    Write-Host "2. 🔥 Execute com F5" -ForegroundColor White
    Write-Host "3. 🌐 Teste o login:" -ForegroundColor White
    Write-Host ""
    Write-Host "   📧 CPF: 567.065.455-20" -ForegroundColor Green
    Write-Host "   🔑 Senha: RXL8DjdVj6Y=" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Sistema corrigido para aceitar col_st_admin = NULL" -ForegroundColor Green
    Write-Host "✅ Usuario 'Ricardo Freire' deve fazer login agora!" -ForegroundColor Green
    
} else {
    Write-Host ""
    Write-Host "❌ ERRO NA COMPILACAO!" -ForegroundColor Red
    Write-Host "Verifique os erros acima e tente novamente" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📍 Localizacao: $(Get-Location)" -ForegroundColor Gray