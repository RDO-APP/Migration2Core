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
    Invoke-WebRequest -Uri $PresignedZipUrl -OutFile $zipPath -UseBasicParsing -TimeoutSec 900
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
Write-Output 'Expand-Archive (pode levar varios minutos)...'
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force
Write-Output 'Expand-Archive OK'

Import-Module WebAdministration -ErrorAction SilentlyContinue

function Stop-IisSitesOnPort {
    param([int]$Port)
    if (-not (Get-Module WebAdministration)) { return @() }
    $stopped = @()
    Get-Website | ForEach-Object {
        $site = $_
        $site.Bindings.Collection |
            Where-Object { $_.protocol -eq 'http' -and $_.bindingInformation -match ":$Port`:" } |
            ForEach-Object {
                if ($site.State -eq 'Started') {
                    Write-Output "Stopping IIS site $($site.Name) (port $Port) so Kestrel can bind for ALB"
                    Stop-Website -Name $site.Name -ErrorAction SilentlyContinue
                    $stopped += $site.Name
                }
            }
    }
    return $stopped
}

$stoppedIisSites = @()
if ($AppPoolName -and (Get-Module WebAdministration)) {
    if (Test-Path "IIS:\AppPools\$AppPoolName") {
        Write-Output "Stopping app pool $AppPoolName"
        Stop-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}
else {
    $stoppedIisSites = @(Stop-IisSitesOnPort -Port $SmokePort)
    if ($stoppedIisSites.Count -gt 0) { Start-Sleep -Seconds 2 }
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

Write-Output "Copy-Item -> $SitePath (pode levar varios minutos)..."
Get-ChildItem -Path $extractRoot -Force | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $SitePath -Recurse -Force
}
Write-Output 'Copy-Item OK'

if (Test-Path $stagingBackup) {
    Copy-Item -Path $stagingBackup -Destination $stagingPath -Force
    Remove-Item -Force $stagingBackup
    Write-Output "Restored $stagingName from backup"
}

$homologServiceName = 'RdoAppCoreHomolog'
$homologService = Get-Service -Name $homologServiceName -ErrorAction SilentlyContinue
$proc = $null
$coreExe = Join-Path $SitePath 'RdoApp.Core.exe'

if ($homologService) {
    Write-Output "Restarting service $homologServiceName"
    if ($homologService.Status -eq 'Running') {
        Restart-Service -Name $homologServiceName -Force -ErrorAction SilentlyContinue
    }
    else {
        Start-Service -Name $homologServiceName -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 5
}
elseif ($AppPoolName -and (Get-Module WebAdministration)) {
    if (Test-Path "IIS:\AppPools\$AppPoolName") {
        Write-Output "Starting app pool $AppPoolName (IIS :$SmokePort)"
        Start-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
        Get-Website | Where-Object { $_.applicationPool -eq $AppPoolName -and $_.State -ne 'Started' } |
            ForEach-Object { Start-Website -Name $_.Name -ErrorAction SilentlyContinue }
        Start-Sleep -Seconds 3
    }
}
elseif (Test-Path $coreExe) {
    Write-Output 'Starting RdoApp.Core (Kestrel homolog, 0.0.0.0 for ALB)...'
    $listenUrls = "http://0.0.0.0:$SmokePort"
    $startArgs = @{
        FilePath         = $coreExe
        WorkingDirectory = $SitePath
        WindowStyle      = 'Hidden'
        PassThru         = $true
    }
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $startArgs['Environment'] = @{
            ASPNETCORE_ENVIRONMENT = 'Staging'
            ASPNETCORE_URLS        = $listenUrls
        }
    }
    else {
        $env:ASPNETCORE_ENVIRONMENT = 'Staging'
        $env:ASPNETCORE_URLS = $listenUrls
    }
    $proc = Start-Process @startArgs
    if (-not $proc) { throw 'Failed to start RdoApp.Core.exe' }
    Start-Sleep -Seconds 3
}
elseif (-not (Test-Path $coreExe)) {
    throw "RdoApp.Core.exe not found under $SitePath"
}

$smokeUrl = "http://127.0.0.1:$SmokePort/Account/Login"
Write-Output "Smoke GET $smokeUrl"
$smokeOk = $false
$maxAttempts = 15
for ($attempt = 1; $attempt -le $maxAttempts; $attempt++) {
    if ($proc -and $proc.HasExited) {
        throw "RdoApp.Core.exe exited before smoke (code $($proc.ExitCode)). Check homolog Event Log or run exe manually on EC2."
    }
    try {
        $response = Invoke-WebRequest -Uri $smokeUrl -UseBasicParsing -TimeoutSec 15
        Write-Output "Smoke status: $($response.StatusCode) (attempt $attempt)"
        if ($response.StatusCode -eq 200) {
            $smokeOk = $true
            break
        }
    } catch {
        Write-Output "Smoke attempt ${attempt}/${maxAttempts}: $($_.Exception.Message)"
    }
    Start-Sleep -Seconds 4
}
if (-not $smokeOk) { exit 1 }

$privateIp = (Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notmatch '^127\.' -and $_.PrefixOrigin -ne 'WellKnown' } |
    Select-Object -First 1).IPAddress
$albSmokeOk = $false
if ($privateIp) {
    $albSmokeUrl = "http://${privateIp}:$SmokePort/Account/Login"
    Write-Output "Smoke GET $albSmokeUrl (ALB/TG path - must match browser, not only localhost)"
    for ($attempt = 1; $attempt -le 10; $attempt++) {
        try {
            $albResp = Invoke-WebRequest -Uri $albSmokeUrl -UseBasicParsing -TimeoutSec 20
            Write-Output "ALB smoke status: $($albResp.StatusCode) (attempt $attempt)"
            if ($albResp.StatusCode -eq 200) {
                $albSmokeOk = $true
                break
            }
        } catch {
            Write-Output "ALB smoke attempt $attempt/10: $($_.Exception.Message)"
        }
        Start-Sleep -Seconds 3
    }
}
else {
    Write-Output 'ALB smoke SKIP: no private IPv4 on instance (unexpected on EC2)'
}

if (-not $albSmokeOk) {
    Write-Output @'
ALB smoke FAILED. Common causes (regression since SSM Start-Process without stopping IIS):
  - IIS still bound to :5081 (ALB hits IIS 502; localhost smoke hit Kestrel on another binding)
  - Kestrel listening on 127.0.0.1 only (use ASPNETCORE_URLS=http://0.0.0.0:5081)
  - RdoApp.Core.exe exited after SSM (check Event Log)
Fix: redeploy with this script, or Session Manager - Stop-Website on :5081, start Core with 0.0.0.0:5081
'@
    exit 1
}

Write-Output 'Deploy homolog Core OK'
exit 0
