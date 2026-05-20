# Compilação Simples
Write-Host "COMPILANDO..." -ForegroundColor Green

Set-Location "rdoappProject"

# Limpar
Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "obj" -Recurse -Force -ErrorAction SilentlyContinue

# Compilar
$vs = "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.exe"
if (Test-Path $vs) {
    Write-Host "Compilando com Visual Studio..." -ForegroundColor Yellow
    & $vs "rdoappProject.csproj" /build Release
    
    if (Test-Path "bin") {
        Write-Host "✅ SUCESSO!" -ForegroundColor Green
        Write-Host "Aplicação compilada e pronta!" -ForegroundColor Yellow
    } else {
        Write-Host "❌ FALHOU" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Visual Studio não encontrado" -ForegroundColor Red
}

Set-Location ".."