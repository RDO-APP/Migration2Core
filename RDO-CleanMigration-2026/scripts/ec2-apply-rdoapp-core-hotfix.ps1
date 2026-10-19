# Hotfix apply on EC2 — overlay publish output; never overwrite appsettings.Staging.json.
param(
    [Parameter(Mandatory = $true)]
    [string]$S3Bucket,

    [string]$S3Key = '',

    [string]$PresignedZipUrl = '',

    [string]$SitePath = 'C:\inetpub\wwwroot\homologacao\rdoapp_core',

    [string]$ServiceName = 'RdoAppCoreHomolog',

    [string]$AwsRegion = 'us-east-2',

    [int]$SmokePort = 5081
)

$ErrorActionPreference = 'Stop'

$forbidden = @('C:\inetpub\wwwroot\rdoapp', 'C:\inetpub\wwwroot\rdoapp\')
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

$zipPath = Join-Path $env:TEMP 'rdoapp_core-hotfix.zip'
if ($PresignedZipUrl) {
    Write-Output 'Downloading hotfix zip via presigned URL ...'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $PresignedZipUrl -OutFile $zipPath -UseBasicParsing
} else {
    if (-not $S3Key) { throw 'Provide S3Key or PresignedZipUrl' }
    $s3Uri = "s3://$S3Bucket/$S3Key"
    $awsExe = @(
        (Join-Path $env:ProgramFiles 'Amazon\AWSCLIV2\aws.exe'),
        (Join-Path ${env:ProgramFiles(x86)} 'Amazon\AWSCLIV2\aws.exe')
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $awsExe) { throw 'aws CLI not found on EC2' }
    & $awsExe s3 cp $s3Uri $zipPath --region $AwsRegion
    if ($LASTEXITCODE -ne 0) { throw "aws s3 cp failed ($LASTEXITCODE)" }
}

$extractRoot = Join-Path $env:TEMP 'rdoapp_core_hotfix_extract'
if (Test-Path $extractRoot) { Remove-Item -Recurse -Force $extractRoot }
New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

function Stop-HomologCore {
    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq 'Running') {
        Write-Output "Stopping service $ServiceName"
        Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
    }
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    cmd /c 'taskkill /F /IM RdoApp.Core.exe >nul 2>&1'
    Get-Process -Name 'RdoApp.Core' -ErrorAction SilentlyContinue | Stop-Process -Force
    Get-Process -Name 'dotnet' -ErrorAction SilentlyContinue | Where-Object {
        $_.Path -and $_.MainModule -and $_.MainModule.FileName -like '*dotnet.exe*'
    } | ForEach-Object {
        $cmd = (Get-CimInstance Win32_Process -Filter "ProcessId=$($_.Id)" -ErrorAction SilentlyContinue).CommandLine
        if ($cmd -and $cmd -like "*RdoApp.Core.dll*") { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue }
    }
    $ErrorActionPreference = $prev
}

Stop-HomologCore
Start-Sleep -Seconds 2

Get-ChildItem -Path $extractRoot -Force | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $SitePath -Recurse -Force
}

if (Test-Path $stagingBackup) {
    Copy-Item -Path $stagingBackup -Destination $stagingPath -Force
    Remove-Item -Force $stagingBackup
    Write-Output "Restored $stagingName from backup"
}

$svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($svc) {
    Write-Output "Starting service $ServiceName"
    Start-Service -Name $ServiceName -ErrorAction Stop
    Start-Sleep -Seconds 5
} else {
    $coreDll = Join-Path $SitePath 'RdoApp.Core.dll'
    $coreExe = Join-Path $SitePath 'RdoApp.Core.exe'
    if (Test-Path $coreDll) {
        $dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
        $dotnet = if ($dotnetCmd) { $dotnetCmd.Source } else { $null }
        if (-not $dotnet) { $dotnet = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe' }
        if (-not (Test-Path $dotnet)) { throw 'dotnet not found; install runtime or register service' }
        Write-Output "Starting Kestrel: dotnet RdoApp.Core.dll"
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $dotnet
        $psi.Arguments = "`"$coreDll`""
        $psi.WorkingDirectory = $SitePath
        $psi.UseShellExecute = $false
        $psi.EnvironmentVariables['ASPNETCORE_ENVIRONMENT'] = 'Staging'
        $psi.EnvironmentVariables['ASPNETCORE_URLS'] = "http://*:$SmokePort"
        [void][System.Diagnostics.Process]::Start($psi)
        Start-Sleep -Seconds 5
    } elseif (Test-Path $coreExe) {
        Write-Output 'Starting RdoApp.Core.exe (self-contained)'
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $coreExe
        $psi.WorkingDirectory = $SitePath
        $psi.UseShellExecute = $false
        $psi.EnvironmentVariables['ASPNETCORE_ENVIRONMENT'] = 'Staging'
        $psi.EnvironmentVariables['ASPNETCORE_URLS'] = "http://*:$SmokePort"
        [void][System.Diagnostics.Process]::Start($psi)
        Start-Sleep -Seconds 5
    } else {
        throw 'Neither RdoApp.Core.dll nor RdoApp.Core.exe found after hotfix'
    }
}

$smokeUrl = "http://127.0.0.1:$SmokePort/Account/Login"
Write-Output "Smoke GET $smokeUrl"
$response = Invoke-WebRequest -Uri $smokeUrl -UseBasicParsing -TimeoutSec 60
Write-Output "Smoke status: $($response.StatusCode)"
if ($response.StatusCode -ne 200) { exit 1 }

Write-Output 'Hotfix homolog Core OK'
