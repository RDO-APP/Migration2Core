# Upload zip to S3 and trigger EC2 deploy via SSM (homolog only).
param(
    [string]$ZipPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'publish\rdoapp_core.zip'),

    [Parameter(Mandatory = $true)]
    [string]$S3Bucket,

    [string]$S3KeyPrefix = 'rdoapp_core',

    [Parameter(Mandatory = $true)]
    [string]$InstanceId,

    [string]$SitePath = 'C:\inetpub\wwwroot\homologacao\rdoapp_core',

    [string]$AppPoolName = '',

    [string]$AwsRegion = 'us-east-2',

    [switch]$NoWait,

    [int]$PollIntervalSeconds = 15,

    [int]$TimeoutMinutes = 45
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ZipPath)) {
    throw "Zip not found: $ZipPath. Run publish-homolog-ec2.ps1 first."
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$S3Key = "$S3KeyPrefix/rdoapp_core-$timestamp.zip"
$s3Uri = "s3://$S3Bucket/$S3Key"

Write-Host "Upload $ZipPath -> $s3Uri" -ForegroundColor Cyan
& aws s3 cp $ZipPath $s3Uri --region $AwsRegion
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$presignedUrl = aws s3 presign $s3Uri --expires-in 7200 --region $AwsRegion
if ($LASTEXITCODE -ne 0 -or -not $presignedUrl) { throw 'aws s3 presign failed' }
$presignedUrl = $presignedUrl.Trim()

$scriptPath = Join-Path $PSScriptRoot 'ec2-apply-rdoapp-core.ps1'
if (-not (Test-Path $scriptPath)) { throw "Missing $scriptPath" }
$remoteScript = Get-Content -Raw -Encoding UTF8 -Path $scriptPath
$scriptB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($remoteScript))

$poolArg = if ($AppPoolName) { "-AppPoolName '$AppPoolName'" } else { '' }
$presignedEsc = $presignedUrl -replace "'", "''"
$commands = @(
    'Set-ExecutionPolicy Bypass -Scope Process -Force'
    @"
`$applyPath = Join-Path `$env:TEMP 'ec2-apply-rdoapp-core.ps1'
[System.IO.File]::WriteAllBytes(`$applyPath, [Convert]::FromBase64String('$scriptB64'))
& `$applyPath -S3Bucket '$S3Bucket' -PresignedZipUrl '$presignedEsc' -SitePath '$SitePath' -AwsRegion '$AwsRegion' $poolArg
"@
)

$cliInputPath = Join-Path $env:TEMP "ssm-homolog-input-$timestamp.json"
$cliInput = @{
    DocumentName = 'AWS-RunPowerShellScript'
    InstanceIds  = @($InstanceId)
    Parameters   = @{ commands = $commands }
}
$cliJson = $cliInput | ConvertTo-Json -Depth 8 -Compress
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($cliInputPath, $cliJson, $utf8NoBom)

# Windows: --parameters file://... falha (\U em \Users ou file:///C:/). --cli-input-json file://$path OK.
Write-Host "SSM SendCommand -> $InstanceId" -ForegroundColor Cyan
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
Write-Host 'Proximo passo: browser B2 - https://homolog.sistema.rdoapp.com.br/Account/Login' -ForegroundColor Cyan
