# Executar busca do ultimo colaborador criado no banco homologa
# Para encontrar o usuario teste criado pelo usuario

Write-Host "Buscando ultimo colaborador criado no banco homologa..." -ForegroundColor Green

# Mostrar o conteudo do arquivo SQL para execucao manual
Write-Host "`nExecute esta consulta no DBeaver ou MySQL Workbench:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Get-Content "verificar-ultimo-colaborador-criado.sql" | Write-Host -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan

Write-Host "`nO que estamos procurando:" -ForegroundColor Yellow
Write-Host "- Colaborador criado recentemente" -ForegroundColor White
Write-Host "- Com poucas obras (1-2 obras maximo)" -ForegroundColor White
Write-Host "- CPF para login de teste" -ForegroundColor White
Write-Host "- Alternativa ao Ricardo (103 obras)" -ForegroundColor White

Write-Host "`nInstrucoes:" -ForegroundColor Yellow
Write-Host "1. Abra o DBeaver" -ForegroundColor White
Write-Host "2. Conecte no banco: piscinas_rdoapp_homologa" -ForegroundColor White
Write-Host "3. Execute as consultas acima" -ForegroundColor White
Write-Host "4. Procure pelo colaborador com data de insercao mais recente" -ForegroundColor White