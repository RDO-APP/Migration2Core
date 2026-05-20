# Fix Icon Rendering Issue - Simplify Razor Logic
Write-Host "=== FIXING ICON RENDERING ISSUE ===" -ForegroundColor Green

Write-Host "1. Backing up current Escolher.cshtml..." -ForegroundColor Yellow
Copy-Item "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml" "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml.backup" -Force

Write-Host "2. Simplifying icon rendering logic..." -ForegroundColor Yellow

# Read current file
$content = Get-Content "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml" -Raw

# Replace complex Razor logic with simple approach
$oldIconLogic = @'
                            <!-- DYNAMIC ICON SYSTEM - Exact match to Gilberto's implementation -->
                            @if (!string.IsNullOrEmpty(obra.ContratanteContratada))
                            {
                                @* Transform t/d values to full names like Gilberto's backend does *@
                                string iconClass = "";
                                string iconTitle = "";
                                
                                if (obra.ContratanteContratada.ToLower() == "t")
                                {
                                    iconClass = "icon-contratante";
                                    iconTitle = "Contratante";
                                }
                                else if (obra.ContratanteContratada.ToLower() == "d")
                                {
                                    iconClass = "icon-contratada";
                                    iconTitle = "Contratada";
                                }
                                else if (obra.ContratanteContratada.ToLower() == "contratante")
                                {
                                    iconClass = "icon-contratante";
                                    iconTitle = "Contratante";
                                }
                                else if (obra.ContratanteContratada.ToLower() == "contratada")
                                {
                                    iconClass = "icon-contratada";
                                    iconTitle = "Contratada";
                                }
                                else
                                {
                                    // Fallback to raw value (for debugging)
                                    iconClass = $"icon-{obra.ContratanteContratada.ToLower()}";
                                    iconTitle = obra.ContratanteContratada;
                                }
                                
                                <i class="@iconClass" title="@iconTitle"></i>
                            }
                            else
                            {
                                <!-- Fallback icon if no value -->
                                <i class="icon-contratante" title="Tipo não definido"></i>
                            }'@

$newIconLogic = @'
                            <!-- SIMPLIFIED DYNAMIC ICON - Like Gilberto's AngularJS approach -->
                            <i class="icon-@(obra.ContratanteContratada ?? "contratada")" 
                               title="@(obra.ContratanteContratada ?? "contratada")" 
                               data-tipo="@(obra.ContratanteContratada ?? "contratada")"></i>'@

# Replace the complex logic with simple approach
$newContent = $content -replace [regex]::Escape($oldIconLogic), $newIconLogic

# Write updated content
Set-Content "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml" -Value $newContent -Encoding UTF8

Write-Host "3. Adding JavaScript icon transformation..." -ForegroundColor Yellow

# Add JavaScript to handle icon transformation (like AngularJS would)
$jsIconTransform = @'
        
        // ICON TRANSFORMATION - Replicate Gilberto's AngularJS behavior
        function transformIcons() {
            document.querySelectorAll('[class*="icon-"]').forEach(icon => {
                const tipo = icon.getAttribute('data-tipo');
                if (!tipo) return;
                
                // Transform values like Gilberto's system
                let iconClass = '';
                let iconTitle = '';
                
                switch(tipo.toLowerCase()) {
                    case 't':
                    case 'contratante':
                        iconClass = 'icon-contratante';
                        iconTitle = 'Contratante';
                        break;
                    case 'd':
                    case 'contratada':
                        iconClass = 'icon-contratada';
                        iconTitle = 'Contratada';
                        break;
                    default:
                        iconClass = 'icon-contratada';
                        iconTitle = 'Contratada';
                }
                
                // Update icon class and title
                icon.className = iconClass;
                icon.setAttribute('title', iconTitle);
                
                console.log('Icon transformed:', tipo, '->', iconClass);
            });
        }
        
        // Run transformation when page loads
        document.addEventListener('DOMContentLoaded', transformIcons);'@

# Insert JavaScript before the closing script tag
$newContent = $newContent -replace '(\s+</script>\s+</body>)', "$jsIconTransform`$1"

# Write final content
Set-Content "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml" -Value $newContent -Encoding UTF8

Write-Host "4. Testing icon rendering fix..." -ForegroundColor Yellow

# Navigate to project directory and build
Set-Location "RDO-NET8-Migration\RdoApp.Core"

# Quick build test
$buildResult = dotnet build --no-restore --verbosity quiet

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ ICON RENDERING FIX APPLIED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host ""
    Write-Host "CHANGES MADE:" -ForegroundColor Cyan
    Write-Host "1. Simplified Razor icon logic (removed complex if/else)" -ForegroundColor White
    Write-Host "2. Added JavaScript icon transformation (like AngularJS)" -ForegroundColor White
    Write-Host "3. Added data-tipo attribute for client-side processing" -ForegroundColor White
    Write-Host "4. Console logging for debugging icon transformations" -ForegroundColor White
    Write-Host ""
    Write-Host "TEST NOW:" -ForegroundColor Yellow
    Write-Host "1. Press F5 in Visual Studio" -ForegroundColor White
    Write-Host "2. Login with CPF 12345678901" -ForegroundColor White
    Write-Host "3. Check browser console for icon transformation logs" -ForegroundColor White
    Write-Host "4. Verify icons appear on obra cards" -ForegroundColor White
} else {
    Write-Host "❌ BUILD ERROR - Restoring backup..." -ForegroundColor Red
    Copy-Item "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml.backup" "RDO-NET8-Migration\RdoApp.Core\Views\Obra\Escolher.cshtml" -Force
    Write-Host "Backup restored. Please check the error and try again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== ICON FIX PROCESS COMPLETED ===" -ForegroundColor Green