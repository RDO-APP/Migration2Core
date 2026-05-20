# Criar Banco do Zero - Day 6 Fix
Write-Host "=== CRIANDO BANCO DO ZERO - DAY 6 ===" -ForegroundColor Green

Write-Host "`n1. Parando aplicação..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*RdoApp*"} | Stop-Process -Force -ErrorAction SilentlyContinue

Write-Host "`n2. Removendo migrations antigas..." -ForegroundColor Yellow
Set-Location "RDO-NET8-Migration\RdoApp.Core"
Remove-Item "Migrations" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n3. Criando migration inicial..." -ForegroundColor Yellow
dotnet ef migrations add InitialCreate

Write-Host "`n4. Criando banco novo..." -ForegroundColor Yellow
dotnet ef database update

Write-Host "`n5. Compilando projeto..." -ForegroundColor Yellow
dotnet build

Write-Host "`n6. Iniciando aplicação..." -ForegroundColor Yellow
Start-Process -FilePath "dotnet" -ArgumentList "run --urls http://localhost:5031" -WindowStyle Hidden

Write-Host "`nAguardando 8 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 8

Write-Host "`n7. Testando endpoints..." -ForegroundColor Yellow
try {
    $conexao = Invoke-RestMethod -Uri "http://localhost:5031/api/teste/conexao" -Method GET
    Write-Host "✅ Conexão: $($conexao.message)" -ForegroundColor Green
    
    $tarefas = Invoke-RestMethod -Uri "http://localhost:5031/api/tarefa" -Method GET
    Write-Host "✅ Tarefas: Retornou $($tarefas.Count) registros (banco vazio = normal)" -ForegroundColor Green
    
    Write-Host "`n🎉 SUCESSO! Banco criado do zero!" -ForegroundColor Green
    Write-Host "Swagger: http://localhost:5031/swagger" -ForegroundColor Cyan
    Write-Host "API Tarefas: http://localhost:5031/api/tarefa" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Erro: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== BANCO NOVO PRONTO! ===" -ForegroundColor Green