# One-time: Windows service for homolog Kestrel (FDD). Run on EC2 via SSM or Session Manager.
param(
    [string]$SitePath = 'C:\inetpub\wwwroot\homologacao\rdoapp_core',

    [string]$ServiceName = 'RdoAppCoreHomolog',

    [string]$DisplayName = 'RDO App Core Homolog (Kestrel :5081)',

    [int]$Port = 5081
)

$ErrorActionPreference = 'Stop'

$coreDll = Join-Path $SitePath 'RdoApp.Core.dll'
if (-not (Test-Path $coreDll)) {
    throw "RdoApp.Core.dll not found at $SitePath — deploy FDD first (publish-homolog-ec2-fdd.ps1)."
}

$dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
$dotnet = if ($dotnetCmd) { $dotnetCmd.Source } else { $null }
if (-not $dotnet) { $dotnet = Join-Path $env:ProgramFiles 'dotnet\dotnet.exe' }
if (-not (Test-Path $dotnet)) {
    throw 'dotnet.exe not found. Install .NET 10 ASP.NET Core Runtime / Hosting Bundle on EC2.'
}

$runnerPath = Join-Path $SitePath 'run-rdoapp-core-homolog.cmd'
$runnerContent = @"
@echo off
cd /d "$SitePath"
set ASPNETCORE_ENVIRONMENT=Staging
set ASPNETCORE_URLS=http://*:$Port
"$dotnet" "$coreDll"
"@
Set-Content -Path $runnerPath -Value $runnerContent -Encoding ASCII

$existing = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($existing) {
    if ($existing.Status -eq 'Running') {
        Stop-Service -Name $ServiceName -Force
    }
    sc.exe delete $ServiceName | Out-Null
    Start-Sleep -Seconds 2
}

$binPath = "`"$runnerPath`""
sc.exe create $ServiceName binPath= $binPath start= auto DisplayName= "$DisplayName"
if ($LASTEXITCODE -ne 0) { throw "sc.exe create failed ($LASTEXITCODE)" }

Set-Service -Name $ServiceName -StartupType Automatic
Start-Service -Name $ServiceName
Start-Sleep -Seconds 5

$smokeUrl = "http://127.0.0.1:$Port/Account/Login"
$response = Invoke-WebRequest -Uri $smokeUrl -UseBasicParsing -TimeoutSec 60
Write-Output "Service $ServiceName started; smoke $($response.StatusCode) $smokeUrl"
