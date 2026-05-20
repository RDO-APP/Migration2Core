# Script to rebuild the rdoappClass project and fix Entity Framework model issues

Write-Host "=== Rebuilding rdoappClass Project ===" -ForegroundColor Green

# Step 1: Clean bin and obj folders
Write-Host "`n1. Cleaning bin and obj folders..." -ForegroundColor Yellow
if (Test-Path "rdoappClass\bin") {
    Remove-Item "rdoappClass\bin" -Recurse -Force
    Write-Host "   - Removed bin folder" -ForegroundColor Gray
}
if (Test-Path "rdoappClass\obj") {
    Remove-Item "rdoappClass\obj" -Recurse -Force
    Write-Host "   - Removed obj folder" -ForegroundColor Gray
}

# Step 2: Clean rdoappProject bin folder
Write-Host "`n2. Cleaning rdoappProject bin folder..." -ForegroundColor Yellow
if (Test-Path "rdoappProject\bin") {
    Remove-Item "rdoappProject\bin" -Recurse -Force
    Write-Host "   - Removed rdoappProject bin folder" -ForegroundColor Gray
}

Write-Host "`n=== Clean Complete ===" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Open the solution in Visual Studio"
Write-Host "2. Right-click on rdoappModel.edmx -> Open With -> XML Editor"
Write-Host "3. Save the file (Ctrl+S)"
Write-Host "4. Right-click on rdoappModel.tt -> Run Custom Tool"
Write-Host "5. Right-click on rdoappModel.Context.tt -> Run Custom Tool"
Write-Host "6. Build the solution (Ctrl+Shift+B)"
Write-Host "7. Publish/Deploy to the server"
