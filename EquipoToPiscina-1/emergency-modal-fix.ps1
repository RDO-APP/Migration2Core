# QUICK FIX - If modal still doesn't work
Write-Host "Applying emergency fixes..." -ForegroundColor Yellow

# Force restart application
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3
Start-Process -FilePath "dotnet" -ArgumentList "run", "--project", "RDO-NET8-Migration/RdoApp.Core" -NoNewWindow

Write-Host "Emergency fixes applied. Test again in 15 seconds." -ForegroundColor Green
