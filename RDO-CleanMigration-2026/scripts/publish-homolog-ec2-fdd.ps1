# Framework-dependent publish (I0) — requer ASP.NET Core Runtime 10 na EC2.
$ErrorActionPreference = 'Stop'

$ProjectRoot = Join-Path $PSScriptRoot '..\RDO-CleanMigration-2026\RdoApp.Core'
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$OutDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'publish\homolog-ec2-fdd'

Write-Host "Projeto: $ProjectRoot" -ForegroundColor Cyan
Write-Host "Saida:   $OutDir" -ForegroundColor Cyan

if (Test-Path $OutDir) {
    Remove-Item -Recurse -Force $OutDir
}
New-Item -ItemType Directory -Path $OutDir | Out-Null

Push-Location $ProjectRoot
try {
    dotnet publish -c Release -r win-x64 --self-contained false -o $OutDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $ZipPath = Join-Path (Split-Path $OutDir -Parent) 'rdoapp_core_fdd.zip'
    if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
    Compress-Archive -Path (Join-Path $OutDir '*') -DestinationPath $ZipPath -Force

    Write-Host 'Publish FDD OK.' -ForegroundColor Green
    Write-Host "Zip: $ZipPath" -ForegroundColor Green
    Write-Host 'EC2: dotnet RdoApp.Core.dll (servico RdoAppCoreHomolog) — preservar appsettings.Staging.json' -ForegroundColor Yellow
}
finally {
    Pop-Location
}
