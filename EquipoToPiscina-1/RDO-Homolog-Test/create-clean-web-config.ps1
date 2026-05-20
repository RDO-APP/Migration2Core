# CRIAR WEB.CONFIG COMPLETAMENTE LIMPO

Write-Host "=== CRIANDO WEB.CONFIG LIMPO ===" -ForegroundColor Green
Write-Host ""

# Fazer backup do atual
$webConfigPath = "rdoappProject\Web.config"
$backupPath = "rdoappProject\Web.config.backup"

if (Test-Path $webConfigPath) {
    Copy-Item $webConfigPath $backupPath
    Write-Host "Backup criado: Web.config.backup" -ForegroundColor Yellow
}

# Criar Web.config completamente limpo
$cleanWebConfig = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <configSections>
    <section name="entityFramework" type="System.Data.Entity.Internal.ConfigFile.EntityFrameworkSection, EntityFramework, Version=5.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089" requirePermission="false" />
  </configSections>
  
  <appSettings>
    <add key="basePath" value="/" />
    <add key="WSAssinatura" value="http://loja.rdoapp.com.br/site/webservice/v1/assinatura/subscription/{0}" />
    <add key="DisableAssinatura" value="true" />
    <add key="webpages:Version" value="3.0.0.0" />
    <add key="webpages:Enabled" value="false" />
    <add key="ClientValidationEnabled" value="true" />
    <add key="UnobtrusiveJavaScriptEnabled" value="true" />
    <add key="EmailRemetente" value="convite@rdoapp.com.br" />
    <add key="SenhaRemetente" value="Rdo@301087" />
    <add key="NomeRemetente" value="Rdo App" />
    <add key="PastaDeImagens" value="~/Uploads/Imagens/" />
  </appSettings>
  
  <system.web>
    <compilation debug="true" targetFramework="4.8" />
    <httpRuntime targetFramework="4.5.2" maxRequestLength="2147483647" requestLengthDiskThreshold="2147483647" executionTimeout="240" />
    <globalization culture="pt-BR" uiCulture="pt-BR" />
  </system.web>
  
  <runtime>
    <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
      <dependentAssembly>
        <assemblyIdentity name="Newtonsoft.Json" publicKeyToken="30ad4fe6b2a6aeed" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-13.0.0.0" newVersion="13.0.0.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="MySql.Data" publicKeyToken="c5687fc88969c44d" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-9.1.0.0" newVersion="9.1.0.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="System.Web.Helpers" publicKeyToken="31bf3856ad364e35" />
        <bindingRedirect oldVersion="1.0.0.0-3.0.0.0" newVersion="3.0.0.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="System.Web.WebPages" publicKeyToken="31bf3856ad364e35" />
        <bindingRedirect oldVersion="0.0.0.0-3.0.0.0" newVersion="3.0.0.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="System.Web.Mvc" publicKeyToken="31bf3856ad364e35" />
        <bindingRedirect oldVersion="0.0.0.0-5.3.0.0" newVersion="5.3.0.0" />
      </dependentAssembly>
      <dependentAssembly>
        <assemblyIdentity name="EntityFramework" publicKeyToken="b77a5c561934e089" culture="neutral" />
        <bindingRedirect oldVersion="0.0.0.0-6.0.0.0" newVersion="6.0.0.0" />
      </dependentAssembly>
    </assemblyBinding>
  </runtime>
  
  <system.webServer>
    <handlers>
      <remove name="ExtensionlessUrlHandler-Integrated-4.0" />
      <remove name="OPTIONSVerbHandler" />
      <remove name="TRACEVerbHandler" />
      <add name="ExtensionlessUrlHandler-Integrated-4.0" path="*." verb="*" type="System.Web.Handlers.TransferRequestHandler" preCondition="integratedMode,runtimeVersionv4.0" />
    </handlers>
    <modules runAllManagedModulesForAllRequests="true" />
    <validation validateIntegratedModeConfiguration="false" />
  </system.webServer>
  
  <connectionStrings>
    <add name="rdoappEntities" connectionString="metadata=res://*/rdoappModel.csdl|res://*/rdoappModel.ssdl|res://*/rdoappModel.msl;provider=MySql.Data.MySqlClient;provider connection string=&quot;server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;User Id=rdoadmin;password=rdoapp2018aws;database=piscinas_rdoapp_homologa&quot;" providerName="System.Data.EntityClient" />
  </connectionStrings>
  
  <entityFramework>
    <defaultConnectionFactory type="System.Data.Entity.Infrastructure.LocalDbConnectionFactory, EntityFramework">
      <parameters>
        <parameter value="v13.0" />
      </parameters>
    </defaultConnectionFactory>
    <providers>
      <provider invariantName="MySql.Data.MySqlClient" type="MySql.Data.MySqlClient.MySqlProviderServices, MySql.Data.EntityFramework, Version=9.1.0.0, Culture=neutral, PublicKeyToken=c5687fc88969c44d" />
    </providers>
  </entityFramework>
</configuration>
'@

# Salvar Web.config limpo
Set-Content -Path $webConfigPath -Value $cleanWebConfig -Encoding UTF8

Write-Host "Web.config limpo criado!" -ForegroundColor Green
Write-Host ""
Write-Host "VERIFICACAO:" -ForegroundColor Yellow

# Verificar se esta limpo
$content = Get-Content $webConfigPath -Raw
$hasSystemCodedom = $content -match "system\.codedom"
$hasMicrosoftCodedom = $content -match "Microsoft\.CodeDom\.Providers"

if (-not $hasSystemCodedom -and -not $hasMicrosoftCodedom) {
    Write-Host "SUCESSO: Web.config completamente limpo!" -ForegroundColor Green
} else {
    Write-Host "ERRO: Ainda ha referencias problematicas" -ForegroundColor Red
}

Write-Host ""
Write-Host "TESTE AGORA:" -ForegroundColor Cyan
Write-Host "1. Volte ao Visual Studio"
Write-Host "2. Pressione F5"
Write-Host "3. Deve funcionar sem erros!"