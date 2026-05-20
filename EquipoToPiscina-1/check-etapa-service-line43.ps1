# Check specifically line 43 of EtapaService.cs
Write-Host "=== CHECKING LINE 43 OF ETAPASERVICE.CS ===" -ForegroundColor Yellow

$etapaServicePath = "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/EtapaService.cs"

if (Test-Path $etapaServicePath) {
    $lines = Get-Content $etapaServicePath
    
    Write-Host "Total lines in file: $($lines.Count)" -ForegroundColor Green
    
    # Show lines around 43
    for ($i = 40; $i -le 45; $i++) {
        if ($i -lt $lines.Count) {
            $lineContent = $lines[$i-1]  # Arrays are 0-based
            $marker = if ($i -eq 43) { " <-- LINE 43" } else { "" }
            Write-Host "Line $i`: $lineContent$marker" -ForegroundColor $(if ($i -eq 43) { "Red" } else { "White" })
        }
    }
    
    # Check if !e.Ativo exists anywhere
    Write-Host ""
    Write-Host "Searching for '!e.Ativo' in entire file..." -ForegroundColor Yellow
    $foundLines = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "!e\.Ativo") {
            $foundLines += "Line $($i+1): $($lines[$i].Trim())"
        }
    }
    
    if ($foundLines.Count -gt 0) {
        Write-Host "FOUND !e.Ativo in these lines:" -ForegroundColor Red
        $foundLines | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    } else {
        Write-Host "!e.Ativo NOT FOUND anywhere in the file" -ForegroundColor Green
    }
}
else {
    Write-Host "File not found: $etapaServicePath" -ForegroundColor Red
}