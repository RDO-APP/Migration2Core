# PLANO COMPLETO: MIGRAÇÃO .NET 8 EM 8-10 SEMANAS

## CRONOGRAMA DETALHADO SEM SCRIPTS 📋

---

## **SEMANA 1: PREPARAÇÃO E ANÁLISE** (40 horas)

### **DIA 1-2: SETUP DO AMBIENTE** (16h)
```
MANHÃ (4h):
1. Baixar e instalar .NET 8 SDK
   - https://dotnet.microsoft.com/download/dotnet/8.0
   - Verificar: dotnet --version (deve mostrar 8.x)

2. Atualizar Visual Studio 2022
   - Instalar workload "ASP.NET and web development"
   - Instalar workload ".NET desktop development"

TARDE (4h):
3. Criar novo projeto ASP.NET Core 8
   - File > New > Project
   - ASP.NET Core Web App (Model-View-Controller)
   - Target Framework: .NET 8.0
   - Nome: RdoApp.Core

4. Configurar Git
   - git checkout -b dotnet8-migration
   - Criar .gitignore para .NET Core
   - Commit inicial
```

### **DIA 3-4: ANÁLISE DO CÓDIGO ATUAL** (16h)
```
ANÁLISE MANUAL (sem scripts):

1. INVENTÁRIO DE ARQUIVOS:
   - Contar Controllers: rdoappProject/Api/Controllers/*.cs
   - Contar Models: rdoappProject/Api/Models/*.cs  
   - Contar Views: rdoappProject/Client/Views/*/*.html
   - Contar Entidades: rdoappClass/*.cs

2. DEPENDÊNCIAS CRÍTICAS:
   - Entity Framework 6.5.1 → EF Core 8
   - Microsoft.ReportViewer → FastReport.NET
   - System.Web.Mvc → Microsoft.AspNetCore.Mvc
   - Web.config → appsettings.json

3. RELATÓRIOS RDLC:
   - Listar todos os .rdlc em Api/Contents/Reports/
   - Identificar relatórios mais usados
   - Priorizar: Laudo, RDO, Controle de Horas

4. JAVASCRIPT/CSS:
   - TarefaController.js (principal)
   - Bundling atual (BundleConfig.cs)
   - CSS customizado
```

### **DIA 5: PLANEJAMENTO DETALHADO** (8h)
```
DOCUMENTAR:
1. Lista de prioridades de migração
2. Ordem de desenvolvimento (crítico → não-crítico)
3. Pontos de risco identificados
4. Estratégia de testes
5. Plano de rollback
```

---

## **SEMANA 2: ESTRUTURA BASE .NET 8** (40 horas)

### **DIA 1: PROJETO BASE** (8h)
```
MANHÃ (4h):
1. Criar estrutura de pastas:
   RdoApp.Core/
   ├── Controllers/
   ├── Models/
   ├── Views/
   ├── Services/
   ├── Data/
   └── wwwroot/

2. Configurar Program.cs:
   - Adicionar Entity Framework
   - Configurar DI container
   - Configurar middleware pipeline

TARDE (4h):
3. Criar appsettings.json:
   - Connection strings
   - Configurações de logging
   - Configurações customizadas

4. Instalar pacotes NuGet essenciais:
   - Microsoft.EntityFrameworkCore
   - Microsoft.EntityFrameworkCore.Tools
   - Pomelo.EntityFrameworkCore.MySql
```

### **DIA 2-3: ENTITY FRAMEWORK CORE** (16h)
```
DIA 2 - CONFIGURAÇÃO BÁSICA:
1. Criar DbContext (RdoContext.cs):
   - Herdar de DbContext
   - Configurar connection string
   - Método OnConfiguring

2. Migrar 5 entidades principais:
   - tarefa.cs → Tarefa.cs
   - obra.cs → Obra.cs  
   - colaborador.cs → Colaborador.cs
   - etapa.cs → Etapa.cs
   - status_tarefa.cs → StatusTarefa.cs

DIA 3 - RELACIONAMENTOS:
3. Configurar relacionamentos básicos:
   - Tarefa → Obra (via Etapa)
   - Tarefa → Colaborador
   - Obra → Etapas
   - Usar Fluent API no OnModelCreating

4. Testar conexão:
   - dotnet ef migrations add InitialCreate
   - dotnet ef database update
   - Verificar se tabelas são criadas
```

