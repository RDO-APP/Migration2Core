# Upload linux zip to S3 and deploy via SSM AWS-RunShellScript (homolog L1 only).
param(
    [string]$ZipPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'publish\rdoapp_core_linux.zip'),

    [Parameter(Mandatory = $true)]
    [string]$S3Bucket,

    [string]$S3KeyPrefix = 'rdoapp_core_linux',

    [Parameter(Mandatory = $true)]
    [string]$InstanceId,

    [string]$SitePath = '/var/www/rdoapp_core',

    [string]$AwsRegion = 'us-east-2',

    [switch]$NoWait,

    [int]$PollIntervalSeconds = 15,

    [int]$TimeoutMinutes = 45
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ZipPath)) {
    throw "Zip not found: $ZipPath. Run publish-homolog-linux.ps1 first."
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$S3Key = "$S3KeyPrefix/rdoapp_core_linux-$timestamp.zip"
$s3Uri = "s3://$S3Bucket/$S3Key"

Write-Host "Upload $ZipPath -> $s3Uri" -ForegroundColor Cyan
& aws s3 cp $ZipPath $s3Uri --region $AwsRegion
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$presignedUrl = aws s3 presign $s3Uri --expires-in 7200 --region $AwsRegion
if ($LASTEXITCODE -ne 0 -or -not $presignedUrl) { throw 'aws s3 presign failed' }
$presignedUrl = $presignedUrl.Trim()

$scriptPath = Join-Path $PSScriptRoot 'ec2-apply-rdoapp-core-linux.sh'
if (-not (Test-Path $scriptPath)) { throw "Missing $scriptPath" }
$remoteScript = Get-Content -Raw -Encoding UTF8 -Path $scriptPath
# Normalizar CRLF -> LF para bash
$remoteScript = $remoteScript -replace "`r`n", "`n" -replace "`r", "`n"
$scriptB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($remoteScript))

# Escapar aspas simples no URL para embutir em shell single-quoted
$presignedEsc = $presignedUrl -replace "'", "'\\''"

$commands = @(
    'set -euo pipefail'
    "printf '%s' '$scriptB64' | base64 -d > /tmp/ec2-apply-rdoapp-core-linux.sh"
    'chmod +x /tmp/ec2-apply-rdoapp-core-linux.sh'
    "bash /tmp/ec2-apply-rdoapp-core-linux.sh --presigned-url '$presignedEsc' --site-path '$SitePath' --port 5081"
)

$cliInputPath = Join-Path $env:TEMP "ssm-homolog-linux-input-$timestamp.json"
$cliInput = @{
    DocumentName = 'AWS-RunShellScript'
    InstanceIds  = @($InstanceId)
    Parameters   = @{ commands = $commands }
}
$cliJson = $cliInput | ConvertTo-Json -Depth 8 -Compress
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($cliInputPath, $cliJson, $utf8NoBom)

Write-Host "SSM SendCommand (RunShellScript) -> $InstanceId" -ForegroundColor Cyan
$commandId = aws ssm send-command `
    --region $AwsRegion `
    --cli-input-json "file://$cliInputPath" `
    --query 'Command.CommandId' `
    --output text

if (-not $commandId) { throw 'SSM send-command failed' }
Write-Host "CommandId: $commandId" -ForegroundColor Green

if ($NoWait) {
    Write-Host "NoWait: poll manual:" -ForegroundColor DarkYellow
    Write-Host "  .\wait-ssm-homolog-command.ps1 -CommandId `"$commandId`" -InstanceId `"$InstanceId`" -AwsRegion $AwsRegion"
    exit 0
}

$waitScript = Join-Path $PSScriptRoot 'wait-ssm-homolog-command.ps1'
if (-not (Test-Path $waitScript)) { throw "Missing $waitScript" }

& $waitScript `
    -CommandId $commandId `
    -InstanceId $InstanceId `
    -AwsRegion $AwsRegion `
    -PollIntervalSeconds $PollIntervalSeconds `
    -TimeoutMinutes $TimeoutMinutes

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Write-Host 'Proximo: smoke browser homolog.sistema (apos registrar no TG)' -ForegroundColor Cyan
