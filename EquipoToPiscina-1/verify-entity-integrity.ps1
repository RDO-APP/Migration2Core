Write-Host "=== VERIFICACAO INTEGRIDADE ENTIDADES ===" -ForegroundColor Green
Write-Host "Verificando se existem propriedades adicionadas incorretamente" -ForegroundColor Yellow
Write-Host ""

Set-Location "RDO-NET8-Migration/RdoApp.Core"

# Lista de entidades para verificar
$entities = @(
    "Models/Entities/Colaborador.cs",
    "Models/Entities/Usuario.cs",
    "Models/Entities/Empresa.cs",
    "Models/Entities/Obra.cs",
    "Models/Entities/Tarefa.cs",
    "Models/Entities/Laudo.cs",
    "Models/Entities/Rdo.cs"
)

# Propriedades que podem ter sido adicionadas incorretamente
$suspiciousProperties = @(
    "PasswordHash",
    "col_password_hash",
    "CreatedAt",
    "UpdatedAt",
    "IsDeleted",
    "Version"
)

Write-Host "Verificando entidades..." -ForegroundColor Cyan

foreach ($entity in $entities) {
    if (Test-Path $entity) {
        $entityName = Split-Path $entity -Leaf
        Write-Host "Verificando: $entityName" -ForegroundColor White
        
        $content = Get-Content $entity -Raw
        $foundIssues = $false
        
        foreach ($property in $suspiciousProperties) {
            if ($content -match $property) {
                if (-not $foundIssues) {
                    Write-Host "  PROBLEMAS ENCONTRADOS:" -ForegroundColor Red
                    $foundIssues = $true
                }
                Write-Host "    - Propriedade suspeita: $property" -ForegroundColor Yellow
                
                # Mostrar contexto
                $lines = $content -split "`n"
                for ($i = 0; $i -lt $lines.Length; $i++) {
                    if ($lines[$i] -match $property) {
                        Write-Host "      Linha $($i+1): $($lines[$i].Trim())" -ForegroundColor Gray
                    }
                }
            }
        }
        
        if (-not $foundIssues) {
            Write-Host "  OK - Nenhum problema encontrado" -ForegroundColor Green
        }
        Write-Host ""
    } else {
        Write-Host "AVISO: $entity nao encontrado" -ForegroundColor Yellow
    }
}

Write-Host "=== RESUMO ===" -ForegroundColor Green
Write-Host "EXPLICACAO DO PROBLEMA:" -ForegroundColor Yellow
Write-Host "1. O script apply-production-security.ps1 foi criado para adicionar PasswordHash ao Usuario" -ForegroundColor White
Write-Host "2. Mas o sistema usa tabela 'colaborador' para autenticacao, nao 'usuario'" -ForegroundColor White
Write-Host "3. Alguem pode ter aplicado PasswordHash ao Colaborador incorretamente" -ForegroundColor White
Write-Host "4. O banco homolog nao tem coluna col_password_hash" -ForegroundColor White
Write-Host ""
Write-Host "SOLUCAO:" -ForegroundColor Yellow
Write-Host "- PasswordHash deve existir APENAS em Usuario.cs (se usado)" -ForegroundColor White
Write-Host "- Colaborador.cs deve usar apenas col_ds_senha (senha legada)" -ForegroundColor White
Write-Host "- AuthService deve trabalhar com senha legada para homolog" -ForegroundColor White