### **DIA 4-5: VALIDAÇÃO INICIAL** (16h)
```
DIA 4 - TESTES BÁSICOS:
1. Criar controller de teste:
   - TesteController.cs
   - Action para listar obras
   - Action para listar tarefas
   - Testar CRUD básico

2. Configurar logging:
   - Serilog ou ILogger nativo
   - Log de queries EF Core
   - Log de erros

DIA 5 - CORREÇÕES:
3. Ajustar mapeamentos:
   - Nomes de colunas
   - Tipos de dados
   - Chaves estrangeiras

4. Documentar problemas encontrados
```

---

## **SEMANA 3: CONTROLLERS E API** (40 horas)

### **DIA 1-2: CONTROLLERS PRINCIPAIS** (16h)
```
DIA 1 - TAREFA CONTROLLER:
1. Migrar TarefaController.cs:
   - Herdar de ControllerBase
   - Injetar DbContext via DI
   - Converter métodos para async/await
   - Ajustar return types (IActionResult)

2. Migrar métodos principais:
   - Lista() → GetTarefas()
   - Salvar() → PostTarefa()
   - Update() → PutTarefa()
   - ObterRegistro() → GetTarefa(id)

DIA 2 - OUTROS CONTROLLERS:
3. Migrar ColaboradorController
4. Migrar ObraController  
5. Migrar EtapaController
6. Ajustar rotas e parâmetros
```

### **DIA 3-4: AUTENTICAÇÃO** (16h)
```
DIA 3 - SISTEMA DE LOGIN:
1. Configurar Authentication:
   - AddAuthentication no Program.cs
   - Cookie authentication
   - Login/Logout actions

2. Migrar lógica de login atual:
   - Validação de CPF/senha
   - Criação de claims
   - Redirecionamento

DIA 4 - AUTORIZAÇÃO:
3. Configurar Authorization:
   - Policies básicas
   - Roles se necessário
   - [Authorize] attributes

4. Middleware de segurança:
   - HTTPS redirection
   - HSTS headers
   - Anti-forgery tokens
```

### **DIA 5: TESTES DE API** (8h)
```
VALIDAÇÃO COMPLETA:
1. Testar todos os endpoints:
   - GET /api/tarefa
   - POST /api/tarefa
   - PUT /api/tarefa/{id}
   - DELETE /api/tarefa/{id}

2. Testar autenticação:
   - Login válido/inválido
   - Acesso protegido
   - Logout

3. Performance básica:
   - Tempo de resposta
   - Queries geradas pelo EF
   - Memory usage
```

---

## **SEMANA 4: FRONTEND E VIEWS** (40 horas)

### **DIA 1-2: VIEWS PRINCIPAIS** (16h)
```
DIA 1 - LAYOUT E ESTRUTURA:
1. Migrar _Layout.cshtml:
   - Bootstrap 5
   - Menu de navegação
   - Scripts básicos
   - CSS customizado

2. Migrar views principais:
   - Login/Index.cshtml
   - Home/Index.cshtml (dashboard)
   - Tarefa/Index.cshtml

DIA 2 - FORMULÁRIOS:
3. Migrar formulários:
   - Tarefa/Create.cshtml
   - Tarefa/Edit.cshtml
   - Colaborador/Create.cshtml

4. Ajustar Razor syntax:
   - @model declarations
   - Html.BeginForm → using (Html.BeginForm)
   - @Html.ActionLink → asp-action
```

### **DIA 3-4: JAVASCRIPT E CSS** (16h)
```
DIA 3 - BUNDLING MODERNO:
1. Configurar bundling:
   - Usar LibMan ou npm
   - Bundle CSS/JS
   - Minificação

2. Migrar TarefaController.js:
   - Ajustar URLs das APIs
   - Corrigir chamadas AJAX
   - Atualizar selectors

DIA 4 - ESTILOS:
3. Migrar CSS customizado:
   - Responsive design
   - Temas/cores
   - Componentes específicos

4. Testar compatibilidade:
   - Chrome, Firefox, Edge
   - Mobile responsiveness
```

