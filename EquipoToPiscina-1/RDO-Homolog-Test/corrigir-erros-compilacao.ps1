# Corrigir Erros de Compilação
Write-Host "CORRIGINDO ERROS DE COMPILAÇÃO..." -ForegroundColor Green

Set-Location "rdoappProject"

# Corrigir TarefaModel.cs - conversões int para string
Write-Host "1. Corrigindo TarefaModel.cs..." -ForegroundColor Cyan
$tarefaModel = Get-Content "Api\Models\TarefaModel.cs" -Raw

# Corrigir conversões int para string
$tarefaModel = $tarefaModel -replace 'IdTarefa', 'IdTarefa.ToString()'
$tarefaModel = $tarefaModel -replace 'IdObra', 'IdObra.ToString()'
$tarefaModel = $tarefaModel -replace 'IdEtapa', 'IdEtapa.ToString()'
$tarefaModel = $tarefaModel -replace 'IdEquipamento', 'IdEquipamento.ToString()'

# Salvar arquivo corrigido
$tarefaModel | Set-Content "Api\Models\TarefaModel.cs"
Write-Host "   - TarefaModel.cs corrigido" -ForegroundColor Green

# Corrigir EquipamentosModel.cs
Write-Host "2. Corrigindo EquipamentosModel.cs..." -ForegroundColor Cyan
if (Test-Path "Api\Models\EquipamentosModel.cs") {
    $equipModel = Get-Content "Api\Models\EquipamentosModel.cs" -Raw
    
    # Adicionar declaração de variável 'ex' se não existir
    if ($equipModel -notmatch 'var ex\s*=') {
        $equipModel = $equipModel -replace 'catch\s*\{', 'catch (Exception ex) {'
    }
    
    $equipModel | Set-Content "Api\Models\EquipamentosModel.cs"
    Write-Host "   - EquipamentosModel.cs corrigido" -ForegroundColor Green
}

# Corrigir LoginModel.cs
Write-Host "3. Corrigindo LoginModel.cs..." -ForegroundColor Cyan
if (Test-Path "Api\Models\LoginModel.cs") {
    $loginModel = Get-Content "Api\Models\LoginModel.cs" -Raw
    
    # Adicionar declaração de variável 'ex' se não existir
    if ($loginModel -notmatch 'var ex\s*=') {
        $loginModel = $loginModel -replace 'catch\s*\{', 'catch (Exception ex) {'
    }
    
    $loginModel | Set-Content "Api\Models\LoginModel.cs"
    Write-Host "   - LoginModel.cs corrigido" -ForegroundColor Green
}

# Corrigir RdoModel.cs
Write-Host "4. Corrigindo RdoModel.cs..." -ForegroundColor Cyan
if (Test-Path "Api\Models\RdoModel.cs") {
    $rdoModel = Get-Content "Api\Models\RdoModel.cs" -Raw
    
    # Adicionar declaração de variável 'ex' se não existir
    if ($rdoModel -notmatch 'var ex\s*=') {
        $rdoModel = $rdoModel -replace 'catch\s*\{', 'catch (Exception ex) {'
    }
    
    $rdoModel | Set-Content "Api\Models\RdoModel.cs"
    Write-Host "   - RdoModel.cs corrigido" -ForegroundColor Green
}

# Corrigir RamoModel.cs
Write-Host "5. Corrigindo RamoModel.cs..." -ForegroundColor Cyan
if (Test-Path "Api\Models\RamoModel.cs") {
    $ramoModel = Get-Content "Api\Models\RamoModel.cs" -Raw
    
    # Adicionar declaração de variável 'ex' se não existir
    if ($ramoModel -notmatch 'var ex\s*=') {
        $ramoModel = $ramoModel -replace 'catch\s*\{', 'catch (Exception ex) {'
    }
    
    $ramoModel | Set-Content "Api\Models\RamoModel.cs"
    Write-Host "   - RamoModel.cs corrigido" -ForegroundColor Green
}

Write-Host "`n6. Tentando recompilar..." -ForegroundColor Cyan

# Limpar bin e obj
Remove-Item "bin" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "obj" -Recurse -Force -ErrorAction SilentlyContinue

# Tentar compilar com dotnet
try {
    dotnet build --configuration Release --verbosity quiet
    
    if (Test-Path "bin") {
        Write-Host "✅ COMPILAÇÃO SUCESSO!" -ForegroundColor Green
        Write-Host "Aplicação pronta para testar!" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Ainda há erros de compilação" -ForegroundColor Red
        Write-Host "Verifique os erros no Visual Studio" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erro na compilação: $($_.Exception.Message)" -ForegroundColor Red
}

Set-Location ".."
Write-Host "`nCorreções aplicadas!" -ForegroundColor Magenta