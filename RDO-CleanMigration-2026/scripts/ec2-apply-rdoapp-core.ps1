# Executado NA EC2 via SSM (homolog Core only).
param(
    [Parameter(Mandatory = $true)]
    [string]$S3Bucket,

    [string]$S3Key = '',

    [string]$PresignedZipUrl = '',

    [string]$SitePath = 'C:\inetpub\wwwroot\homologacao\rdoapp_core',

    [string]$AppPoolName = '',

    [string]$AwsRegion = 'us-east-2',

    [int]$SmokePort = 5081
)

$ErrorActionPreference = 'Stop'

$forbidden = @(
    'C:\inetpub\wwwroot\rdoapp',
    'C:\inetpub\wwwroot\rdoapp\'
)
foreach ($f in $forbidden) {
    if ($SitePath -eq $f -or $SitePath.StartsWith($f, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to deploy to production path: $SitePath"
    }
}

if (-not (Test-Path $SitePath)) {
    New-Item -ItemType Directory -Path $SitePath -Force | Out-Null
}

$stagingName = 'appsettings.Staging.json'
$stagingPath = Join-Path $SitePath $stagingName
$stagingBackup = Join-Path $env:TEMP "rdoapp_core-$stagingName.bak"

if (Test-Path $stagingPath) {
    Copy-Item -Path $stagingPath -Destination $stagingBackup -Force
    Write-Output "Backed up $stagingName"
}

$zipPath = Join-Path $env:TEMP 'rdoapp_core-deploy.zip'
if ($PresignedZipUrl) {
    Write-Output 'Downloading deploy zip via presigned URL ...'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $PresignedZipUrl -OutFile $zipPath -UseBasicParsing
} else {
    if (-not $S3Key) { throw 'Provide S3Key or PresignedZipUrl' }
    $s3Uri = "s3://$S3Bucket/$S3Key"
    Write-Output "Downloading $s3Uri ..."
    $awsExe = @(
        (Join-Path $env:ProgramFiles 'Amazon\AWSCLIV2\aws.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Amazon\AWSCLIV2\aws.exe')
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $awsExe) {
        $awsCmd = Get-Command aws -ErrorAction SilentlyContinue
        if ($awsCmd) { $awsExe = $awsCmd.Source }
    }
    if (-not $awsExe) { throw 'aws CLI not found on EC2; redeploy with PresignedZipUrl from your PC' }
    & $awsExe s3 cp $s3Uri $zipPath --region $AwsRegion
    if ($LASTEXITCODE -ne 0) { throw "aws s3 cp failed ($LASTEXITCODE)" }
}

$extractRoot = Join-Path $env:TEMP 'rdoapp_core_extract'
if (Test-Path $extractRoot) { Remove-Item -Recurse -Force $extractRoot }
New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

Import-Module WebAdministration -ErrorAction SilentlyContinue
if ($AppPoolName -and (Get-Module WebAdministration)) {
    if (Test-Path "IIS:\AppPools\$AppPoolName") {
        Write-Output "Stopping app pool $AppPoolName"
        Stop-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

Write-Output 'Stopping RdoApp.Core (Kestrel homolog)...'
function Stop-HomologCoreProcess {
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    cmd /c "taskkill /F /IM RdoApp.Core.exe >nul 2>&1"
    Get-Process -Name 'RdoApp.Core' -ErrorAction SilentlyContinue | Stop-Process -Force
    $ErrorActionPreference = $prev
}
Stop-HomologCoreProcess
$deadline = (Get-Date).AddSeconds(45)
while (Get-Process -Name 'RdoApp.Core' -ErrorAction SilentlyContinue) {
    if ((Get-Date) -gt $deadline) {
        throw 'RdoApp.Core still running; cannot overwrite binaries'
    }
    Start-Sleep -Seconds 2
    Stop-HomologCoreProcess
}
Start-Sleep -Seconds 2

Get-ChildItem -Path $extractRoot -Force | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $SitePath -Recurse -Force
}

if (Test-Path $stagingBackup) {
    Copy-Item -Path $stagingBackup -Destination $stagingPath -Force
    Remove-Item -Force $stagingBackup
    Write-Output "Restored $stagingName from backup"
}

if ($AppPoolName -and (Get-Module WebAdministration)) {
    if (Test-Path "IIS:\AppPools\$AppPoolName") {
        Write-Output "Starting app pool $AppPoolName"
        Start-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
    }
}

$coreExe = Join-Path $SitePath 'RdoApp.Core.exe'
if (Test-Path $coreExe) {
    Write-Output 'Starting RdoApp.Core (Kestrel homolog)...'
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $coreExe
    $psi.WorkingDirectory = $SitePath
    $psi.UseShellExecute = $false
    $psi.EnvironmentVariables['ASPNETCORE_ENVIRONMENT'] = 'Staging'
    $psi.EnvironmentVariables['ASPNETCORE_URLS'] = "http://*:$SmokePort"
    [void][System.Diagnostics.Process]::Start($psi)
    Start-Sleep -Seconds 5
}

$smokeUrl = "http://127.0.0.1:$SmokePort/Account/Login"
Write-Output "Smoke GET $smokeUrl"
$response = Invoke-WebRequest -Uri $smokeUrl -UseBasicParsing -TimeoutSec 60
Write-Output "Smoke status: $($response.StatusCode)"
if ($response.StatusCode -ne 200) { exit 1 }

Write-Output 'Deploy homolog Core OK'
