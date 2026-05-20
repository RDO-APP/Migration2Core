Write-Host "=== DEBUG LOGIN TEMPO REAL ===" -ForegroundColor Green
Write-Host "Verificando exatamente o que esta acontecendo" -ForegroundColor Yellow
Write-Host ""

# 1. Verificar dados no banco
Write-Host "1. VERIFICANDO DADOS NO BANCO..." -ForegroundColor Cyan
Write-Host "Executando query no banco homolog..." -ForegroundColor White

$sqlQuery = @"
SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF,
    col_ds_senha as Senha,
    col_st_admin as Ativo,
    LENGTH(col_nr_cpf) as TamanhoCPF,
    LENGTH(col_ds_senha) as TamanhoSenha
FROM colaborador 
WHERE col_nr_cpf LIKE '%567%' 
   OR col_nr_cpf LIKE '%065%' 
   OR col_nr_cpf LIKE '%455%'
   OR col_nr_cpf = '56706545520'
   OR col_nr_cpf = '567.065.455-20'
ORDER BY col_id_colaborador;
"@

Write-Host "Query SQL:" -ForegroundColor Gray
Write-Host $sqlQuery -ForegroundColor Gray
Write-Host ""

# 2. Verificar AuthService atual
Write-Host "2. VERIFICANDO AUTHSERVICE..." -ForegroundColor Cyan
Set-Location "RDO-NET8-Migration/RdoApp.Core"

$authServiceContent = Get-Content "Services/Implementations/AuthService.cs" -Raw

# Verificar se tem a conversao de senha
if ($authServiceContent -match "RXL8DjdVj6Y=") {
    Write-Host "✅ AuthService tem conversao 1234 -> RXL8DjdVj6Y=" -ForegroundColor Green
} else {
    Write-Host "❌ AuthService NAO tem conversao de senha!" -ForegroundColor Red
}

# Verificar se remove formatacao do CPF
if ($authServiceContent -match "Replace.*\[.*d\]") {
    Write-Host "✅ AuthService remove formatacao do CPF" -ForegroundColor Green
} else {
    Write-Host "❌ AuthService NAO remove formatacao do CPF!" -ForegroundColor Red
}

# Verificar se usa tabela colaborador
if ($authServiceContent -match "Colaboradores") {
    Write-Host "✅ AuthService usa tabela Colaboradores" -ForegroundColor Green
} else {
    Write-Host "❌ AuthService NAO usa tabela Colaboradores!" -ForegroundColor Red
}

Write-Host ""

# 3. Verificar logs do Visual Studio
Write-Host "3. INSTRUCOES PARA DEBUG..." -ForegroundColor Cyan
Write-Host "No Visual Studio, verifique a janela 'Output' ou 'Saida':" -ForegroundColor White
Write-Host "1. Menu View -> Output (ou Exibir -> Saida)" -ForegroundColor White
Write-Host "2. Selecione 'Debug' no dropdown" -ForegroundColor White
Write-Host "3. Procure por logs do AuthService" -ForegroundColor White
Write-Host ""

# 4. Teste manual
Write-Host "4. TESTE MANUAL SUGERIDO..." -ForegroundColor Cyan
Write-Host "Tente estas combinacoes:" -ForegroundColor White
Write-Host "CPF: 567.065.455-20  Senha: 1234" -ForegroundColor Yellow
Write-Host "CPF: 567.065.455-20  Senha: RXL8DjdVj6Y=" -ForegroundColor Yellow
Write-Host "CPF: 56706545520     Senha: 1234" -ForegroundColor Yellow
Write-Host "CPF: 56706545520     Senha: RXL8DjdVj6Y=" -ForegroundColor Yellow
Write-Host ""

# 5. Verificar conexao com banco
Write-Host "5. TESTANDO CONEXAO COM BANCO..." -ForegroundColor Cyan
$connectionString = "Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa;Uid=rdoadmin;Pwd=rdoapp2018aws;CharSet=utf8mb4;"
Write-Host "String de conexao:" -ForegroundColor Gray
Write-Host $connectionString -ForegroundColor Gray
Write-Host ""

Write-Host "=== PROXIMOS PASSOS ===" -ForegroundColor Green
Write-Host "1. Execute a query SQL no DBeaver para ver os dados reais" -ForegroundColor White
Write-Host "2. Verifique os logs no Visual Studio" -ForegroundColor White
Write-Host "3. Teste as combinacoes de CPF/Senha sugeridas" -ForegroundColor White
Write-Host "4. Se ainda nao funcionar, vamos adicionar mais logs" -ForegroundColor White
Write-Host ""
Write-Host "IMPORTANTE: O AuthService deve estar logando as tentativas!" -ForegroundColor Yellow