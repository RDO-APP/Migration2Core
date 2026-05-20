Write-Host "=== TESTE COLABORADOR COM CPF VÁLIDO ===" -ForegroundColor Green

Write-Host ""
Write-Host "PROBLEMA IDENTIFICADO:" -ForegroundColor Yellow
Write-Host "O CPF 222.222.222-22 é INVÁLIDO segundo o algoritmo brasileiro!" -ForegroundColor Red
Write-Host "CPFs com todos os dígitos iguais são sempre rejeitados." -ForegroundColor Red

Write-Host ""
Write-Host "SOLUÇÃO:" -ForegroundColor Green
Write-Host "Use um CPF válido para teste:" -ForegroundColor White

Write-Host ""
Write-Host "CPFs VÁLIDOS PARA TESTE:" -ForegroundColor Cyan
Write-Host "  123.456.789-09" -ForegroundColor White
Write-Host "  987.654.321-00" -ForegroundColor White  
Write-Host "  147.258.369-40" -ForegroundColor White
Write-Host "  321.654.987-30" -ForegroundColor White

Write-Host ""
Write-Host "DADOS COMPLETOS PARA TESTE:" -ForegroundColor Yellow
Write-Host "  CPF: 123.456.789-09" -ForegroundColor White
Write-Host "  Nome: Usuario Teste" -ForegroundColor White
Write-Host "  Perfil: (selecione um da lista)" -ForegroundColor White
Write-Host "  Cargo: (selecione um da lista)" -ForegroundColor White
Write-Host "  Sexo: M" -ForegroundColor White
Write-Host "  Data Nascimento: 01/01/1990" -ForegroundColor White
Write-Host "  Telefone Principal: (11) 99999-9999" -ForegroundColor White
Write-Host "  Email: teste@teste.com" -ForegroundColor White
Write-Host "  Logradouro: Rua Teste" -ForegroundColor White
Write-Host "  Número: 123" -ForegroundColor White
Write-Host "  UF: (selecione)" -ForegroundColor White
Write-Host "  Município: (selecione)" -ForegroundColor White
Write-Host "  CEP: 01234-567" -ForegroundColor White
Write-Host "  Senha: 1234" -ForegroundColor White
Write-Host "  Confirmação Senha: 1234" -ForegroundColor White

Write-Host ""
Write-Host "INSTRUÇÕES:" -ForegroundColor Green
Write-Host "1. Limpe o formulário" -ForegroundColor White
Write-Host "2. Preencha com os dados acima" -ForegroundColor White
Write-Host "3. Clique em Salvar" -ForegroundColor White
Write-Host "4. Se ainda não funcionar, abra F12 > Network" -ForegroundColor White
Write-Host "5. Tente salvar novamente e veja as requisições HTTP" -ForegroundColor White

Write-Host ""
Write-Host "TESTE AGORA COM CPF VÁLIDO!" -ForegroundColor Cyan