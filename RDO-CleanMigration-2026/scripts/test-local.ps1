# Build + lembrete de teste local — RdoApp.Core (Migration2Core)
$ErrorActionPreference = "Stop"

$ProjectRoot = Join-Path $PSScriptRoot "..\RDO-CleanMigration-2026\RdoApp.Core"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

Write-Host "Projeto: $ProjectRoot" -ForegroundColor Cyan

Push-Location $ProjectRoot
try {
    dotnet restore
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    dotnet build --no-restore
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host ""
    Write-Host "Build OK. Subir o app:" -ForegroundColor Green
    Write-Host "  dotnet run --launch-profile https"
    Write-Host ""
    Write-Host "URLs:" -ForegroundColor Green
    Write-Host "  https://localhost:7176/Account/Login"
    Write-Host "  http://localhost:5229/Account/Login"
    Write-Host ""
    Write-Host "Checklist Fase 0: Login -> Escolher obra -> /Tarefa/Cards"
    Write-Host "Guia completo: RDO-CleanMigration-2026/HOMOLOGACAO_LOCAL.md"
}
finally {
    Pop-Location
}
