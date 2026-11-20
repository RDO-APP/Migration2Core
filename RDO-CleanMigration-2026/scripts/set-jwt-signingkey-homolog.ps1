# Seta Jwt:SigningKey no Staging EC2 via SSM.
# NAO coloque a chave real neste arquivo no Git.
# Uso: cole a chave so na linha $SigningKey, rode, depois volte o placeholder.

$InstanceId = 'i-0776acb09b8438f22'
$Region = 'us-east-2'

$SigningKey = 'COLE_AQUI_A_LINHA_DO_NOTES'

if ([string]::IsNullOrWhiteSpace($SigningKey) -or $SigningKey -eq 'COLE_AQUI_A_LINHA_DO_NOTES' -or $SigningKey.Length -lt 32) {
    Write-Host 'ERRO: cole a chave em $SigningKey (so nessa linha) e salve.' -ForegroundColor Red
    exit 1
}

$SigningKey = $SigningKey.Trim()
Write-Host ("Chave length = {0}" -f $SigningKey.Length) -ForegroundColor Cyan
$keyEsc = $SigningKey.Replace("'", "'\''")
$py = "import json,pathlib; p=pathlib.Path('/var/www/rdoapp_core/appsettings.Staging.json'); d=json.loads(p.read_text(encoding='utf-8')); d['Jwt']={'Issuer':'https://homolog.sistema.rdoapp.com.br','Audience':'rdo-apontador','SigningKey':'$keyEsc','ExpiryMinutes':480}; p.write_text(json.dumps(d,indent=2,ensure_ascii=False)+chr(10),encoding='utf-8'); print('Jwt section OK (SigningKey length=%s)' % len(d['Jwt']['SigningKey']))"
$cmd1 = "python3 -c `"$py`""
$cmd2 = 'systemctl restart rdoapp-core-homolog'
$cmd3 = 'systemctl is-active rdoapp-core-homolog'
$paramsPath = Join-Path $env:TEMP 'ssm-jwt-params.json'
$obj = @{ commands = @($cmd1, $cmd2, $cmd3) }
$json = $obj | ConvertTo-Json -Compress
[System.IO.File]::WriteAllText($paramsPath, $json, (New-Object -TypeName System.Text.UTF8Encoding -ArgumentList @($false)))
Write-Host 'Enviando SSM...' -ForegroundColor Yellow
$cmdId = aws ssm send-command --region $Region --instance-ids $InstanceId --document-name AWS-RunShellScript --parameters "file://$paramsPath" --output text --query Command.CommandId 2>&1
Write-Host "CommandId = $cmdId"
if (-not $cmdId -or "$cmdId" -notmatch '^[0-9a-fA-F-]{36}$') { Write-Host $cmdId -ForegroundColor Red; exit 1 }
Start-Sleep -Seconds 12
$outFile = Join-Path $env:TEMP 'ssm-jwt-result.json'
aws ssm get-command-invocation --region $Region --command-id $cmdId --instance-id $InstanceId --output json | Out-File -FilePath $outFile -Encoding utf8
$j = Get-Content $outFile -Raw -Encoding utf8 | ConvertFrom-Json
Write-Host ("Status = {0}" -f $j.Status)
Write-Host $j.StandardOutputContent
if ($j.Status -eq 'Success' -and $j.StandardOutputContent -match 'Jwt section OK') { Write-Host 'CERTO: Jwt gravado.' -ForegroundColor Green; exit 0 }
Write-Host 'Ainda nao.' -ForegroundColor Yellow; exit 2