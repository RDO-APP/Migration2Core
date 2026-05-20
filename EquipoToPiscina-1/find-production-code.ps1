# 🔍 FIND PRODUCTION CODE SCRIPT
# This script searches for the actual production code with the modern interface

Write-Host "🔍 SEARCHING FOR PRODUCTION CODE" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check the fresh clone for different branches
Write-Host "`n[1/4] Checking fresh clone branches..." -ForegroundColor Yellow
if (Test-Path "EquipoToPiscina-Updated") {
    Push-Location "EquipoToPiscina-Updated"
    
    Write-Host "Available branches in fresh clone:" -ForegroundColor White
    try {
        $branches = git branch -a
        foreach ($branch in $branches) {
            Write-Host "   $branch" -ForegroundColor Gray
        }
        
        Write-Host "`nTrying to checkout feature branches..." -ForegroundColor Yellow
        
        # Try the most promising branches
        $targetBranches = @(
            "feature/atualizar_estrutura_dados_laudo",
            "feature/implementa_laudo_piscinas",
            "gilberto"
        )
        
        foreach ($branch in $targetBranches) {
            Write-Host "Trying branch: $branch" -ForegroundColor White
            try {
                git checkout $branch 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "   ✅ Successfully switched to $branch" -ForegroundColor Green
                    
                    # Check if this branch has the modern interface
                    Write-Host "   Checking for modern interface elements..." -ForegroundColor Gray
                    
                    $hasModernInterface = $false
                    
                    # Search for modern interface elements
                    $searchResults = Select-String -Path "rdoappProject\Client\Views\**\*.html" -Pattern "Alcalinidade|Materiais flutuantes|Areia no fundo" -ErrorAction SilentlyContinue
                    
                    if ($searchResults) {
                        Write-Host "   🎉 FOUND MODERN INTERFACE IN BRANCH: $branch" -ForegroundColor Green
                        Write-Host "   Files with modern interface:" -ForegroundColor White
                        foreach ($result in $searchResults) {
                            Write-Host "      - $($result.Filename)" -ForegroundColor Gray
                        }
                        $hasModernInterface = $true
                        break
                    } else {
                        Write-Host "   ❌ No modern interface found in $branch" -ForegroundColor Red
                    }
                } else {
                    Write-Host "   ❌ Failed to switch to $branch" -ForegroundColor Red
                }
            } catch {
                Write-Host "   ❌ Error checking branch $branch" -ForegroundColor Red
            }
        }
        
    } catch {
        Write-Host "   ❌ Error accessing Git repository" -ForegroundColor Red
    }
    
    Pop-Location
} else {
    Write-Host "   ❌ Fresh clone not found" -ForegroundColor Red
}

# Search in current directory for any files with modern interface
Write-Host "`n[2/4] Searching current directory for modern interface..." -ForegroundColor Yellow
$modernFiles = Get-ChildItem -Recurse -Include "*.html", "*.js", "*.cs" | Select-String -Pattern "Alcalinidade|Materiais flutuantes|Areia no fundo" -ErrorAction SilentlyContinue

if ($modernFiles) {
    Write-Host "   🎉 FOUND MODERN INTERFACE FILES:" -ForegroundColor Green
    foreach ($file in $modernFiles) {
        Write-Host "      - $($file.Filename): $($file.Line.Trim())" -ForegroundColor Gray
    }
} else {
    Write-Host "   ❌ No modern interface files found in current directory" -ForegroundColor Red
}

# Check for recent commits that might indicate updates
Write-Host "`n[3/4] Checking recent Git commits..." -ForegroundColor Yellow
try {
    $recentCommits = git log --oneline -10 --grep="laudo\|piscina\|interface\|nova" --all 2>$null
    if ($recentCommits) {
        Write-Host "   Recent commits related to laudo/interface:" -ForegroundColor White
        foreach ($commit in $recentCommits) {
            Write-Host "      $commit" -ForegroundColor Gray
        }
    } else {
        Write-Host "   No recent relevant commits found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Error checking Git commits" -ForegroundColor Red
}

# Check for deployment or production folders
Write-Host "`n[4/4] Checking for deployment/production folders..." -ForegroundColor Yellow
$searchPaths = @(
    "..\*prod*",
    "..\*deploy*",
    "..\*server*",
    "..\..\*prod*",
    "..\..\*deploy*",
    "C:\inetpub\*rdoapp*",
    "C:\inetpub\*piscina*"
)

$foundProdFolders = @()
foreach ($path in $searchPaths) {
    try {
        $folders = Get-ChildItem $path -Directory -ErrorAction SilentlyContinue
        if ($folders) {
            $foundProdFolders += $folders
        }
    } catch {
        # Ignore access errors
    }
}

if ($foundProdFolders.Count -gt 0) {
    Write-Host "   🎯 POTENTIAL PRODUCTION LOCATIONS:" -ForegroundColor Green
    foreach ($folder in $foundProdFolders) {
        Write-Host "      - $($folder.FullName)" -ForegroundColor Gray
    }
} else {
    Write-Host "   No obvious production folders found" -ForegroundColor Yellow
}

Write-Host "`n" -ForegroundColor White
Write-Host "📋 SUMMARY & NEXT STEPS:" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If modern interface was found above:" -ForegroundColor Green
Write-Host "   1. Copy the files from that location to RDO-Homolog-Test/" -ForegroundColor White
Write-Host "   2. Apply Entity Framework fixes" -ForegroundColor White
Write-Host "   3. Test the updated homolog environment" -ForegroundColor White
Write-Host ""
Write-Host "If NO modern interface was found:" -ForegroundColor Yellow
Write-Host "   1. Check with your team where the production code is deployed" -ForegroundColor White
Write-Host "   2. Look for the server deployment location" -ForegroundColor White
Write-Host "   3. Check if there's a separate production repository" -ForegroundColor White
Write-Host ""
Write-Host "🎯 WHAT WE NEED:" -ForegroundColor Cyan
Write-Host "The code that generates this interface:" -ForegroundColor White
Write-Host "   - Dropdown fields: Quantidade, Cloro, PH, Alcalinidade" -ForegroundColor Gray
Write-Host "   - Grid with: Limpidez, Materiais flutuantes, Areia no fundo, Algas, Detritos" -ForegroundColor Gray
Write-Host "   - Photo upload functionality" -ForegroundColor Gray
Write-Host ""
Write-Host "📞 Please report back with the results!" -ForegroundColor Green