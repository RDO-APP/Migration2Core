# Upload hotfix zip to S3 and apply on EC2 via SSM (homolog only).
param(
    [string]$ZipPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'publish\rdoapp_core_hotfix.zip'),

    [Parameter(Mandatory = $true)]
    [string]$S3Bucket,

    [string]$S3KeyPrefix = 'rdoapp_core_hotfix',

    [Parameter(Mandatory = $true)]
    [string]$InstanceId,

    [string]$SitePath = 'C:\inetpub\wwwroot\homologacao\rdoapp_core',

    [string]$AwsRegion = 'us-east-2'
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $ZipPath)) {
    throw "Zip not found: $ZipPath. Run publish-homolog-hotfix.ps1 first."
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$S3Key = "$S3KeyPrefix/rdoapp_core_hotfix-$timestamp.zip"
$s3Uri = "s3://$S3Bucket/$S3Key"

Write-Host "Upload $ZipPath -> $s3Uri" -ForegroundColor Cyan
& aws s3 cp $ZipPath $s3Uri --region $AwsRegion
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$presignedUrl = aws s3 presign $s3Uri --expires-in 7200 --region $AwsRegion
if ($LASTEXITCODE -ne 0 -or -not $presignedUrl) { throw 'aws s3 presign failed' }
$presignedUrl = $presignedUrl.Trim()

$scriptPath = Join-Path $PSScriptRoot 'ec2-apply-rdoapp-core-hotfix.ps1'
if (-not (Test-Path $scriptPath)) { throw "Missing $scriptPath" }
$remoteScript = Get-Content -Raw -Path $scriptPath

$commands = @(
    'Set-ExecutionPolicy Bypass -Scope Process -Force'
    @"
`$script = @'
$remoteScript
'@
Set-Content -Path `$env:TEMP\ec2-apply-rdoapp-core-hotfix.ps1 -Value `$script -Encoding UTF8
& `$env:TEMP\ec2-apply-rdoapp-core-hotfix.ps1 -S3Bucket '$S3Bucket' -PresignedZipUrl '$presignedUrl' -SitePath '$SitePath' -AwsRegion '$AwsRegion'
"@
)

$paramPath = Join-Path $env:TEMP "ssm-homolog-hotfix-$timestamp.json"
$paramJson = @{ commands = $commands } | ConvertTo-Json -Depth 5
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($paramPath, $paramJson, $utf8NoBom)

Write-Host "SSM SendCommand (hotfix) -> $InstanceId" -ForegroundColor Cyan
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
