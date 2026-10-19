# Poll SSM until deploy finishes (homolog EC2). Safe to re-run while InProgress.
param(
    [Parameter(Mandatory = $true)]
    [string]$CommandId,

    [string]$InstanceId = 'i-05cb0003c031a26da',

    [string]$AwsRegion = 'us-east-2',

    [int]$PollIntervalSeconds = 15,

    [int]$TimeoutMinutes = 45
)

$ErrorActionPreference = 'Stop'

$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$started = Get-Date
Write-Host "Aguardando SSM CommandId $CommandId (max ${TimeoutMinutes} min, poll ${PollIntervalSeconds}s)..." -ForegroundColor Cyan
Write-Host "Nota: SSM so publica StandardOutput quando o script NA EC2 termina. InProgress 10-20 min e normal (download + Expand-Archive + copia self-contained)." -ForegroundColor DarkGray

$poll = 0
while ((Get-Date) -lt $deadline) {
    $poll++
    $raw = aws ssm get-command-invocation `
        --command-id $CommandId `
        --instance-id $InstanceId `
        --region $AwsRegion `
        --output json

    if ($LASTEXITCODE -ne 0) {
        throw 'aws ssm get-command-invocation failed'
    }

    $inv = $raw | ConvertFrom-Json
    $status = [string]$inv.Status
    $clock = Get-Date -Format 'HH:mm:ss'
    $elapsedMin = [math]::Round(((Get-Date) - $started).TotalMinutes, 1)
    Write-Host "[$clock] Status: $status (decorrido ${elapsedMin} min)" -ForegroundColor Yellow
    if ($poll -eq 1 -or ($poll % 4 -eq 0)) {
        Write-Host "  Homolog pode continuar no ar (versao anterior) ate o script parar o Core e copiar arquivos." -ForegroundColor DarkGray
    }

    switch ($status) {
        'Success' {
            if ($inv.StandardOutputContent) {
                Write-Host "--- StandardOutput ---" -ForegroundColor Green
                Write-Host $inv.StandardOutputContent
            }
            if ($inv.StandardErrorContent) {
                Write-Host "--- StandardError ---" -ForegroundColor DarkYellow
                Write-Host $inv.StandardErrorContent
            }
            Write-Host "Deploy SSM OK." -ForegroundColor Green
            exit 0
        }
        { $_ -in @('Failed', 'Cancelled', 'TimedOut') } {
            if ($inv.StandardOutputContent) { Write-Host $inv.StandardOutputContent }
            if ($inv.StandardErrorContent) { Write-Host $inv.StandardErrorContent -ForegroundColor Red }
            if ($status -eq 'Failed' -and $inv.StandardOutputContent -match 'Deploy homolog Core OK') {
                Write-Host "SSM Status=Failed mas stdout confirma deploy OK (falso negativo conhecido: logs Kestrel no SSM)." -ForegroundColor Yellow
                Write-Host "Deploy SSM OK." -ForegroundColor Green
                exit 0
            }
            throw "SSM terminou com Status=$status"
        }
        default {
            Start-Sleep -Seconds $PollIntervalSeconds
        }
    }
}

throw "SSM ainda InProgress apos ${TimeoutMinutes} min. CommandId=$CommandId. Ver Console SSM ou Session Manager (diagnostico)."