### **DIA 5: INTEGRAÇÃO FRONTEND-BACKEND** (8h)
```
TESTES COMPLETOS:
1. Fluxo de login completo
2. CRUD de tarefas via interface
3. Upload de arquivos
4. Validações client-side
5. Mensagens de erro/sucesso
```

---

## **SEMANA 5: ENTIDADES RESTANTES** (40 horas)

### **DIA 1-3: MIGRAÇÃO EM LOTE** (24h)
```
ESTRATÉGIA ORGANIZADA:

DIA 1 - ENTIDADES CORE (8 entidades):
- equipamento.cs → Equipamento.cs
- unidade_de_medida.cs → UnidadeMedida.cs
- cargo.cs → Cargo.cs
- grupo.cs → Grupo.cs
- empresa.cs → Empresa.cs
- licenca.cs → Licenca.cs
- status_rdo.cs → StatusRdo.cs
- tipo_obra.cs → TipoObra.cs

DIA 2 - ENTIDADES RELACIONAIS (15 entidades):
- obra_colaborador.cs → ObraColaborador.cs
- obra_equipamento.cs → ObraEquipamento.cs
- obra_tarefa_colaborador.cs → ObraTarefaColaborador.cs
- obra_tarefa_equipamento.cs → ObraTarefaEquipamento.cs
- rdo.cs → Rdo.cs
- rdo_tarefa.cs → RdoTarefa.cs
- historico_tarefa_rdo.cs → HistoricoTarefaRdo.cs
- assinatura_rdo.cs → AssinaturaRdo.cs
- imagem.cs → Imagem.cs
- acidente.cs → Acidente.cs
- acidente_colaborador.cs → AcidenteColaborador.cs
- tarefa_codigo_paralizacao.cs → TarefaCodigoParalizacao.cs
- laudo.cs → Laudo.cs (IMPORTANTE!)
- usuario.cs → Usuario.cs
- permissao.cs → Permissao.cs

DIA 3 - ENTIDADES AUXILIARES (25 entidades restantes):
- Todas as demais entidades do rdoappClass/
- Configurar relacionamentos complexos
- Ajustar foreign keys
```

### **DIA 4-5: VALIDAÇÃO COMPLETA** (16h)
```
DIA 4 - TESTES AUTOMATIZADOS:
1. Criar testes unitários:
   - xUnit + Moq
   - Testar cada entidade
   - Testar relacionamentos

2. Testes de integração:
   - CRUD completo
   - Queries complexas
   - Performance

DIA 5 - CORREÇÕES:
3. Ajustar mapeamentos problemáticos
4. Corrigir relacionamentos
5. Otimizar queries lentas
6. Documentar mudanças
```

---

## **SEMANA 6: SISTEMA DE RELATÓRIOS** (40 horas)

### **DIA 1-2: FASTREPOR.NET SETUP** (16h)
```
DIA 1 - INSTALAÇÃO:
1. Instalar FastReport.NET:
   - NuGet: FastReport.Core
   - NuGet: FastReport.Web
   - Licença (trial ou comprada)

2. Configurar no Program.cs:
   - AddFastReport()
   - Configurar templates path

DIA 2 - PRIMEIRO RELATÓRIO:
3. Converter Teste.rdlc → Teste.frx:
   - Usar FastReport Designer
   - Recriar layout manualmente
   - Configurar data source

4. Testar geração de PDF:
   - Controller action
   - Passar dados do laudo
   - Retornar PDF
```

### **DIA 3-4: RELATÓRIOS CRÍTICOS** (16h)
```
DIA 3 - LAUDO PDF:
1. Recriar relatório de laudo:
   - Layout idêntico ao atual
   - Campos de água (cloro, pH, etc.)
   - Assinaturas e logos

2. Integrar com LaudoController:
   - Action GerarLaudoPdf()
   - Buscar dados do banco
   - Gerar e retornar PDF

DIA 4 - RDO PDF:
3. Recriar relatório RDO:
   - Layout de RDO diário
   - Lista de tarefas
   - Colaboradores e equipamentos

4. Relatório de controle de horas:
   - Equipamentos por período
   - Horas normais/extras
   - Totalizadores
```

