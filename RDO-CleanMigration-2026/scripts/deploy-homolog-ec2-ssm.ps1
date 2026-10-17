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

    [string]$AwsRegion = 'us-east-2'
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

$scriptPath = Join-Path $PSScriptRoot 'ec2-apply-rdoapp-core.ps1'
if (-not (Test-Path $scriptPath)) { throw "Missing $scriptPath" }
$remoteScript = Get-Content -Raw -Path $scriptPath

$poolArg = if ($AppPoolName) { "-AppPoolName '$AppPoolName'" } else { '' }
$commands = @(
    "Set-ExecutionPolicy Bypass -Scope Process -Force"
    @"
`$script = @'
$remoteScript
'@
Set-Content -Path `$env:TEMP\ec2-apply-rdoapp-core.ps1 -Value `$script -Encoding UTF8
& `$env:TEMP\ec2-apply-rdoapp-core.ps1 -S3Bucket '$S3Bucket' -S3Key '$S3Key' -SitePath '$SitePath' -AwsRegion '$AwsRegion' $poolArg
"@
)

$paramPath = Join-Path $env:TEMP "ssm-homolog-core-$timestamp.json"
@{ commands = $commands } | ConvertTo-Json | Set-Content -Path $paramPath -Encoding UTF8

Write-Host "SSM SendCommand -> $InstanceId" -ForegroundColor Cyan
$commandId = aws ssm send-command `
    --region $AwsRegion `
    --instance-ids $InstanceId `
    --document-name 'AWS-RunPowerShellScript' `
    --parameters "file://$paramPath" `
    --query 'Command.CommandId' `
    --output text

if (-not $commandId) { throw 'SSM send-command failed' }
Write-Host "CommandId: $commandId" -ForegroundColor Green
Write-Host "Poll: aws ssm get-command-invocation --command-id $commandId --instance-id $InstanceId --region $AwsRegion"
