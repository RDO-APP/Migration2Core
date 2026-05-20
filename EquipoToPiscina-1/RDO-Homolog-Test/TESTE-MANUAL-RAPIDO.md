# TESTE MANUAL RÁPIDO

## ✅ SITUAÇÃO ATUAL
- A aplicação já tem uma pasta `bin` compilada
- Está pronta para testar

## 🚀 COMO TESTAR AGORA (3 opções):

### OPÇÃO 1: Visual Studio (MAIS FÁCIL)
1. Abra o Visual Studio
2. Abra o arquivo `rdoappProject.csproj` 
3. Pressione **F5** para executar
4. A aplicação abrirá no navegador automaticamente

### OPÇÃO 2: IIS Express Manual
1. Abra o Prompt de Comando como Administrador
2. Navegue até: `C:\Users\LUCIO\OneDrive\Documentos\RDO App\TI\Projetos\.Net Piscina\Kiro\EquipoToPiscina-1\RDO-Homolog-Test\rdoappProject`
3. Execute: `"C:\Program Files\IIS Express\iisexpress.exe" /path:"%CD%" /port:8080`
4. Acesse: http://localhost:8080

### OPÇÃO 3: Publicar no IIS Local
1. Copie a pasta `bin` para `C:\inetpub\wwwroot\rdoapp`
2. Copie todos os arquivos .aspx, .html, .js, .css
3. Configure um site no IIS Manager

## 🎯 TESTE PRINCIPAL
- Acesse a página de **Tarefas**
- Teste criar um **Laudo**
- Verifique se salva corretamente

## ⚡ MAIS RÁPIDO: Use a OPÇÃO 1 (Visual Studio F5)