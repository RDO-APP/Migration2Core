# Create Diagnostic Version of Escolher View
Write-Host "🔧 CREATING DIAGNOSTIC VERSION OF ESCOLHER VIEW" -ForegroundColor Yellow
Write-Host ""

$diagnosticView = @'
@model IEnumerable<dynamic>
@{
    ViewData["Title"] = "Selecionar Obra - DIAGNOSTIC";
    Layout = null;
}

<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>@ViewData["Title"] - RDO App Piscinas</title>
    <link rel="stylesheet" href="~/lib/bootstrap/dist/css/bootstrap.min.css" />
    <style>
        body {
            background: linear-gradient(135deg, #2c5aa0 0%, #1e3a5f 50%, #0f1419 100%);
            min-height: 100vh;
            color: white;
            padding: 20px;
        }
        .diagnostic-info {
            background: rgba(255, 255, 255, 0.1);
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .obra-card {
            background: white;
            color: black;
            padding: 15px;
            margin: 10px;
            border-radius: 8px;
            display: inline-block;
            min-width: 200px;
        }
    </style>
</head>
<body>
    <h1>🔍 DIAGNOSTIC MODE - Obra Selection</h1>
    
    <div class="diagnostic-info">
        <h3>📊 Diagnostic Information</h3>
        <p><strong>Model Type:</strong> @Model?.GetType().Name</p>
        <p><strong>Model Count:</strong> @(Model?.Count() ?? 0)</p>
        <p><strong>User Name:</strong> @ViewBag.UsuarioNome</p>
        <p><strong>User CPF:</strong> @ViewBag.UsuarioCpf</p>
        <p><strong>Is Authenticated:</strong> @User.Identity.IsAuthenticated</p>
        <p><strong>User ID Claim:</strong> @User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value</p>
    </div>

    @if (Model != null && Model.Any())
    {
        <div class="diagnostic-info">
            <h3>✅ SUCCESS: @Model.Count() obras found!</h3>
            <p>Data is being passed correctly to the view.</p>
        </div>
        
        <h3>📋 Obra List:</h3>
        <div>
            @foreach (var obra in Model)
            {
                <div class="obra-card">
                    <h5>@obra.Descricao</h5>
                    <p>ID: @obra.IdObra</p>
                    <p>Local: @obra.CidadeEstado</p>
                    <p>Status: @obra.StatusBasicaGratuita</p>
                    <p>Tipo: @obra.ContratanteContratada</p>
                    <p>Progresso: @obra.ProgressoPorcentagem%</p>
                    <button onclick="escolherObra(@obra.IdObra)" class="btn btn-primary">
                        Escolher Obra @obra.IdObra
                    </button>
                </div>
            }
        </div>
    }
    else
    {
        <div class="diagnostic-info">
            <h3>❌ ISSUE FOUND: No obras in Model</h3>
            <p>The Model is null or empty. This indicates:</p>
            <ul>
                <li>API call failed in ObraController.Escolher()</li>
                <li>User authentication issue</li>
                <li>Database connection problem</li>
                <li>No obras assigned to this user</li>
            </ul>
        </div>
    }

    <div class="diagnostic-info">
        <h3>🔧 Next Steps:</h3>
        <ol>
            <li>If obras are shown above, the issue is in the original view's rendering</li>
            <li>If no obras, check the ObraController.Escolher() method in debugger</li>
            <li>Verify API call returns data in ObraApiController.ObterObras()</li>
            <li>Check user authentication and claims</li>
        </ol>
    </div>

    <script>
        function escolherObra(obraId) {
            console.log('Escolhendo obra:', obraId);
            alert('Obra ' + obraId + ' selecionada! (Diagnostic mode)');
            // In real mode, this would navigate to /Obra/Etapas?obraId=' + obraId
        }
        
        // Log diagnostic info to console
        console.log('🔍 DIAGNOSTIC MODE ACTIVE');
        console.log('Model count:', @(Model?.Count() ?? 0));
        console.log('User authenticated:', @User.Identity.IsAuthenticated.ToString().ToLower());
        console.log('User ID:', '@User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value');
    </script>
</body>
</html>
'@

# Create backup of original view
$originalView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml"
$backupView = "RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml.backup"

if (Test-Path $originalView) {
    Write-Host "1. Creating backup of original view..." -ForegroundColor Green
    Copy-Item $originalView $backupView -Force
    Write-Host "   ✅ Backup created: Escolher.cshtml.backup" -ForegroundColor Green
}

# Create diagnostic view
Write-Host "2. Creating diagnostic view..." -ForegroundColor Green
$diagnosticView | Out-File -FilePath $originalView -Encoding UTF8
Write-Host "   ✅ Diagnostic view created!" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 DIAGNOSTIC VIEW READY!" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor White
Write-Host "1. Open Visual Studio with RdoApp.Core.sln" -ForegroundColor Gray
Write-Host "2. Press F5 to start debugging" -ForegroundColor Gray
Write-Host "3. Navigate to /Obra/Escolher" -ForegroundColor Gray
Write-Host "4. Check the diagnostic information displayed" -ForegroundColor Gray
Write-Host ""
Write-Host "WHAT TO LOOK FOR:" -ForegroundColor Yellow
Write-Host "• Model Count: Should show 103 if API works" -ForegroundColor White
Write-Host "• User ID Claim: Should show a number, not null" -ForegroundColor White
Write-Host "• Obra cards: Should display if data is passed correctly" -ForegroundColor White
Write-Host ""
Write-Host "TO RESTORE ORIGINAL VIEW:" -ForegroundColor Cyan
Write-Host "Copy-Item 'RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml.backup' 'RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml' -Force" -ForegroundColor Gray