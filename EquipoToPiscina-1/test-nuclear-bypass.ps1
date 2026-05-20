# TEST NUCLEAR BYPASS - Disable Custom Middleware
# This tests if custom middleware is blocking the response

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NUCLEAR BYPASS TEST" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This test disables custom middleware to see if it's blocking the response." -ForegroundColor Yellow
Write-Host ""

Write-Host "⚠️ WARNING: This will temporarily disable legacy route redirects" -ForegroundColor Red
Write-Host ""

Write-Host "STEP 1: Backup Program.cs" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "Creating backup..." -ForegroundColor White

$programCs = "RDO-NET8-Migration/RdoApp.Core/Program.cs"
$backupCs = "RDO-NET8-Migration/RdoApp.Core/Program.cs.backup-nuclear"

if (Test-Path $programCs) {
    Copy-Item $programCs $backupCs -Force
    Write-Host "✅ Backup created: $backupCs" -ForegroundColor Green
} else {
    Write-Host "❌ Program.cs not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "STEP 2: Comment Out Custom Middleware" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "Reading Program.cs..." -ForegroundColor White

$content = Get-Content $programCs -Raw

# Find the custom middleware block
$middlewareStart = $content.IndexOf("// RESTRICTED SCOPE: Custom middleware ONLY handles legacy page redirects")
$middlewareEnd = $content.IndexOf("// Map Blazor Hub for TaskCard component")

if ($middlewareStart -gt 0 -and $middlewareEnd -gt $middlewareStart) {
    Write-Host "✅ Found custom middleware block" -ForegroundColor Green
    
    # Extract the middleware block
    $before = $content.Substring(0, $middlewareStart)
    $middleware = $content.Substring($middlewareStart, $middlewareEnd - $middlewareStart)
    $after = $content.Substring($middlewareEnd)
    
    # Comment out the middleware
    $commentedMiddleware = "/*`n" + $middleware + "`n*/"
    
    # Reconstruct the file
    $newContent = $before + $commentedMiddleware + "`n`n" + $after
    
    # Write the modified content
    Set-Content $programCs $newContent -NoNewline
    
    Write-Host "✅ Custom middleware commented out" -ForegroundColor Green
} else {
    Write-Host "❌ Could not find custom middleware block!" -ForegroundColor Red
    Write-Host "You'll need to manually comment it out." -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "STEP 3: Restart Application" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "You need to restart the application manually:" -ForegroundColor White
Write-Host "1. Press Ctrl+C to stop current application" -ForegroundColor Cyan
Write-Host "2. Run: cd RDO-NET8-Migration/RdoApp.Core" -ForegroundColor Cyan
Write-Host "3. Run: dotnet run" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 4: Test Escolher Page" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "Navigate to: https://localhost:7201/Obra/Escolher" -ForegroundColor Cyan
Write-Host ""

Write-Host "STEP 5: Check Results" -ForegroundColor Green
Write-Host "---------------------------------------"
Write-Host "EXPECTED RESULTS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ If page renders (shows obra cards)" -ForegroundColor Green
Write-Host "   → Custom middleware WAS blocking the response" -ForegroundColor White
Write-Host "   → Need to fix middleware logic" -ForegroundColor White
Write-Host ""
Write-Host "❌ If page is still blank" -ForegroundColor Red
Write-Host "   → Issue is NOT in custom middleware" -ForegroundColor White
Write-Host "   → Need to check view file and routing" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Press Enter when you've completed the test..." -ForegroundColor Yellow
Read-Host

Write-Host ""
Write-Host "What did you see?" -ForegroundColor Yellow
Write-Host "1) Page renders with obra cards (Middleware was blocking)" -ForegroundColor Green
Write-Host "2) Page is still blank (Issue is elsewhere)" -ForegroundColor Red
Write-Host ""
$result = Read-Host "Enter 1 or 2"

Write-Host ""

switch ($result) {
    "1" {
        Write-Host "✅ MIDDLEWARE WAS THE PROBLEM!" -ForegroundColor Green
        Write-Host ""
        Write-Host "The custom middleware was blocking the response." -ForegroundColor White
        Write-Host ""
        Write-Host "SOLUTION:" -ForegroundColor Yellow
        Write-Host "The middleware checks for '/obra/' (lowercase) but the route is '/Obra/Escolher' (capital O)." -ForegroundColor White
        Write-Host ""
        Write-Host "Fix: The middleware already uses .ToLower() so this should work." -ForegroundColor White
        Write-Host "But let's verify the middleware logic is correct." -ForegroundColor White
        Write-Host ""
        Write-Host "Do you want to restore the original Program.cs and apply a fix? (Y/N)" -ForegroundColor Yellow
        $restore = Read-Host
        
        if ($restore -eq "Y" -or $restore -eq "y") {
            Write-Host ""
            Write-Host "Restoring original Program.cs..." -ForegroundColor White
            Copy-Item $backupCs $programCs -Force
            Write-Host "✅ Original Program.cs restored" -ForegroundColor Green
            Write-Host ""
            Write-Host "Now I'll create a fixed version with better middleware logic." -ForegroundColor Yellow
        }
    }
    "2" {
        Write-Host "❌ ISSUE IS NOT IN MIDDLEWARE!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Restoring original Program.cs..." -ForegroundColor White
        Copy-Item $backupCs $programCs -Force
        Write-Host "✅ Original Program.cs restored" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next step: Check view file existence" -ForegroundColor Yellow
        Write-Host "Run: Test-Path 'RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml'" -ForegroundColor Cyan
    }
    default {
        Write-Host "Invalid input. Restoring original Program.cs..." -ForegroundColor Red
        Copy-Item $backupCs $programCs -Force
        Write-Host "✅ Original Program.cs restored" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Backup file preserved at: $backupCs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
