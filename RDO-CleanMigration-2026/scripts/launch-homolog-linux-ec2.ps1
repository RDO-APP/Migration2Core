# Launch Amazon Linux 2023 dedicada ao homolog Core (L1). NAO registra no TG.
param(
    [string]$AwsRegion = 'us-east-2',
    [string]$AmiId = '',
    [string]$InstanceType = 't3.small',
    [string]$SubnetId = 'subnet-c1a2ffa9',
    [string]$SecurityGroupId = 'sg-0949364ef36d38331',
    [string]$IamInstanceProfile = 'NewInstanceRole',
    [string]$NameTag = 'rdoapp-core-homolog-linux',
    [string]$KeyName = 'acessoFull_EC2'
)

$ErrorActionPreference = 'Stop'

if (-not $AmiId) {
    $AmiId = aws ssm get-parameter `
        --region $AwsRegion `
        --name '/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64' `
        --query 'Parameter.Value' `
        --output text
    if (-not $AmiId) { throw 'Could not resolve AL2023 AMI' }
}

$userDataPath = Join-Path $env:TEMP 'rdoapp-homolog-linux-userdata.sh'
@'
#!/bin/bash
set -euo pipefail
dnf install -y unzip curl libicu
mkdir -p /var/www/rdoapp_core
chown root:root /var/www/rdoapp_core
chmod 755 /var/www/rdoapp_core
cat > /etc/systemd/system/rdoapp-core-homolog.service <<'UNIT'
[Unit]
Description=RdoApp.Core homolog (Kestrel 5081)
After=network.target

[Service]
WorkingDirectory=/var/www/rdoapp_core
ExecStart=/var/www/rdoapp_core/RdoApp.Core
Restart=always
RestartSec=5
Environment=ASPNETCORE_ENVIRONMENT=Staging
Environment=ASPNETCORE_URLS=http://0.0.0.0:5081
KillSignal=SIGINT
TimeoutStopSec=30

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable rdoapp-core-homolog.service || true
echo "bootstrap homolog linux OK" > /var/log/rdoapp-homolog-bootstrap.log
'@ | Set-Content -Path $userDataPath -Encoding ascii -NoNewline

Write-Host "AMI: $AmiId | Type: $InstanceType | Subnet: $SubnetId | SG: $SecurityGroupId" -ForegroundColor Cyan

$out = aws ec2 run-instances `
    --region $AwsRegion `
    --image-id $AmiId `
    --instance-type $InstanceType `
    --subnet-id $SubnetId `
    --security-group-ids $SecurityGroupId `
    --iam-instance-profile "Name=$IamInstanceProfile" `
    --key-name $KeyName `
    --user-data "file://$userDataPath" `
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NameTag},{Key=Role,Value=homolog-core-l1},{Key=Product,Value=Equipamentos}]" `
    --metadata-options "HttpTokens=required,HttpEndpoint=enabled" `
    --query 'Instances[0].{InstanceId:InstanceId,PrivateIp:PrivateIpAddress,SubnetId:SubnetId}' `
    --output json

if ($LASTEXITCODE -ne 0 -or -not $out) { throw 'run-instances failed' }
Write-Host $out -ForegroundColor Green
$obj = $out | ConvertFrom-Json
Write-Host ""
Write-Host "InstanceId: $($obj.InstanceId)" -ForegroundColor Green
Write-Host "Aguarde SSM Online (~2-5 min). NAO registre no TG ainda." -ForegroundColor Yellow
Write-Host "Depois: copiar Staging do Windows + publish-homolog-linux + deploy-homolog-linux-ssm" -ForegroundColor Yellow
$obj.InstanceId
