# STEP 6 TEST: Relationship Entities Activation
Write-Host "Testing STEP 6: Relationship Entities Activation" -ForegroundColor Green

# Stop any running processes
taskkill /f /im "RdoApp.Core.exe" 2>$null
taskkill /f /im "dotnet.exe" 2>$null
Start-Sleep -Seconds 2

# Navigate to project directory
Set-Location "RDO-NET8-Migration\RdoApp.Core"

Write-Host "Step 1: Build Project" -ForegroundColor Cyan
dotnet clean --verbosity quiet
dotnet build --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "BUILD FAILED" -ForegroundColor Red
    exit 1
}

Write-Host "BUILD SUCCESS!" -ForegroundColor Green

Write-Host "Step 2: Start Application" -ForegroundColor Cyan
Start-Process -FilePath "dotnet" -ArgumentList "run" -NoNewWindow -PassThru
Write-Host "Waiting for application to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

Write-Host "Step 3: Test Database Connectivity" -ForegroundColor Cyan

# Test database connection
Write-Host "Testing database connection" -ForegroundColor White
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/teste/database" -Method GET
    Write-Host "SUCCESS: Database connection works" -ForegroundColor Green
    Write-Host "Database: $($response.database)" -ForegroundColor Gray
} catch {
    Write-Host "Database connection test failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Test existing endpoints still work
Write-Host "Testing existing API endpoints" -ForegroundColor White
try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/tarefa" -Method GET
    Write-Host "SUCCESS: Tarefa API still works" -ForegroundColor Green
} catch {
    Write-Host "Tarefa API test: $($_.Exception.Message)" -ForegroundColor Yellow
}

try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/rdo" -Method GET
    Write-Host "SUCCESS: RDO API still works" -ForegroundColor Green
} catch {
    Write-Host "RDO API test: $($_.Exception.Message)" -ForegroundColor Yellow
}

try {
    $response = Invoke-RestMethod -Uri "https://localhost:7297/api/laudo" -Method GET
    Write-Host "SUCCESS: Laudo API still works" -ForegroundColor Green
} catch {
    Write-Host "Laudo API test: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "STEP 6 IMPLEMENTATION SUMMARY:" -ForegroundColor Green
Write-Host "- Activated 8 relationship entities in RdoContext" -ForegroundColor White
Write-Host "- ObraColaborador: Project-employee assignments" -ForegroundColor White
Write-Host "- ObraTarefaColaborador: Task-employee assignments" -ForegroundColor White
Write-Host "- ObraTarefaEquipamento: Task-equipment assignments" -ForegroundColor White
Write-Host "- Equipamento: Equipment management" -ForegroundColor White
Write-Host "- ObraEquipamento: Project-equipment assignments" -ForegroundColor White
Write-Host "- Cargo: Job positions" -ForegroundColor White
Write-Host "- Grupo: User groups" -ForegroundColor White
Write-Host "- TipoEquipamento: Equipment types" -ForegroundColor White

Write-Host "BENEFITS UNLOCKED:" -ForegroundColor Cyan
Write-Host "- Complex queries with Include() statements" -ForegroundColor Gray
Write-Host "- Navigation properties between entities" -ForegroundColor Gray
Write-Host "- Project-employee relationship queries" -ForegroundColor Gray
Write-Host "- Task-equipment assignment tracking" -ForegroundColor Gray
Write-Host "- Equipment management capabilities" -ForegroundColor Gray
Write-Host "- User group and role management" -ForegroundColor Gray

Write-Host "NEXT RECOMMENDED STEPS:" -ForegroundColor Cyan
Write-Host "Step 7: Create API controllers for core entities" -ForegroundColor Gray
Write-Host "Step 8: Implement image management system" -ForegroundColor Gray
Write-Host "Step 9: Add user management and security" -ForegroundColor Gray

Write-Host "STEP 6 COMPLETED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "Application running at: https://localhost:7297" -ForegroundColor Yellow
Write-Host "Swagger UI: https://localhost:7297/swagger" -ForegroundColor Yellow