### **DIA 5: TESTES DE RELATÓRIOS** (8h)
```
VALIDAÇÃO COMPLETA:
1. Testar geração de todos os PDFs
2. Comparar com versão atual
3. Performance de geração
4. Qualidade do PDF
5. Correções de layout
```

---

## **SEMANA 7: FUNCIONALIDADES AVANÇADAS** (40 horas)

### **DIA 1-2: SISTEMA DE LAUDO MODERNO** (16h)
```
DIA 1 - INTERFACE:
1. Migrar interface moderna do laudo:
   - cards.html → Laudo/Create.cshtml
   - Dropdowns para cloro, pH, alcalinidade
   - Grid de inspeção com radio buttons
   - Tooltips explicativos

2. JavaScript do laudo:
   - Migrar lógica de salvamento
   - Validações client-side
   - AJAX calls

DIA 2 - BACKEND:
3. LaudoController completo:
   - CRUD operations
   - Integração com tarefa
   - Validações server-side

4. Integração com histórico:
   - Mostrar dados do laudo no histórico
   - Colunas: CLORO, PH, ALCALIN., etc.
   - Substituir traços por valores reais
```

### **DIA 3-4: UPLOAD E STORAGE** (16h)
```
DIA 3 - SISTEMA DE ARQUIVOS:
1. Upload de imagens:
   - IFormFile handling
   - Validação de tipos
   - Redimensionamento
   - Storage em wwwroot/uploads/

2. Anexos de documentos:
   - PDF, Word, Excel
   - Validação de tamanho
   - Antivírus scan (opcional)

DIA 4 - OTIMIZAÇÕES:
3. Compressão de imagens:
   - ImageSharp library
   - Thumbnails automáticos
   - Lazy loading

4. CDN setup (opcional):
   - Azure Blob Storage
   - Amazon S3
   - CloudFlare
```

### **DIA 5: INTEGRAÇÕES** (8h)
```
FUNCIONALIDADES EXTRAS:
1. Email notifications:
   - SMTP configuration
   - Templates de email
   - Notificações automáticas

2. Backup automático:
   - Scheduled jobs
   - Database backup
   - File backup

3. Logging estruturado:
   - Serilog configuration
   - Structured logging
   - Error tracking
```

---

## **SEMANA 8: TESTES E OTIMIZAÇÃO** (40 horas)

### **DIA 1-2: TESTES INTENSIVOS** (16h)
```
DIA 1 - TESTES FUNCIONAIS:
1. Testes manuais completos:
   - Todos os fluxos de usuário
   - Cenários de erro
   - Edge cases
   - Compatibilidade de browsers

2. Testes automatizados:
   - Unit tests (80%+ coverage)
   - Integration tests
   - E2E tests com Playwright

DIA 2 - TESTES DE CARGA:
3. Performance testing:
   - NBomber ou k6
   - 100+ usuários simultâneos
   - Stress testing
   - Memory leaks

4. Testes de segurança:
   - SQL injection
   - XSS attacks
   - CSRF protection
   - Authentication bypass
```

### **DIA 3-4: OTIMIZAÇÃO** (16h)
```
DIA 3 - PERFORMANCE:
1. Database optimization:
   - Query analysis
   - Missing indexes
   - N+1 problems
   - Connection pooling

2. Application optimization:
   - Caching strategies
   - Response compression
   - Static file optimization
   - CDN integration

DIA 4 - MONITORING:
3. Application monitoring:
   - Health checks
   - Metrics collection
   - Error tracking
   - Performance counters

4. Logging optimization:
   - Log levels
   - Structured logging
   - Log aggregation
```

### **DIA 5: DOCUMENTAÇÃO** (8h)
```
DOCUMENTAÇÃO COMPLETA:
1. API documentation:
   - Swagger/OpenAPI
   - Endpoint descriptions
   - Request/response examples

2. Deployment guide:
   - Server requirements
   - Installation steps
   - Configuration guide
   - Troubleshooting

3. User manual:
   - Feature changes
   - New functionalities
   - Migration notes
```

---

## **SEMANA 9: DEPLOY E PRODUÇÃO** (40 horas)

