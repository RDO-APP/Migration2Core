# Fix EtapaService.cs - Remove !e.Ativo filter that's causing empty results
Write-Host "=== FIXING ETAPA ATIVO FILTER ===" -ForegroundColor Yellow

$etapaServicePath = "RDO-NET8-Migration/RdoApp.Core/Services/Implementations/EtapaService.cs"

if (Test-Path $etapaServicePath) {
    Write-Host "Reading EtapaService.cs..." -ForegroundColor Green
    
    $content = Get-Content $etapaServicePath -Raw
    
    # Check if the problematic filter exists
    if ($content -match "!e\.Ativo") {
        Write-Host "FOUND PROBLEMATIC FILTER: !e.Ativo" -ForegroundColor Red
        
        # Replace the problematic filter
        $newContent = $content -replace "\.Where\(e => e\.ObraId == obraId && !e\.Ativo\)", ".Where(e => e.ObraId == obraId)"
        
        # Save the corrected file
        Set-Content -Path $etapaServicePath -Value $newContent -Encoding UTF8
        
        Write-Host "FIXED: Removed !e.Ativo filter" -ForegroundColor Green
        Write-Host "Now the query will return ACTIVE etapas instead of INACTIVE ones" -ForegroundColor Green
    }
    else {
        Write-Host "Filter !e.Ativo NOT FOUND in current file" -ForegroundColor Yellow
        Write-Host "Checking what filters exist..." -ForegroundColor Yellow
        
        # Show current Where clauses
        $lines = Get-Content $etapaServicePath
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "\.Where\(") {
                Write-Host "Line $($i+1): $($lines[$i].Trim())" -ForegroundColor Cyan
            }
        }
    }
}
else {
    Write-Host "EtapaService.cs not found at: $etapaServicePath" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== NEXT STEPS ===" -ForegroundColor Yellow
Write-Host "1. Recompile the project" -ForegroundColor White
Write-Host "2. Test the etapas page" -ForegroundColor White
Write-Host "3. Check if etapas are now visible" -ForegroundColor White