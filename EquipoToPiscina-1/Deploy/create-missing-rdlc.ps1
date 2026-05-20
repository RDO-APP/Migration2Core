# Create Missing Teste.rdlc Report Template
# This script creates the missing Teste.rdlc file based on existing RDO report templates

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Create Missing Teste.rdlc Template   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Teste.rdlc already exists
$testeRdlcPath = "rdoappProject\Api\Contents\Reports\Teste.rdlc"
Write-Host "[1/5] Checking if Teste.rdlc exists..." -ForegroundColor Yellow

if (Test-Path $testeRdlcPath) {
    Write-Host "   ⚠ Teste.rdlc already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "   Do you want to overwrite it? (y/N)"
    if ($overwrite -ne 'y' -and $overwrite -ne 'Y') {
        Write-Host "   Aborted by user" -ForegroundColor Gray
        exit 0
    }
} else {
    Write-Host "   ✓ Teste.rdlc does not exist - will create it" -ForegroundColor Green
}

# Step 2: Find suitable template to copy from
Write-Host "`n[2/5] Finding suitable template to copy from..." -ForegroundColor Yellow
$reportsDir = "rdoappProject\Api\Contents\Reports"
$possibleTemplates = @(
    "Rdo_def.rdlc",
    "Rdo.rdlc", 
    "RelatorioEfetivoDiario.rdlc",
    "RelatorioProdutividade.rdlc"
)

$sourceTemplate = $null
foreach ($template in $possibleTemplates) {
    $templatePath = Join-Path $reportsDir $template
    if (Test-Path $templatePath) {
        $sourceTemplate = $templatePath
        Write-Host "   ✓ Found template: $template" -ForegroundColor Green
        break
    }
}

if (-not $sourceTemplate) {
    Write-Host "   ✗ No suitable template found!" -ForegroundColor Red
    Write-Host "   Available files in Reports directory:" -ForegroundColor Gray
    if (Test-Path $reportsDir) {
        Get-ChildItem $reportsDir -Filter "*.rdlc" | ForEach-Object {
            Write-Host "     - $($_.Name)" -ForegroundColor Gray
        }
    }
    exit 1
}

# Step 3: Create backup if overwriting
if (Test-Path $testeRdlcPath) {
    Write-Host "`n[3/5] Creating backup of existing Teste.rdlc..." -ForegroundColor Yellow
    $backupPath = "$testeRdlcPath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $testeRdlcPath $backupPath -Force
    Write-Host "   ✓ Backup created: $(Split-Path $backupPath -Leaf)" -ForegroundColor Green
} else {
    Write-Host "`n[3/5] No backup needed (file doesn't exist)" -ForegroundColor Gray
}

# Step 4: Copy and customize template
Write-Host "`n[4/5] Creating Teste.rdlc from template..." -ForegroundColor Yellow

try {
    # Copy the template
    Copy-Item $sourceTemplate $testeRdlcPath -Force
    Write-Host "   ✓ Copied $(Split-Path $sourceTemplate -Leaf) to Teste.rdlc" -ForegroundColor Green
    
    # Read the content for customization
    $rdlcContent = Get-Content $testeRdlcPath -Raw -Encoding UTF8
    
    # Customize for Laudo (basic replacements)
    $rdlcContent = $rdlcContent -replace 'RDO', 'LAUDO'
    $rdlcContent = $rdlcContent -replace 'Relatório Diário de Obra', 'Laudo de Piscina'
    $rdlcContent = $rdlcContent -replace 'Daily Work Report', 'Pool Inspection Report'
    
    # Update report name/title if present
    $rdlcContent = $rdlcContent -replace '<Name>.*?</Name>', '<Name>LaudoReport</Name>'
    
    # Save the customized content
    Set-Content $testeRdlcPath $rdlcContent -Encoding UTF8
    Write-Host "   ✓ Applied basic Laudo customizations" -ForegroundColor Green
    
} catch {
    Write-Host "   ✗ Error creating Teste.rdlc: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Step 5: Verify creation and provide next steps
Write-Host "`n[5/5] Verifying creation..." -ForegroundColor Yellow

if (Test-Path $testeRdlcPath) {
    $fileInfo = Get-Item $testeRdlcPath
    Write-Host "   ✓ Teste.rdlc created successfully" -ForegroundColor Green
    Write-Host "     Size: $($fileInfo.Length) bytes" -ForegroundColor Gray
    Write-Host "     Created: $($fileInfo.CreationTime)" -ForegroundColor Gray
} else {
    Write-Host "   ✗ Failed to create Teste.rdlc" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Teste.rdlc Created Successfully!     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Open Teste.rdlc in Visual Studio Report Designer" -ForegroundColor White
Write-Host "2. Customize the report layout for Laudo data:" -ForegroundColor White
Write-Host "   - Add fields for water quality parameters (pH, chlorine, etc.)" -ForegroundColor Gray
Write-Host "   - Update data sources to match Laudo model" -ForegroundColor Gray
Write-Host "   - Adjust report title and headers" -ForegroundColor Gray
Write-Host "3. Test PDF generation with the new template" -ForegroundColor White
Write-Host "4. Deploy to homolog environment for testing" -ForegroundColor White

Write-Host ""
Write-Host "Report template structure:" -ForegroundColor Cyan
Write-Host "- Based on: $(Split-Path $sourceTemplate -Leaf)" -ForegroundColor White
Write-Host "- Location: $testeRdlcPath" -ForegroundColor White
Write-Host "- Purpose: Laudo PDF generation" -ForegroundColor White

Write-Host ""
Write-Host "Data sources expected by LaudoModel.cs:" -ForegroundColor Cyan
Write-Host "- dtItensLaudo (water quality parameters)" -ForegroundColor White
Write-Host "- dtAssinaturaContratante (contractor signature)" -ForegroundColor White
Write-Host "- dtAssinaturaContratada (contracted signature)" -ForegroundColor White
Write-Host "- dtImagem (images, if photo report enabled)" -ForegroundColor White

Write-Host ""
Write-Host "Parameters expected:" -ForegroundColor Cyan
Write-Host "- NomeObra, StatusRdo, DataRdo" -ForegroundColor White
Write-Host "- DataInicioObra, DiasDecorridosObra" -ForegroundColor White
Write-Host "- ComentarioRdo, EnderecoObra" -ForegroundColor White
Write-Host "- HabilitarRelatorioFotografico" -ForegroundColor White
Write-Host "- logoContratada" -ForegroundColor White

Write-Host ""
Write-Host "🎉 Template creation complete!" -ForegroundColor Green
Write-Host ""