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

# client/ fica ao lado de scripts/ (nao dentro de RDO-CleanMigration-2026/RdoApp.Core)
$ClientRoot = Join-Path $PSScriptRoot "..\client"
if (-not (Test-Path $ClientRoot)) {
    throw "Pasta client nao encontrada: $ClientRoot"
}
$ClientRoot = (Resolve-Path $ClientRoot).Path
Push-Location $ClientRoot
try {
    Write-Host "Client:  $ClientRoot" -ForegroundColor Cyan
    npm run build
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}

Push-Location $ProjectRoot
try {
    dotnet publish -c Release -r win-x64 --self-contained true -o $OutDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host ""
    Write-Host "Publish OK." -ForegroundColor Green
    $ZipPath = Join-Path (Split-Path $OutDir -Parent) "rdoapp_core.zip"
    if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
    Compress-Archive -Path (Join-Path $OutDir "*") -DestinationPath $ZipPath -Force

    Write-Host "Zip:     $ZipPath" -ForegroundColor Green
    Write-Host "Proximo passo: copiar para EC2 (preservar appsettings.Staging.json com senha):" -ForegroundColor Yellow
    Write-Host "  C:\inetpub\wwwroot\homologacao\rdoapp_core"
    Write-Host "Guia: RDO-CleanMigration-2026\DEPLOY-HOMOLOG-EC2.md"
}
finally {
    Pop-Location
}
