# Poll SSM until deploy finishes (homolog EC2). Safe to re-run while InProgress.
# Windows: evita falha aws CLI 'charmap' codec (systemctl imprime U+25CF ●).
param(
    [Parameter(Mandatory = $true)]
    [string]$CommandId,

    # Default L1 Linux (2026-11-19). Windows rollback: i-05cb0003c031a26da
    [string]$InstanceId = 'i-0776acb09b8438f22',

    [string]$AwsRegion = 'us-east-2',

    [int]$PollIntervalSeconds = 15,

    [int]$TimeoutMinutes = 45
)

$ErrorActionPreference = 'Stop'

$env:PYTHONIOENCODING = 'utf-8'
$env:PYTHONUTF8 = '1'
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch { }

function Get-SsmStatusOnly {
    param([string]$Cid, [string]$Iid, [string]$Region)
    # So Status (ASCII) — nao baixa stdout com ● durante o poll.
    $status = & aws ssm get-command-invocation `
        --command-id $Cid `
        --instance-id $Iid `
        --region $Region `
        --query 'Status' `
        --output text
    if ($LASTEXITCODE -ne 0) {
        throw 'aws ssm get-command-invocation failed (Status)'
    }
    return ([string]$status).Trim()
}

function Get-SsmInvocationFromFile {
    param([string]$Cid, [string]$Iid, [string]$Region)
    $outFile = Join-Path $env:TEMP ("ssm-inv-{0}.json" -f $Cid)
    # Redirect via cmd+PYTHONUTF8: JSON vai para arquivo sem codec do console.
    $arg = "ssm get-command-invocation --command-id $Cid --instance-id $Iid --region $Region --output json --query Status,StandardOutputContent,StandardErrorContent"
    # query precisa de aspas no shape; usar arquivo cli
    $q = '{Status:Status,StandardOutputContent:StandardOutputContent,StandardErrorContent:StandardErrorContent}'
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'aws'
    $psi.Arguments = "ssm get-command-invocation --command-id `"$Cid`" --instance-id `"$Iid`" --region `"$Region`" --output json --query `"$q`""
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.Environment['PYTHONIOENCODING'] = 'utf-8'
    $psi.Environment['PYTHONUTF8'] = '1'
    # Herdar PATH etc.
    foreach ($key in [System.Environment]::GetEnvironmentVariables().Keys) {
        if (-not $psi.Environment.ContainsKey($key)) {
            try { $psi.Environment[$key] = [System.Environment]::GetEnvironmentVariable($key) } catch { }
        }
    }
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    [void]$p.Start()
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()
    if ($p.ExitCode -ne 0) {
        throw "aws get-command-invocation exit $($p.ExitCode): $stderr"
    }
    [System.IO.File]::WriteAllText($outFile, $stdout, [System.Text.UTF8Encoding]::new($false))
    return ($stdout | ConvertFrom-Json)
}

function Write-SsmTextSafe([string]$label, [string]$content) {
    if (-not $content) { return }
    Write-Host $label
    $safe = $content -replace [char]0x25CF, '*' -replace '[^\x09\x0A\x0D\x20-\x7E]', '?'
    Write-Host $safe
}

$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$started = Get-Date
Write-Host "Aguardando SSM CommandId $CommandId (max ${TimeoutMinutes} min, poll ${PollIntervalSeconds}s)..." -ForegroundColor Cyan
Write-Host "Nota: SSM so publica StandardOutput quando o script NA EC2 termina. InProgress 10-20 min e normal." -ForegroundColor DarkGray

$poll = 0
while ((Get-Date) -lt $deadline) {
    $poll++
    $status = Get-SsmStatusOnly -Cid $CommandId -Iid $InstanceId -Region $AwsRegion
    $clock = Get-Date -Format 'HH:mm:ss'
    $elapsedMin = [math]::Round(((Get-Date) - $started).TotalMinutes, 1)
    Write-Host "[$clock] Status: $status (decorrido ${elapsedMin} min)" -ForegroundColor Yellow
    if ($poll -eq 1 -or ($poll % 4 -eq 0)) {
        Write-Host "  Homolog pode continuar no ar (versao anterior) ate o script parar o Core e copiar arquivos." -ForegroundColor DarkGray
    }

    switch ($status) {
        'Success' {
            try {
                $inv = Get-SsmInvocationFromFile -Cid $CommandId -Iid $InstanceId -Region $AwsRegion
                Write-SsmTextSafe '--- StandardOutput ---' $inv.StandardOutputContent
                Write-SsmTextSafe '--- StandardError ---' $inv.StandardErrorContent
            } catch {
                Write-Host "(aviso) Status=Success mas nao leu stdout: $_" -ForegroundColor DarkYellow
            }
            Write-Host "Deploy SSM OK." -ForegroundColor Green
            exit 0
        }
        { $_ -in @('Failed', 'Cancelled', 'TimedOut') } {
            $stdout = ''
            try {
                $inv = Get-SsmInvocationFromFile -Cid $CommandId -Iid $InstanceId -Region $AwsRegion
                $stdout = [string]$inv.StandardOutputContent
                Write-SsmTextSafe '--- StandardOutput ---' $stdout
                Write-SsmTextSafe '--- StandardError ---' $inv.StandardErrorContent
            } catch {
                Write-Host "(aviso) nao leu stdout: $_" -ForegroundColor DarkYellow
            }
            if ($status -eq 'Failed' -and ($stdout -match 'Deploy homolog Core( Linux)? OK')) {
                Write-Host "SSM Status=Failed mas stdout confirma deploy OK (falso negativo conhecido)." -ForegroundColor Yellow
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
