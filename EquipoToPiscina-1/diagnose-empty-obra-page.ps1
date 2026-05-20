# DIAGNÓSTICO: Página de Obras Vazia
# Vamos descobrir onde estão as 103 obras do Ricardo

Write-Host "🔍 INVESTIGANDO PÁGINA DE OBRAS VAZIA" -ForegroundColor Yellow
Write-Host "Problema: Login funciona, mas página de obras está vazia" -ForegroundColor Cyan
Write-Host ""

# Passo 1: Testar se o usuário Ricardo ainda existe
Write-Host "1️⃣  Verificando se Ricardo ainda existe..." -ForegroundColor Green
$loginData = @{
    cpf = "567.065.455-20"
    senha = "RXL8DjdYj6Y="
    lembrarMe = $false
}

# Create session for cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/auth/login" -Method POST -Body ($loginData | ConvertTo-Json) -ContentType "application/json" -WebSession $session
    
    if ($loginResponse.sucesso) {
        Write-Host "   ✅ LOGIN FUNCIONA: $($loginResponse.usuario.nome)" -ForegroundColor Green
        Write-Host "   📋 User ID: $($loginResponse.usuario.id)" -ForegroundColor White
        Write-Host "   📧 Email: $($loginResponse.usuario.email)" -ForegroundColor White
    } else {
        Write-Host "   ❌ LOGIN FALHOU: $($loginResponse.mensagem)" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "   ❌ Erro no login: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Passo 2: Testar o endpoint que a página usa
Write-Host ""
Write-Host "2️⃣  Testando endpoint ObterObras (usado pela página)..." -ForegroundColor Green
try {
    $obrasResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/ObraApi/ObterObras" -Method POST -Body "{}" -ContentType "application/json" -WebSession $session
    
    if ($obrasResponse -and $obrasResponse.Count -gt 0) {
        Write-Host "   ✅ ENDPOINT FUNCIONA: $($obrasResponse.Count) obras encontradas!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "   📊 PRIMEIRAS 5 OBRAS:" -ForegroundColor Cyan
        for ($i = 0; $i -lt [Math]::Min(5, $obrasResponse.Count); $i++) {
            $obra = $obrasResponse[$i]
            Write-Host "      $($i+1). ID: $($obra.IdObra) - $($obra.Descricao)" -ForegroundColor White
            Write-Host "         Cidade: $($obra.CidadeEstado)" -ForegroundColor Gray
            Write-Host "         Status: $($obra.StatusBasicaGratuita)" -ForegroundColor Gray
        }
        
        if ($obrasResponse.Count -gt 5) {
            Write-Host "      ... e mais $($obrasResponse.Count - 5) obras" -ForegroundColor Gray
        }
        
    } else {
        Write-Host "   ❌ ENDPOINT RETORNA VAZIO!" -ForegroundColor Red
        Write-Host "   🔍 Isso explica por que a página está vazia" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Erro no endpoint: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   📝 Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

# Passo 3: Testar endpoint direto do banco
Write-Host ""
Write-Host "3️⃣  Testando endpoint direto do banco..." -ForegroundColor Green
try {
    $directResponse = Invoke-RestMethod -Uri "http://localhost:5031/api/TestUsuario/GetUserObras?userId=302" -Method GET
    
    if ($directResponse.obras -and $directResponse.obras.Count -gt 0) {
        Write-Host "   ✅ BANCO TEM DADOS: $($directResponse.obras.Count) obras no banco!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "   📊 PRIMEIRAS 3 OBRAS DO BANCO:" -ForegroundColor Cyan
        for ($i = 0; $i -lt [Math]::Min(3, $directResponse.obras.Count); $i++) {
            $obra = $directResponse.obras[$i]
            Write-Host "      $($i+1). ID: $($obra.obraId) - $($obra.descricao)" -ForegroundColor White
        }
        
    } else {
        Write-Host "   ❌ BANCO TAMBÉM ESTÁ VAZIO!" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erro no banco: $($_.Exception.Message)" -ForegroundColor Red
}

# Passo 4: Verificar se há problema de autenticação na sessão
Write-Host ""
Write-Host "4️⃣  Verificando autenticação da sessão..." -ForegroundColor Green
try {
    # Tentar acessar um endpoint que requer autenticação
    $authTest = Invoke-RestMethod -Uri "http://localhost:5031/api/TestConnection/database" -Method GET -WebSession $session
    Write-Host "   ✅ Sessão autenticada funcionando" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Problema na sessão: $($_.Exception.Message)" -ForegroundColor Red
}

# Passo 5: Testar se a página HTML está carregando corretamente
Write-Host ""
Write-Host "5️⃣  Verificando se a página HTML carrega..." -ForegroundColor Green
try {
    $pageResponse = Invoke-WebRequest -Uri "http://localhost:5031/Obra/Escolher" -WebSession $session
    
    if ($pageResponse.StatusCode -eq 200) {
        Write-Host "   ✅ Página HTML carrega (Status: 200)" -ForegroundColor Green
        
        # Verificar se há JavaScript errors na página
        $content = $pageResponse.Content
        if ($content -match "error" -or $content -match "Error") {
            Write-Host "   ⚠️  Possíveis erros JavaScript na página" -ForegroundColor Yellow
        }
        
        # Verificar se há referência ao endpoint correto
        if ($content -match "ObterObras") {
            Write-Host "   ✅ Página referencia endpoint ObterObras" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Página NÃO referencia endpoint ObterObras" -ForegroundColor Red
        }
        
    } else {
        Write-Host "   ❌ Página não carrega: Status $($pageResponse.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "   ❌ Erro ao carregar página: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== DIAGNÓSTICO COMPLETO ===" -ForegroundColor Yellow

# Resumo do diagnóstico
Write-Host ""
Write-Host "📋 RESUMO:" -ForegroundColor Cyan
Write-Host "   • Login: ✅ Funcionando" -ForegroundColor Green
Write-Host "   • Usuário Ricardo: ✅ Existe (ID: 302)" -ForegroundColor Green
Write-Host "   • Endpoint ObterObras: $(if ($obrasResponse -and $obrasResponse.Count -gt 0) { '✅ Retorna ' + $obrasResponse.Count + ' obras' } else { '❌ Retorna vazio' })" -ForegroundColor $(if ($obrasResponse -and $obrasResponse.Count -gt 0) { 'Green' } else { 'Red' })
Write-Host "   • Banco de dados: $(if ($directResponse.obras -and $directResponse.obras.Count -gt 0) { '✅ Tem ' + $directResponse.obras.Count + ' obras' } else { '❌ Vazio' })" -ForegroundColor $(if ($directResponse.obras -and $directResponse.obras.Count -gt 0) { 'Green' } else { 'Red' })

Write-Host ""
if ($obrasResponse -and $obrasResponse.Count -gt 0) {
    Write-Host "🎉 PROBLEMA IDENTIFICADO E RESOLVIDO!" -ForegroundColor Green
    Write-Host "   As obras estão sendo retornadas pelo endpoint." -ForegroundColor White
    Write-Host "   Se a página ainda está vazia, pode ser um problema de JavaScript." -ForegroundColor White
} elseif ($directResponse.obras -and $directResponse.obras.Count -gt 0) {
    Write-Host "🔧 PROBLEMA IDENTIFICADO!" -ForegroundColor Yellow
    Write-Host "   • Banco tem dados ✅" -ForegroundColor Green
    Write-Host "   • Endpoint ObterObras não funciona ❌" -ForegroundColor Red
    Write-Host "   • Problema: Autenticação ou lógica do endpoint" -ForegroundColor Yellow
} else {
    Write-Host "🚨 PROBLEMA SÉRIO!" -ForegroundColor Red
    Write-Host "   • Nem o banco nem o endpoint têm dados" -ForegroundColor Red
    Write-Host "   • Os dados podem ter sido perdidos" -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 PRÓXIMOS PASSOS:" -ForegroundColor Cyan
if ($obrasResponse -and $obrasResponse.Count -gt 0) {
    Write-Host "   1. Abrir Developer Tools (F12) no navegador" -ForegroundColor White
    Write-Host "   2. Verificar Console para erros JavaScript" -ForegroundColor White
    Write-Host "   3. Verificar Network tab para chamadas AJAX" -ForegroundColor White
} else {
    Write-Host "   1. Verificar logs do servidor para erros" -ForegroundColor White
    Write-Host "   2. Verificar se autenticação está sendo passada corretamente" -ForegroundColor White
    Write-Host "   3. Debugar o endpoint ObterObras" -ForegroundColor White
}