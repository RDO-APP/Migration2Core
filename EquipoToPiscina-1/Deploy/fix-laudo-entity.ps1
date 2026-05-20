# Fix Laudo Entity Framework Issue
# This script implements the specific fix for the "laudo entity not part of model" error

param(
    [switch]$ApplyQuickFix = $false
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fix Laudo Entity Framework Issue     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Backup current files
Write-Host "[1/6] Creating backup of current files..." -ForegroundColor Yellow
$backupFolder = "Deploy\backup\entity-fix-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null

# Backup key files
$filesToBackup = @(
    "rdoappClass\rdoappModel.Context.cs",
    "rdoappClass\laudo.cs",
    "rdoappProject\Api\Models\LaudoModel.cs"
)

foreach ($file in $filesToBackup) {
    if (Test-Path $file) {
        $backupPath = Join-Path $backupFolder (Split-Path $file -Leaf)
        Copy-Item $file $backupPath -Force
        Write-Host "   ✓ Backed up $(Split-Path $file -Leaf)" -ForegroundColor Green
    }
}

# Step 2: Verify laudo entity exists in context
Write-Host "`n[2/6] Verifying laudo entity in DbContext..." -ForegroundColor Yellow
$contextFile = "rdoappClass\rdoappModel.Context.cs"
if (Test-Path $contextFile) {
    $contextContent = Get-Content $contextFile -Raw
    if ($contextContent -like "*public DbSet<laudo> laudo { get; set; }*") {
        Write-Host "   ✓ laudo DbSet found in context" -ForegroundColor Green
    } else {
        Write-Host "   ✗ laudo DbSet NOT found in context" -ForegroundColor Red
        Write-Host "   This indicates the EDMX model needs to be regenerated" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ Context file not found" -ForegroundColor Red
}

# Step 3: Check laudo entity class
Write-Host "`n[3/6] Verifying laudo entity class..." -ForegroundColor Yellow
$laudoFile = "rdoappClass\laudo.cs"
if (Test-Path $laudoFile) {
    $laudoContent = Get-Content $laudoFile -Raw
    if ($laudoContent -like "*public partial class laudo*") {
        Write-Host "   ✓ laudo entity class exists" -ForegroundColor Green
    } else {
        Write-Host "   ✗ laudo entity class malformed" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ laudo.cs file not found" -ForegroundColor Red
}

# Step 4: Apply quick fix if requested
if ($ApplyQuickFix) {
    Write-Host "`n[4/6] Applying quick fix to LaudoModel.cs..." -ForegroundColor Yellow
    $laudoModelFile = "rdoappProject\Api\Models\LaudoModel.cs"
    
    if (Test-Path $laudoModelFile) {
        $laudoModelContent = Get-Content $laudoModelFile -Raw
        
        # Replace direct DbSet access with Set<T> method
        $originalPattern = 'context\.laudo\.'
        $replacementPattern = 'context.Set<laudo>().'
        
        if ($laudoModelContent -match $originalPattern) {
            $updatedContent = $laudoModelContent -replace $originalPattern, $replacementPattern
            Set-Content $laudoModelFile $updatedContent
            Write-Host "   ✓ Applied Set<laudo>() fix to LaudoModel.cs" -ForegroundColor Green
            Write-Host "   Changed: context.laudo. → context.Set<laudo>()." -ForegroundColor Gray
        } else {
            Write-Host "   ⚠ No direct laudo DbSet usage found to fix" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ✗ LaudoModel.cs not found" -ForegroundColor Red
    }
} else {
    Write-Host "`n[4/6] Skipping quick fix (use -ApplyQuickFix to enable)" -ForegroundColor Gray
}

# Step 5: Check EDMX file
Write-Host "`n[5/6] Checking EDMX model..." -ForegroundColor Yellow
$edmxFile = "rdoappClass\rdoappModel.edmx"
if (Test-Path $edmxFile) {
    $edmxContent = Get-Content $edmxFile -Raw
    if ($edmxContent -like "*<EntityType Name=`"laudo`">*") {
        Write-Host "   ✓ laudo entity found in EDMX model" -ForegroundColor Green
    } else {
        Write-Host "   ✗ laudo entity NOT found in EDMX model" -ForegroundColor Red
        Write-Host "   The EDMX model needs to be updated from database" -ForegroundColor Yellow
    }
    
    if ($edmxContent -like "*<EntitySet Name=`"laudo`"*") {
        Write-Host "   ✓ laudo EntitySet found in EDMX model" -ForegroundColor Green
    } else {
        Write-Host "   ✗ laudo EntitySet NOT found in EDMX model" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ EDMX file not found" -ForegroundColor Red
}

# Step 6: Provide recommendations
Write-Host "`n[6/6] Generating recommendations..." -ForegroundColor Yellow

$recommendations = @()

# Check if this is a model sync issue
$contextFile = "rdoappClass\rdoappModel.Context.cs"
$edmxFile = "rdoappClass\rdoappModel.edmx"

if ((Test-Path $contextFile) -and (Test-Path $edmxFile)) {
    $contextContent = Get-Content $contextFile -Raw
    $edmxContent = Get-Content $edmxFile -Raw
    
    $contextHasLaudo = $contextContent -like "*public DbSet<laudo> laudo { get; set; }*"
    $edmxHasLaudo = $edmxContent -like "*<EntityType Name=`"laudo`">*"
    
    if ($edmxHasLaudo -and $contextHasLaudo) {
        $recommendations += "✓ Model appears correct - this is likely a compilation/deployment issue"
        $recommendations += "→ Clean and rebuild the solution"
        $recommendations += "→ Ensure the updated DLL is deployed to the server"
    } elseif ($edmxHasLaudo -and -not $contextHasLaudo) {
        $recommendations += "✗ EDMX has laudo but Context doesn't - regenerate T4 templates"
        $recommendations += "→ Right-click rdoappModel.Context.tt → Run Custom Tool"
    } elseif (-not $edmxHasLaudo) {
        $recommendations += "✗ EDMX missing laudo entity - update model from database"
        $recommendations += "→ Right-click rdoappModel.edmx → Update Model from Database"
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Recommendations                       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

foreach ($rec in $recommendations) {
    if ($rec.StartsWith("✓")) {
        Write-Host $rec -ForegroundColor Green
    } elseif ($rec.StartsWith("✗")) {
        Write-Host $rec -ForegroundColor Red
    } elseif ($rec.StartsWith("→")) {
        Write-Host $rec -ForegroundColor Yellow
    } else {
        Write-Host $rec -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Manual steps required in Visual Studio:" -ForegroundColor Cyan
Write-Host "1. Open the solution in Visual Studio" -ForegroundColor White
Write-Host "2. Right-click rdoappModel.edmx → Update Model from Database" -ForegroundColor White
Write-Host "3. Ensure 'laudo' table is selected for import" -ForegroundColor White
Write-Host "4. Right-click rdoappModel.Context.tt → Run Custom Tool" -ForegroundColor White
Write-Host "5. Right-click rdoappModel.tt → Run Custom Tool" -ForegroundColor White
Write-Host "6. Build Solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "7. Deploy to homolog environment" -ForegroundColor White

if ($ApplyQuickFix) {
    Write-Host ""
    Write-Host "Quick fix applied! Test the application now." -ForegroundColor Green
    Write-Host "If the issue persists, follow the manual steps above." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Backup created at: $backupFolder" -ForegroundColor Gray
Write-Host ""