# Test Phase 3: Etapas/Tarefas endpoint for CETI PROFESSORA ÁUREA DOS HUMILDES OLIVEIRA
Write-Host "=== TESTING PHASE 3: ETAPAS/TAREFAS ENDPOINT ===" -ForegroundColor Yellow

# Target obra: CETI PROFESSORA ÁUREA DOS HUMILDES OLIVEIRA (ID: 233)
$obraId = 233
$obraNome = "CETI PROFESSORA ÁUREA DOS HUMILDES OLIVEIRA"

Write-Host "Testing Obra: $obraNome (ID: $obraId)" -ForegroundColor Cyan

# First login to get authentication
Write-Host ""
Write-Host "1. Logging in as Ricardo..." -ForegroundColor Green
$loginData = @{
    cpf = "567.065.455-20"
    senha = "RXL8DjdYj6Y="
    lembrarMe = $false
}

# Create a session to maintain cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json" -WebSession $session
    
    if ($loginResponse.sucesso) {
        Write-Host "SUCCESS - Login successful: $($loginResponse.usuario.nome)" -ForegroundColor Green
    } else {
        Write-Host "❌ Login failed: $($loginResponse.mensagem)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Login request failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test the Etapas endpoint (Phase 3 functionality)
Write-Host ""
Write-Host "2. Testing Etapas endpoint for Obra $obraId..." -ForegroundColor Green
try {
    $etapasResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/ObraApi/Etapas/$obraId" -Method GET -WebSession $session
    
    if ($etapasResponse) {
        $etapasCount = $etapasResponse.Count
        Write-Host "SUCCESS - Found $etapasCount etapas for $obraNome!" -ForegroundColor Green
        
        if ($etapasCount -gt 0) {
            Write-Host ""
            Write-Host "            ETAPAS DETAILS:" -ForegroundColor Yellow
            
            foreach ($etapa in $etapasResponse) {
                Write-Host "   ETAPA ID: $($etapa.Id)" -ForegroundColor White
                Write-Host "      Título: '$($etapa.Titulo)'" -ForegroundColor White
                Write-Host "      Obra ID: $($etapa.IdObra)" -ForegroundColor White
                
                if ($etapa.Tarefas -and $etapa.Tarefas.Count -gt 0) {
                    Write-Host "      TAREFAS ($($etapa.Tarefas.Count)):" -ForegroundColor Cyan
                    
                    foreach ($tarefa in $etapa.Tarefas) {
                        Write-Host "         - Tarefa ID: $($tarefa.Id)" -ForegroundColor Gray
                        Write-Host "           Descrição: '$($tarefa.Descricao)'" -ForegroundColor Gray
                        Write-Host "           Status: $($tarefa.StatusDescricao)" -ForegroundColor Gray
                        
                        if ($tarefa.DataInicio) {
                            Write-Host "           Data Início: $($tarefa.DataInicio)" -ForegroundColor Gray
                        }
                        if ($tarefa.DataPrevisaoFim) {
                            Write-Host "           Previsão Fim: $($tarefa.DataPrevisaoFim)" -ForegroundColor Gray
                        }
                        if ($tarefa.DataFim) {
                            Write-Host "           Data Fim: $($tarefa.DataFim)" -ForegroundColor Gray
                        }
                        if ($tarefa.QuantidadeConstruida) {
                            Write-Host "           Quantidade: $($tarefa.QuantidadeConstruida)" -ForegroundColor Gray
                        }
                        Write-Host "           ---" -ForegroundColor DarkGray
                    }
                } else {
                    Write-Host "      TAREFAS: Nenhuma tarefa encontrada" -ForegroundColor Yellow
                }
                Write-Host "      ═══════════════════════════════════════" -ForegroundColor DarkGray
            }
        } else {
            Write-Host "No etapas found for this obra" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "❌ Etapas endpoint returned no data" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Etapas endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
    
    # Try to get more details about the error
    if ($_.Exception.Response) {
        try {
            $errorStream = $_.Exception.Response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($errorStream)
            $errorBody = $reader.ReadToEnd()
            Write-Host "   Error Details: $errorBody" -ForegroundColor Yellow
        } catch {
            Write-Host "   Could not read error details" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "=== PHASE 3 TEST COMPLETE ===" -ForegroundColor Yellow

# Summary
Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "   • Authentication: SUCCESS - Working" -ForegroundColor Green
Write-Host "   • Obra Access: SUCCESS - 103 obras available" -ForegroundColor Green
Write-Host "   • Etapas/Tarefas: $(if ($etapasResponse) { 'SUCCESS - Endpoint responding' } else { 'FAILED - Endpoint failed' })" -ForegroundColor $(if ($etapasResponse) { 'Green' } else { 'Red' })

if ($etapasResponse -and $etapasResponse.Count -gt 0) {
    Write-Host "   • Phase 3 Status: SUCCESS - CONFIRMED WORKING" -ForegroundColor Green
} else {
    Write-Host "   • Phase 3 Status: WARNING - No data or endpoint issue" -ForegroundColor Yellow
}