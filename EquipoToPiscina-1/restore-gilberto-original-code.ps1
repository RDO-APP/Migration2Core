Write-Host "=== RESTAURANDO CODIGO ORIGINAL GILBERTO ===" -ForegroundColor Green
Write-Host "Removendo funcionalidades extras e mantendo apenas o essencial" -ForegroundColor Yellow
Write-Host ""

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# 1. Verificar se Usuario.cs tem PasswordHash (deve manter para produção futura)
Write-Host "1. Verificando Usuario.cs..." -ForegroundColor Cyan
$usuarioFile = "Models/Entities/Usuario.cs"
if (Test-Path $usuarioFile) {
    $usuarioContent = Get-Content $usuarioFile -Raw
    if ($usuarioContent -match "PasswordHash") {
        Write-Host "   Usuario.cs tem PasswordHash (OK - para uso futuro)" -ForegroundColor Yellow
    } else {
        Write-Host "   Usuario.cs sem PasswordHash (OK)" -ForegroundColor Green
    }
} else {
    Write-Host "   Usuario.cs nao encontrado" -ForegroundColor Red
}

# 2. Verificar se Colaborador.cs está limpo (sem PasswordHash)
Write-Host "2. Verificando Colaborador.cs..." -ForegroundColor Cyan
$colaboradorFile = "Models/Entities/Colaborador.cs"
if (Test-Path $colaboradorFile) {
    $colaboradorContent = Get-Content $colaboradorFile -Raw
    if ($colaboradorContent -match "PasswordHash") {
        Write-Host "   ERRO: Colaborador.cs tem PasswordHash (deve ser removido)" -ForegroundColor Red
    } else {
        Write-Host "   Colaborador.cs limpo (OK)" -ForegroundColor Green
    }
} else {
    Write-Host "   Colaborador.cs nao encontrado" -ForegroundColor Red
}

# 3. Verificar AuthService (deve usar apenas senha legada)
Write-Host "3. Verificando AuthService..." -ForegroundColor Cyan
$authServiceFile = "Services/Implementations/AuthService.cs"
if (Test-Path $authServiceFile) {
    $authContent = Get-Content $authServiceFile -Raw
    if ($authContent -match "PasswordHash") {
        Write-Host "   ERRO: AuthService ainda referencia PasswordHash" -ForegroundColor Red
    } else {
        Write-Host "   AuthService limpo (OK)" -ForegroundColor Green
    }
    
    if ($authContent -match "BCrypt") {
        Write-Host "   AVISO: AuthService tem referencia BCrypt (remover)" -ForegroundColor Yellow
    } else {
        Write-Host "   AuthService sem BCrypt (OK)" -ForegroundColor Green
    }
} else {
    Write-Host "   AuthService nao encontrado" -ForegroundColor Red
}

# 4. Verificar se há arquivos de segurança extras
Write-Host "4. Verificando arquivos de seguranca extras..." -ForegroundColor Cyan
$securityFiles = @(
    "Configuration/SecurityConfiguration.cs",
    "appsettings.Production.json"
)

foreach ($file in $securityFiles) {
    if (Test-Path $file) {
        Write-Host "   Arquivo extra encontrado: $file (manter para futuro)" -ForegroundColor Yellow
    }
}

# 5. Compilar para verificar se está tudo OK
Write-Host "5. Compilando projeto..." -ForegroundColor Cyan
try {
    $buildResult = dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Compilacao: SUCESSO" -ForegroundColor Green
    } else {
        Write-Host "   Compilacao: ERRO" -ForegroundColor Red
    }
} catch {
    Write-Host "   Erro ao compilar: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== RESUMO ===" -ForegroundColor Green
Write-Host "PRINCIPIO: Manter codigo exatamente como Gilberto" -ForegroundColor Yellow
Write-Host ""
Write-Host "DEVE ESTAR ASSIM:" -ForegroundColor White
Write-Host "- Colaborador.cs: Apenas campos originais, sem PasswordHash" -ForegroundColor White
Write-Host "- AuthService: Apenas validacao senha legada (col_ds_senha)" -ForegroundColor White
Write-Host "- Banco: Usar piscinas_rdoapp_homologa (homolog)" -ForegroundColor White
Write-Host "- Login: CPF + Senha simples, sem hash" -ForegroundColor White
Write-Host ""
Write-Host "FUNCIONALIDADES FUTURAS:" -ForegroundColor Cyan
Write-Host "- PasswordHash, BCrypt, RBAC, etc. -> FUTURE-SECURITY-RBAC-PLAN.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "PROXIMO PASSO:" -ForegroundColor Yellow
Write-Host "1. Compile no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Execute com F5" -ForegroundColor White
Write-Host "3. Teste login: CPF 567.065.455-20, Senha 1234" -ForegroundColor White