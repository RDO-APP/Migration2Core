# Publish RdoApp.Core para copiar na EC2 (homolog.sistema.rdoapp.com.br / IIS porta 5081)
# Não inclui secrets — connection string na EC2 (appsettings.Production.json local ou variáveis IIS)
$ErrorActionPreference = "Stop"

$ProjectRoot = Join-Path $PSScriptRoot "..\RDO-CleanMigration-2026\RdoApp.Core"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$OutDir = (Join-Path (Split-Path $PSScriptRoot -Parent) "publish\homolog-ec2")

Write-Host "Projeto: $ProjectRoot" -ForegroundColor Cyan
Write-Host "Saida:   $OutDir" -ForegroundColor Cyan

if (Test-Path $OutDir) {
    Remove-Item -Recurse -Force $OutDir
}
New-Item -ItemType Directory -Path $OutDir | Out-Null

Push-Location $ProjectRoot
try {
    dotnet publish -c Release -r win-x64 --self-contained true -o $OutDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host ""
    Write-Host "Publish OK." -ForegroundColor Green
    Write-Host "Proximo passo: copiar pasta para EC2:" -ForegroundColor Yellow
    Write-Host "  C:\inetpub\wwwroot\homologacao\rdoapp_core"
    Write-Host "Guia: RDO-CleanMigration-2026\DEPLOY-HOMOLOG-EC2.md"
}
finally {
    Pop-Location
}
