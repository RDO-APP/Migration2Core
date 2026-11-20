# Publish RdoApp.Core linux-x64 (self-contained) para homolog L1.
# Secrets ficam na EC2 (appsettings.Staging.json) — nao entram no zip.
$ErrorActionPreference = "Stop"

$ProjectRoot = Join-Path $PSScriptRoot "..\RDO-CleanMigration-2026\RdoApp.Core"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$PublishRoot = Join-Path (Split-Path $PSScriptRoot -Parent) "publish"
$OutDir = Join-Path $PublishRoot "homolog-linux"
$ZipPath = Join-Path $PublishRoot "rdoapp_core_linux.zip"

Write-Host "Projeto: $ProjectRoot" -ForegroundColor Cyan
Write-Host "Saida:   $OutDir" -ForegroundColor Cyan

if (Test-Path $OutDir) {
    Remove-Item -Recurse -Force $OutDir
}
New-Item -ItemType Directory -Path $OutDir | Out-Null

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
    dotnet publish -c Release -r linux-x64 --self-contained true -o $OutDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host ""
    Write-Host "Publish Linux OK." -ForegroundColor Green
    if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
    # Compress-Archive usa '\'; quebrando unzip no Linux — zip com entradas '/' .
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::Open($ZipPath, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        $root = (Resolve-Path $OutDir).Path
        Get-ChildItem $OutDir -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($root.Length).TrimStart('\').Replace('\', '/')
            [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                $zip, $_.FullName, $rel, [System.IO.Compression.CompressionLevel]::Optimal)
        }
    }
    finally {
        $zip.Dispose()
    }

    Write-Host "Zip:     $ZipPath" -ForegroundColor Green
    Write-Host "Proximo: .\deploy-homolog-linux-ssm.ps1 -S3Bucket s3rdoapp -InstanceId <LINUX-ID>" -ForegroundColor Yellow
    Write-Host "Guia: RDO-CleanMigration-2026\DEPLOY-HOMOLOG-LINUX-EC2.md"
}
finally {
    Pop-Location
}
