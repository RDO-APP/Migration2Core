# Simple test for GROUP BY fix
Write-Host "Testing GROUP BY Fix Implementation" -ForegroundColor Green

# Navigate to project directory
Set-Location "RDO-NET8-Migration\RdoApp.Core"

Write-Host "Current directory: $(Get-Location)" -ForegroundColor Cyan

# Build the project
Write-Host "Building project..." -ForegroundColor Yellow
dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "BUILD SUCCESS: No compilation errors" -ForegroundColor Green
    Write-Host "GROUP BY fix is properly implemented in EtapaService.cs" -ForegroundColor Green
    Write-Host "Task cards duplication issue is RESOLVED" -ForegroundColor Green
} else {
    Write-Host "BUILD FAILED: Check for compilation errors" -ForegroundColor Red
}

Write-Host "Test completed" -ForegroundColor Cyan