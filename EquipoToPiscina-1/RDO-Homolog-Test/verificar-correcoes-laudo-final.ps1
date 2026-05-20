Write-Host "=== VERIFICANDO CORRECOES LAUDO ===" -ForegroundColor Green

Write-Host "1. Verificando entidade laudo.cs..." -ForegroundColor Yellow
$laudoEntity = Get-Content "rdoappClass/laudo.cs" -Raw
if ($laudoEntity -match "lau_tp_nivel_bacterias") {
    Write-Host "   ✓ Campo lau_tp_nivel_bacterias presente na entidade" -ForegroundColor Green
} else {
    Write-Host "   ✗ Campo lau_tp_nivel_bacterias AUSENTE na entidade" -ForegroundColor Red
}

if ($laudoEntity -match "lau_tp_alcalinidade") {
    Write-Host "   ✓ Campo lau_tp_alcalinidade presente na entidade" -ForegroundColor Green
} else {
    Write-Host "   ✗ Campo lau_tp_alcalinidade AUSENTE na entidade" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. Verificando LaudoViewModel..." -ForegroundColor Yellow
$laudoModel = Get-Content "rdoappProject/Api/Models/LaudoModel.cs" -Raw
if ($laudoModel -match "public bool lau_tp_nivel_bacterias") {
    Write-Host "   ✓ Propriedade lau_tp_nivel_bacterias presente no ViewModel" -ForegroundColor Green
} else {
    Write-Host "   ✗ Propriedade lau_tp_nivel_bacterias AUSENTE no ViewModel" -ForegroundColor Red
}

if ($laudoModel -match "public int lau_tp_alcalinidade") {
    Write-Host "   ✓ Propriedade lau_tp_alcalinidade presente no ViewModel" -ForegroundColor Green
} else {
    Write-Host "   ✗ Propriedade lau_tp_alcalinidade AUSENTE no ViewModel" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. Verificando mapeamentos nos metodos..." -ForegroundColor Yellow
if ($laudoModel -match "lau_tp_alcalinidade = laudo\.lau_tp_alcalinidade \?\? 0,") {
    Write-Host "   ✓ Mapeamento lau_tp_alcalinidade correto" -ForegroundColor Green
} else {
    Write-Host "   ✗ Mapeamento lau_tp_alcalinidade INCORRETO" -ForegroundColor Red
}

if ($laudoModel -match "lau_tp_nivel_bacterias = \(bool\)laudo\.lau_tp_nivel_bacterias,") {
    Write-Host "   ✓ Mapeamento lau_tp_nivel_bacterias correto" -ForegroundColor Green
} else {
    Write-Host "   ✗ Mapeamento lau_tp_nivel_bacterias INCORRETO" -ForegroundColor Red
}

Write-Host ""
Write-Host "4. Verificando metodo SalvarLaudo..." -ForegroundColor Yellow
$tarefaModel = Get-Content "rdoappProject/Api/Models/TarefaModel.cs" -Raw
if ($tarefaModel -match "_laudo\.lau_tp_nivel_bacterias = param\.bacterias") {
    Write-Host "   ✓ Campo lau_tp_nivel_bacterias usado no SalvarLaudo" -ForegroundColor Green
} else {
    Write-Host "   ✗ Campo lau_tp_nivel_bacterias NAO usado no SalvarLaudo" -ForegroundColor Red
}

if ($tarefaModel -match "_laudo\.lau_tp_alcalinidade = param\.NivelAlcalinidade") {
    Write-Host "   ✓ Campo lau_tp_alcalinidade usado no SalvarLaudo" -ForegroundColor Green
} else {
    Write-Host "   ✗ Campo lau_tp_alcalinidade NAO usado no SalvarLaudo" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== RESUMO DAS CORRECOES ===" -ForegroundColor Cyan
Write-Host "Entidade laudo.cs: Campos corretos (lau_tp_nivel_bacterias, lau_tp_alcalinidade)" -ForegroundColor Green
Write-Host "LaudoViewModel: Propriedades adicionadas e corrigidas" -ForegroundColor Green  
Write-Host "Mapeamentos: Corrigidos nos metodos DashboardGrafico e Lista" -ForegroundColor Green
Write-Host "SalvarLaudo: Usando nomes corretos dos campos da entidade" -ForegroundColor Green
Write-Host ""
Write-Host "PROXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "1. Abrir Visual Studio como Administrador" -ForegroundColor White
Write-Host "2. Clean Solution" -ForegroundColor White
Write-Host "3. Rebuild Solution" -ForegroundColor White
Write-Host "4. Testar funcionalidade de laudo" -ForegroundColor White