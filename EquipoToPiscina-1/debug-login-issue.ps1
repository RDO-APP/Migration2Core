# 🔍 DEBUG LOGIN ISSUE - Day 8 Authentication
# Vamos investigar por que o login não está funcionando

Write-Host "🔍 INVESTIGANDO PROBLEMA DE LOGIN..." -ForegroundColor Yellow
Write-Host ""

# 1. Verificar se o usuário existe no banco
Write-Host "1️⃣ Verificando se usuário existe no banco..." -ForegroundColor Cyan

$query = @"
SELECT 
    col_id,
    col_nome,
    col_cpf,
    col_senha,
    col_ativo
FROM colaboradores 
WHERE col_cpf = '567.065.455-20'
LIMIT 1;
"@

Write-Host "Query SQL:" -ForegroundColor Yellow
Write-Host $query -ForegroundColor White
Write-Host ""

# 2. Verificar logs da aplicação
Write-Host "2️⃣ Verificando logs da aplicação..." -ForegroundColor Cyan
Write-Host "   Procure no console do Visual Studio por mensagens de erro" -ForegroundColor White
Write-Host ""

# 3. Testar validação de CPF
Write-Host "3️⃣ Testando validação de CPF..." -ForegroundColor Cyan
Write-Host "   CPF de teste: 567.065.455-20" -ForegroundColor White
Write-Host "   Este CPF deve ser válido segundo algoritmo brasileiro" -ForegroundColor White
Write-Host ""

# 4. Verificar conexão com banco
Write-Host "4️⃣ Verificando conexão com banco..." -ForegroundColor Cyan
Write-Host "   Connection String: Server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;Database=piscinas_rdoapp_homologa" -ForegroundColor White
Write-Host ""

Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Green
Write-Host "   1. Execute esta query no DBeaver para verificar se usuário existe" -ForegroundColor White
Write-Host "   2. Verifique logs no console do Visual Studio" -ForegroundColor White
Write-Host "   3. Tente login novamente e observe mensagens de erro" -ForegroundColor White
Write-Host ""