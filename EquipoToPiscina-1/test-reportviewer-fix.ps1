# Test ReportViewer Fix for Laudo PDF Generation
# This script helps test the ReportViewer functionality

Write-Host "🔧 TESTANDO CORREÇÃO DO REPORTVIEWER" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green

$webConfigPath = "RDO-Homolog-Test\rdoappProject\Web.config"
$rdlcPath = "RDO-Homolog-Test\rdoappProject\Api\Contents\Reports\Teste.rdlc"
$laudoModelPath = "RDO-Homolog-Test\rdoappProject\Api\Models\LaudoModel.cs"

Write-Host ""
Write-Host "📋 VERIFICANDO ARQUIVOS:" -ForegroundColor Cyan

# Check Web.config
if (Test-Path $webConfigPath) {
    $webConfigContent = Get-Content $webConfigPath -Raw
    
    if ($webConfigContent -match "Microsoft\.ReportViewer\.Common.*Version=11\.0\.0\.0") {
        Write-Host "✅ Web.config: ReportViewer assemblies habilitados" -ForegroundColor Green
    } else {
        Write-Host "❌ Web.config: ReportViewer assemblies não encontrados" -ForegroundColor Red
    }
    
    if ($webConfigContent -match "ReportViewerWebControlHandler") {
        Write-Host "✅ Web.config: ReportViewer handlers habilitados" -ForegroundColor Green
    } else {
        Write-Host "❌ Web.config: ReportViewer handlers não encontrados" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Web.config não encontrado" -ForegroundColor Red
}

# Check RDLC file
if (Test-Path $rdlcPath) {
    $rdlcContent = Get-Content $rdlcPath -Raw
    
    if ($rdlcContent -match "dtItensLaudo") {
        Write-Host "✅ Teste.rdlc: Dataset dtItensLaudo encontrado" -ForegroundColor Green
    } else {
        Write-Host "❌ Teste.rdlc: Dataset dtItensLaudo não encontrado" -ForegroundColor Red
    }
    
    if ($rdlcContent -match "lau_tp_nivel_cloro") {
        Write-Host "✅ Teste.rdlc: Campos de laudo encontrados" -ForegroundColor Green
    } else {
        Write-Host "❌ Teste.rdlc: Campos de laudo não encontrados" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Teste.rdlc não encontrado" -ForegroundColor Red
}

# Check LaudoModel.cs
if (Test-Path $laudoModelPath) {
    $laudoModelContent = Get-Content $laudoModelPath -Raw
    
    if ($laudoModelContent -match "using Microsoft\.Reporting\.WebForms;") {
        Write-Host "✅ LaudoModel.cs: Using ReportViewer habilitado" -ForegroundColor Green
    } else {
        Write-Host "❌ LaudoModel.cs: Using ReportViewer não encontrado" -ForegroundColor Red
    }
    
    if ($laudoModelContent -match "dtItensLaudo") {
        Write-Host "✅ LaudoModel.cs: Uso do dtItensLaudo encontrado" -ForegroundColor Green
    } else {
        Write-Host "❌ LaudoModel.cs: Uso do dtItensLaudo não encontrado" -ForegroundColor Red
    }
} else {
    Write-Host "❌ LaudoModel.cs não encontrado" -ForegroundColor Red
}

Write-Host ""
Write-Host "🧪 PRÓXIMOS PASSOS PARA TESTAR:" -ForegroundColor Cyan
Write-Host "1. Compile o projeto no Visual Studio (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "2. Execute o projeto (F5)" -ForegroundColor White
Write-Host "3. Faça login: 567.065.455-20 / 1234" -ForegroundColor White
Write-Host "4. Crie um novo laudo" -ForegroundColor White
Write-Host "5. Vá no histórico (botão relógio)" -ForegroundColor White
Write-Host "6. Clique no botão impressora para gerar PDF" -ForegroundColor White

Write-Host ""
Write-Host "📋 CORREÇÕES APLICADAS:" -ForegroundColor Cyan
Write-Host "✅ ReportViewer assemblies habilitados no Web.config" -ForegroundColor Green
Write-Host "✅ ReportViewer handlers habilitados no Web.config" -ForegroundColor Green
Write-Host "✅ Dataset dtItensLaudo adicionado ao Teste.rdlc" -ForegroundColor Green
Write-Host "✅ Using Microsoft.Reporting.WebForms habilitado" -ForegroundColor Green

Write-Host ""
Write-Host "⚠️  POSSÍVEIS PROBLEMAS:" -ForegroundColor Yellow
Write-Host "- Se houver erro de compilação, pode ser necessário instalar o pacote Microsoft.ReportViewer.WebForms via NuGet" -ForegroundColor White
Write-Host "- Se o PDF não gerar, verifique se todos os campos do laudo estão sendo preenchidos corretamente" -ForegroundColor White
Write-Host "- O arquivo RDLC pode precisar de ajustes no layout visual (isso é feito manualmente no XML)" -ForegroundColor White

Write-Host ""
Write-Host "🎯 TESTE A GERAÇÃO DE PDF DO LAUDO!" -ForegroundColor Green