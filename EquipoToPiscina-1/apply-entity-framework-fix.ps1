# 🔧 APPLY ENTITY FRAMEWORK FIX TO PRODUCTION
# This script applies the Entity Framework fixes to resolve "entity type laudo is not part of the model" error

Write-Host "🔧 APPLYING ENTITY FRAMEWORK FIX FOR LAUDO ERROR" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

# Check if LaudoModel.cs exists
$laudoModelPath = "rdoappProject\Api\Models\LaudoModel.cs"

if (Test-Path $laudoModelPath) {
    Write-Host "✅ Found LaudoModel.cs at: $laudoModelPath" -ForegroundColor Green
    
    # Create backup
    $backupPath = "$laudoModelPath.backup"
    Copy-Item $laudoModelPath $backupPath
    Write-Host "✅ Backup created: $backupPath" -ForegroundColor Green
    
    # Read the file content
    $content = Get-Content $laudoModelPath -Raw
    
    # Apply the fixes
    Write-Host "🔄 Applying Entity Framework fixes..." -ForegroundColor Yellow
    
    $originalContent = $content
    
    # Replace all instances of context.laudo with context.Set<laudo>()
    $content = $content -replace 'context\.laudo\.FirstOrDefault\(', 'context.Set<laudo>().FirstOrDefault('
    $content = $content -replace 'context\.laudo\.ToList\(', 'context.Set<laudo>().ToList('
    $content = $content -replace 'context\.laudo\.Where\(', 'context.Set<laudo>().Where('
    $content = $content -replace 'context\.laudo\.Find\(', 'context.Set<laudo>().Find('
    $content = $content -replace 'context\.laudo\.Add\(', 'context.Set<laudo>().Add('
    $content = $content -replace 'context\.laudo\.Remove\(', 'context.Set<laudo>().Remove('
    $content = $content -replace 'context\.laudo\.Any\(', 'context.Set<laudo>().Any('
    $content = $content -replace 'context\.laudo\.Count\(', 'context.Set<laudo>().Count('
    $content = $content -replace 'context\.laudo\.Single\(', 'context.Set<laudo>().Single('
    $content = $content -replace 'context\.laudo\.SingleOrDefault\(', 'context.Set<laudo>().SingleOrDefault('
    
    # Check if any changes were made
    if ($content -ne $originalContent) {
        # Write the updated content back to the file
        Set-Content $laudoModelPath $content -Encoding UTF8
        Write-Host "✅ Entity Framework fixes applied successfully!" -ForegroundColor Green
        Write-Host "📝 Changes made:" -ForegroundColor Yellow
        Write-Host "   - Replaced 'context.laudo' with 'context.Set<laudo>()'" -ForegroundColor White
        Write-Host "   - This fixes the 'entity type laudo is not part of the model' error" -ForegroundColor White
    } else {
        Write-Host "ℹ️  No changes needed - file already uses correct syntax" -ForegroundColor Blue
    }
    
} else {
    Write-Host "❌ LaudoModel.cs not found at: $laudoModelPath" -ForegroundColor Red
    Write-Host "🔍 Searching for LaudoModel.cs in other locations..." -ForegroundColor Yellow
    
    # Search for the file
    $foundFiles = Get-ChildItem -Recurse -Name "LaudoModel.cs" -ErrorAction SilentlyContinue
    
    if ($foundFiles) {
        Write-Host "📁 Found LaudoModel.cs files:" -ForegroundColor Green
        foreach ($file in $foundFiles) {
            Write-Host "   - $file" -ForegroundColor White
        }
        Write-Host "💡 Please update the script path or run it from the correct directory" -ForegroundColor Yellow
    } else {
        Write-Host "❌ LaudoModel.cs not found in current directory tree" -ForegroundColor Red
        Write-Host "💡 This might be in a different branch or deployment location" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎯 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Test the application locally if possible" -ForegroundColor White
Write-Host "2. Deploy to production during maintenance window" -ForegroundColor White
Write-Host "3. Test /laudos/index page immediately after deployment" -ForegroundColor White
Write-Host "4. Monitor for 'entity type laudo is not part of the model' errors" -ForegroundColor White
Write-Host "5. Rollback using .backup file if any issues occur" -ForegroundColor White

Write-Host ""
Write-Host "✅ SCRIPT COMPLETED" -ForegroundColor Green