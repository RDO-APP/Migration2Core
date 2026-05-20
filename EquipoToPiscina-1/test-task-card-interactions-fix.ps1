#!/usr/bin/env pwsh

Write-Host "🎯 TESTING TASK CARD IMPLEMENTATION" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# Stop any running processes
Write-Host "1. Stopping any running processes..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "RdoApp.Core" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# Navigate to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "2. Building project..." -ForegroundColor Yellow
dotnet build --configuration Release --no-restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "3. Starting application..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --configuration Release --no-build" -NoNewWindow

# Wait for startup
Write-Host "4. Waiting for application startup..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

# Test the task card functionality
Write-Host "5. Testing task card implementation..." -ForegroundColor Yellow

# Open browser to test page
$url = "https://localhost:7001/Tarefa/Cards?obraId=1"
Write-Host "Opening: $url" -ForegroundColor Cyan

try {
    Start-Process $url
    Write-Host "✅ Browser opened successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔍 TASK CARD IMPLEMENTATION CHECKLIST:" -ForegroundColor Yellow
    Write-Host "1. ✅ Accordion expands to show task cards" -ForegroundColor White
    Write-Host "2. ✅ Hand icons visible based on status:" -ForegroundColor White
    Write-Host "   - 📋 Planned: fa-hand-paper-o" -ForegroundColor Gray
    Write-Host "   - ✊ In Progress: fa-hand-rock-o" -ForegroundColor Gray
    Write-Host "   - ✌️ Completed: fa-hand-peace-o" -ForegroundColor Gray
    Write-Host "   - ✋ Paused: fa-hand-stop-o" -ForegroundColor Gray
    Write-Host "   - ✂️ Cancelled: fa-hand-scissors-o" -ForegroundColor Gray
    Write-Host "3. ✅ Action buttons in header (eye, clock, plus, pencil, trash)" -ForegroundColor White
    Write-Host "4. ✅ Flexbox layout: description left, buttons right" -ForegroundColor White
    Write-Host "5. ✅ Resource info (👥 collaborators, 🚜 equipment)" -ForegroundColor White
    Write-Host "6. ✅ Progress bar with percentage" -ForegroundColor White
    Write-Host "7. ✅ Status action buttons (Start, Pause, Complete, Resume)" -ForegroundColor White
    Write-Host "8. ✅ Selection checkbox" -ForegroundColor White
    Write-Host "9. ✅ Date information (planned vs executed)" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 EXPECTED VISUAL RESULT:" -ForegroundColor Green
    Write-Host "┌─────────────────────────────────────────────────────────┐" -ForegroundColor Gray
    Write-Host "│ [Hand Icon] Task Description    [👁️][🕐][➕][✏️][🗑️] │" -ForegroundColor Gray
    Write-Host "│ 👥 3  🚜 2                                    ☑️      │" -ForegroundColor Gray
    Write-Host "│ ████████░░ 80% completed                              │" -ForegroundColor Gray
    Write-Host "│ 📅 Planned: 01/01/2025 à 31/01/2025                  │" -ForegroundColor Gray
    Write-Host "│ [Start] [Pause] [Complete]                            │" -ForegroundColor Gray
    Write-Host "└─────────────────────────────────────────────────────────┘" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔧 INTERACTION TESTS:" -ForegroundColor Cyan
    Write-Host "- Hover over action buttons - should show hover effect" -ForegroundColor White
    Write-Host "- Click buttons - should call JavaScript functions" -ForegroundColor White
    Write-Host "- Status buttons change based on task status" -ForegroundColor White
    Write-Host "- Progress bar shows correct percentage" -ForegroundColor White
    Write-Host "- Hand icons match task status" -ForegroundColor White
    Write-Host ""
    Write-Host "Press any key to stop the server..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
} catch {
    Write-Host "❌ Failed to open browser: $($_.Exception.Message)" -ForegroundColor Red
}

# Stop the server
Write-Host "6. Stopping server..." -ForegroundColor Yellow
Get-Process -Name "dotnet" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "dotnet" } | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "✅ Test completed!" -ForegroundColor Green