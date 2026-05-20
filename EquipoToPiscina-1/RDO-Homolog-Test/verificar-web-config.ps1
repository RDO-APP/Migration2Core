Write-Host "Verificando Web.config..." -ForegroundColor Yellow

$content = Get-Content "RDO-Homolog-Test\rdoappProject\Web.config" -Raw

if ($content -match "system\.codedom") {
    Write-Host "❌ system.codedom ainda presente!" -ForegroundColor Red
} else {
    Write-Host "✅ system.codedom removido!" -ForegroundColor Green
}

if ($content -match "Microsoft\.Web\.Infrastructure") {
    Write-Host "✅ Microsoft.Web.Infrastructure presente!" -ForegroundColor Green
} else {
    Write-Host "❌ Microsoft.Web.Infrastructure ausente!" -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTE AGORA:" -ForegroundColor Yellow
Write-Host "1. Rebuild Solution no Visual Studio" -ForegroundColor White
Write-Host "2. Pressionar F5" -ForegroundColor White