### **DIA 1-2: AMBIENTE DE PRODUÇÃO** (16h)
```
DIA 1 - SERVIDOR:
1. Preparar servidor:
   - Windows Server 2019/2022
   - IIS 10+ com ASP.NET Core Module
   - .NET 8 Runtime
   - MySQL 8.0+

2. Configurações de segurança:
   - SSL certificates
   - Firewall rules
   - User permissions
   - Backup strategy

DIA 2 - APLICAÇÃO:
3. Deploy configuration:
   - appsettings.Production.json
   - Connection strings
   - Logging configuration
   - Performance settings

4. IIS configuration:
   - Application pool
   - Web.config for IIS
   - URL rewriting
   - Compression
```

### **DIA 3-4: MIGRAÇÃO DE DADOS** (16h)
```
DIA 3 - BACKUP E PREPARAÇÃO:
1. Backup completo da produção:
   - Database backup
   - Files backup
   - Configuration backup
   - Rollback plan

2. Teste de migração:
   - Ambiente de staging
   - Migração completa
   - Validação de dados
   - Performance testing

DIA 4 - MIGRAÇÃO REAL:
3. Janela de manutenção:
   - Comunicação aos usuários
   - Backup final
   - Deploy da aplicação
   - Migração de dados

4. Validação pós-deploy:
   - Smoke tests
   - Critical path testing
   - Performance monitoring
   - Error monitoring
```

### **DIA 5: GO-LIVE** (8h)
```
LANÇAMENTO:
1. Liberação para usuários:
   - Comunicação oficial
   - Suporte ativo
   - Monitoring intensivo

2. Hotfixes se necessário:
   - Correções críticas
   - Deploy rápido
   - Rollback se necessário
```

---

## **SEMANA 10: ESTABILIZAÇÃO** (40 horas)

### **DIA 1-3: CORREÇÕES E AJUSTES** (24h)
```
SUPORTE INTENSIVO:
1. Bug fixes críticos:
   - Problemas reportados pelos usuários
   - Correções de performance
   - Ajustes de UI/UX

2. Otimizações baseadas no uso real:
   - Queries lentas identificadas
   - Bottlenecks de performance
   - Melhorias de usabilidade

3. Monitoramento contínuo:
   - Error rates
   - Response times
   - User satisfaction
   - System stability
```

### **DIA 4-5: FINALIZAÇÃO** (16h)
```
CONCLUSÃO DO PROJETO:
1. Documentação final:
   - Lessons learned
   - Performance metrics
   - User feedback
   - Future improvements

2. Treinamento da equipe:
   - .NET 8 features
   - New architecture
   - Deployment process
   - Troubleshooting guide

3. Handover:
   - Knowledge transfer
   - Support procedures
   - Maintenance schedule
   - Future roadmap
```

---

## **RESUMO EXECUTIVO** 📊

### **CRONOGRAMA CONSOLIDADO:**
- **Semanas 1-2**: Preparação + Base (.NET 8 + EF Core)
- **Semanas 3-4**: Backend + Frontend (50% funcional)
- **Semanas 5-6**: Entidades + Relatórios (90% funcional)
- **Semanas 7-8**: Features + Testes (100% funcional)
- **Semanas 9-10**: Deploy + Estabilização (Produção)

### **MARCOS PRINCIPAIS:**
- **Semana 2**: Sistema básico funcionando
- **Semana 4**: Interface completa
- **Semana 6**: Relatórios funcionando
- **Semana 8**: Sistema completo e testado
- **Semana 10**: Produção estável

### **RECURSOS NECESSÁRIOS:**
- **1-2 Desenvolvedores** (tempo integral)
- **1 DBA** (meio período)
- **1 Tester** (semanas 7-10)
- **Servidor de produção** preparado
- **Licenças** (FastReport.NET, etc.)

### **RISCOS MITIGADOS:**
- **Relatórios**: FastReport.NET como substituto direto
- **Performance**: Testes contínuos desde semana 3
- **Dados**: Backup e rollback strategy
- **Usuários**: Treinamento e suporte intensivo

**RESULTADO: Sistema moderno, performático e estável em 10 semanas!**