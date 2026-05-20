Write-Host "Procurando Visual Studio..." -ForegroundColor Yellow

# Verificar VS 2022
$vs2022Community = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
$vs2022Pro = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"

if (Test-Path $vs2022Community) {
    Write-Host "✅ VS 2022 Community encontrado!" -ForegroundColor Green
} else {
    Write-Host "❌ VS 2022 Community não encontrado" -ForegroundColor Red
}

if (Test-Path $vs2022Pro) {
    Write-Host "✅ VS 2022 Professional encontrado!" -ForegroundColor Green
} else {
    Write-Host "❌ VS 2022 Professional não encontrado" -ForegroundColor Red
}

Write-Host ""
Write-Host "POSSÍVEIS MOTIVOS:" -ForegroundColor Yellow
Write-Host "1. VS Community foi atualizado e mudou de lugar" -ForegroundColor White
Write-Host "2. Foi desinstalado acidentalmente" -ForegroundColor White
Write-Host "3. Instalação corrompida" -ForegroundColor White

Write-Host ""
Write-Host "ENQUANTO BAIXA O NOVO:" -ForegroundColor Cyan
Write-Host "Use o Visual Studio que já abriu!" -ForegroundColor White