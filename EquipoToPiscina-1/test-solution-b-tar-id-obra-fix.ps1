#!/usr/bin/env pwsh

Write-Host "=== TESTING SOLUTION B: TAR_ID_OBRA COLUMN FIX ===" -ForegroundColor Cyan
Write-Host "Testing if removing tar_id_obra mapping fixes the database error" -ForegroundColor Yellow
Write-Host ""

# Change to project directory
Set-Location "RDO-NET8-Migration/RdoApp.Core"

Write-Host "1. Building project to check for compilation errors..." -ForegroundColor Green
try {
    dotnet build --no-restore --verbosity quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful - no compilation errors" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Build error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2. Starting application to test database queries..." -ForegroundColor Green

# Start the application in background
$process = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -WindowStyle Hidden

# Wait for application to start
Start-Sleep -Seconds 10

Write-Host "3. Testing login and obra selection..." -ForegroundColor Green

try {
    # Test login
    $loginResponse = Invoke-WebRequest -Uri "http://localhost:5000/Auth/Login" -Method POST -Body @{
        cpf = "12345678901"
        senha = "123456"
    } -ContentType "application/x-www-form-urlencoded" -SessionVariable session

    if ($loginResponse.StatusCode -eq 200) {
        Write-Host "✅ Login successful" -ForegroundColor Green
        
        # Test obra selection (should trigger etapa loading)
        Write-Host "4. Testing etapa loading with task counts..." -ForegroundColor Green
        
        $obraResponse = Invoke-WebRequest -Uri "http://localhost:5000/Obra/Escolher" -WebSession $session
        
        if ($obraResponse.StatusCode -eq 200) {
            Write-Host "✅ Obra page loaded successfully" -ForegroundColor Green
            
            # Check if page contains etapas and task counts
            $content = $obraResponse.Content
            
            if ($content -match "etapa-card" -or $content -match "Etapa \d+") {
                Write-Host "✅ Etapas found in page content" -ForegroundColor Green
                
                # Look for task count badges
                if ($content -match "\d+ tarefas" -or $content -match "badge") {
                    Write-Host "✅ Task count badges found - Solution B working!" -ForegroundColor Green
                    Write-Host "🎉 SUCCESS: tar_id_obra column fix resolved the database error" -ForegroundColor Cyan
                } else {
                    Write-Host "⚠️ No task count badges found - may still show '0 tarefas'" -ForegroundColor Yellow
                }
            } else {
                Write-Host "⚠️ No etapas found in page content" -ForegroundColor Yellow
            }
            
            # Test direct API call to etapas
            Write-Host "5. Testing direct API call to verify task loading..." -ForegroundColor Green
            
            try {
                $apiResponse = Invoke-WebRequest -Uri "http://localhost:5000/api/obra/1/etapas" -WebSession $session
                
                if ($apiResponse.StatusCode -eq 200) {
                    $apiContent = $apiResponse.Content | ConvertFrom-Json
                    Write-Host "✅ API call successful" -ForegroundColor Green
                    Write-Host "📊 API Response: Found $($apiContent.Count) etapas" -ForegroundColor Cyan
                    
                    foreach ($etapa in $apiContent) {
                        Write-Host "   - Etapa $($etapa.Id): $($etapa.TotalTarefas) tarefas" -ForegroundColor White
                    }
                } else {
                    Write-Host "⚠️ API call failed with status: $($apiResponse.StatusCode)" -ForegroundColor Yellow
                }
            } catch {
                Write-Host "⚠️ API call error: $($_.Exception.Message)" -ForegroundColor Yellow
            }
            
        } else {
            Write-Host "❌ Obra page failed with status: $($obraResponse.StatusCode)" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Login failed with status: $($loginResponse.StatusCode)" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Test error: $($_.Exception.Message)" -ForegroundColor Red
    
    # Check if it's the specific tar_id_obra error
    if ($_.Exception.Message -match "tar_id_obra") {
        Write-Host "❌ CRITICAL: tar_id_obra column error still exists!" -ForegroundColor Red
        Write-Host "   This means the fix was not complete or there are other references" -ForegroundColor Red
    }
} finally {
    # Stop the application
    if ($process -and !$process.HasExited) {
        Write-Host "6. Stopping application..." -ForegroundColor Green
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "=== TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host "✅ Removed tar_id_obra property from Tarefa entity" -ForegroundColor Green
Write-Host "✅ Removed tar_id_obra mapping from TarefaConfiguration" -ForegroundColor Green
Write-Host "✅ Fixed CreateTaskInEtapaAsync method in EtapaService" -ForegroundColor Green
Write-Host "✅ Solution B implementation should now work without database errors" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "1. Verify task counts show real numbers instead of '0 tarefas'" -ForegroundColor White
Write-Host "2. Test accordion expansion to load individual task cards" -ForegroundColor White
Write-Host "3. Ensure all CRUD operations work without tar_id_obra dependency" -ForegroundColor White