# Hotfix zip (I0): publish FDD + opcional SPA — sem appsettings*.
param(
    [switch]$SkipClientBuild
)

$ErrorActionPreference = 'Stop'

$Root = Split-Path $PSScriptRoot -Parent
$ProjectRoot = Join-Path $Root 'RDO-CleanMigration-2026\RdoApp.Core'
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$ClientRoot = Join-Path $Root 'RDO-CleanMigration-2026\client'
if (-not (Test-Path (Join-Path $ClientRoot 'package.json'))) {
    $ClientRoot = Join-Path $Root 'client'
}
$StagingDir = Join-Path $Root 'publish\homolog-hotfix-staging'
$ZipPath = Join-Path $Root 'publish\rdoapp_core_hotfix.zip'

if (-not $SkipClientBuild -and (Test-Path (Join-Path $ClientRoot 'package.json'))) {
    Write-Host 'Building client (Vite -> wwwroot/app)...' -ForegroundColor Cyan
    Push-Location $ClientRoot
    try {
        if (Test-Path 'node_modules') {
            npm run build
        } else {
            npm ci
            if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
            npm run build
        }
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }
    finally {
        Pop-Location
    }
}

if (Test-Path $StagingDir) { Remove-Item -Recurse -Force $StagingDir }
New-Item -ItemType Directory -Path $StagingDir | Out-Null

Push-Location $ProjectRoot
try {
    dotnet publish -c Release -r win-x64 --self-contained false -o $StagingDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}

$excludeSettings = @(
    'appsettings.json',
    'appsettings.Development.json',
    'appsettings.Staging.json',
    'appsettings.Production.json'
)
foreach ($name in $excludeSettings) {
    $p = Join-Path $StagingDir $name
    if (Test-Path $p) { Remove-Item -Force $p }
}

if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
Compress-Archive -Path (Join-Path $StagingDir '*') -DestinationPath $ZipPath -Force

Write-Host "Hotfix zip: $ZipPath ($((Get-Item $ZipPath).Length / 1MB | ForEach-Object { '{0:N1}' -f $_ }) MB)" -ForegroundColor Green
Write-Host 'Proximo: .\deploy-homolog-hotfix-ssm.ps1 -S3Bucket ... -InstanceId ...' -ForegroundColor Yellow
