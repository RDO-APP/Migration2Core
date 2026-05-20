# Recompilação Rápida
Write-Host "RECOMPILANDO RAPIDAMENTE..." -ForegroundColor Green

Set-Location "rdoappProject"

# Limpar bin e obj
Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "obj" -Recurse -Force -ErrorAction SilentlyContinue

# Tentar Visual Studio direto
$vs = "C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\devenv.exe"
if (Test-Path $vs) {
    Write-Host "Compilando com VS..." -ForegroundColor Yellow
    & $vs "rdoappProject.csproj" /build Release /out build.log
    
    if (Test-Path "bin") {
        Write-Host "SUCESSO! Aplicação compilada!" -ForegroundColor Green
        
        # Iniciar IIS Express
        $iis = "C:\Program Files\IIS Express\iisexpress.exe"
        if (-not (Test-Path $iis)) { $iis = "C:\Program Files (x86)\IIS Express\iisexpress.exe" }
        
        if (Test-Path $iis) {
            Write-Host "Iniciando em http://localhost:8080" -ForegroundColor Cyan
            & $iis /path:(Get-Location).Path /port:8080
        } else {
            Write-Host "Compilado! Abra no Visual Studio e pressione F5" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Erro na compilação" -ForegroundColor Red
    }
} else {
    Write-Host "Visual Studio não encontrado" -ForegroundColor Red
}

Set-Location ".."