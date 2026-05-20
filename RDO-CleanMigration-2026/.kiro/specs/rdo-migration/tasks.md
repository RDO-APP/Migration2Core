# RDO Clean Migration - Task List
## Implementation Tasks with Lessons Learned Applied

**Created:** January 22, 2026  
**Status:** 📋 Ready for Execution  
**Total Tasks:** 50+

---

## Phase 1: Foundation & Database Setup (Week 1)

### 1.1 Project Structure Setup
- [ ] 1.1.1 Create .NET 8 MVC project
- [ ] 1.1.2 Install required NuGet packages
  - [ ] Pomelo.EntityFrameworkCore.MySql
  - [ ] Microsoft.AspNetCore.Identity.EntityFrameworkCore
  - [ ] Microsoft.EntityFrameworkCore.Tools
- [ ] 1.1.3 Create folder structure (Controllers, Models, Data, Services, etc.)
- [ ] 1.1.4 Configure appsettings.json
- [ ] 1.1.5 Set up User Secrets for connection string
- [ ] 1.1.6 Verify project compiles without errors

### 1.2 DbContext Configuration
- [ ] 1.2.1 Create RdoDbContext class
- [ ] 1.2.2 Configure connection string in Program.cs
- [ ] 1.2.3 Test database connection
- [ ] 1.2.4 Configure connection pooling
- [ ] 1.2.5 Set appropriate timeout values

### 1.3 Foundation Entities (15 entities)
- [ ] 1.3.1 Create entity classes for geographic data
  - [ ] UF (State)
  - [ ] MUNICIPIO (City)
- [ ] 1.3.2 Create entity classes for reference/lookup tables
  - [ ] CARGO (Job Position)
  - [ ] SETOR (Department)
  - [ ] RAMO (Business Sector)
  - [ ] STATUS_TAREFA (Task Status)
  - [ ] STATUS_RDO (Report Status)
  - [ ] EFETIVO_STATUS (Workforce Status)
  - [ ] TIPO_EQUIPAMENTO (Equipment Type)
  - [ ] UNIDADE_DE_MEDIDA (Unit of Measurement)
- [ ] 1.3.3 Create entity classes for company
  - [ ] LICENCA (License)
  - [ ] EMPRESA (Company)
- [ ] 1.3.4 Create entity classes for personnel
  - [ ] COLABORADOR (Worker)
- [ ] 1.3.5 Create entity classes for equipment
  - [ ] EQUIPAMENTO (Equipment)

### 1.4 Fluent API Configurations
- [ ] 1.4.1 Create configuration classes for all Phase 1 entities
- [ ] 1.4.2 Configure table names (preserve legacy names)
- [ ] 1.4.3 Configure column names (preserve legacy names)
- [ ] 1.4.4 Configure primary keys
- [ ] 1.4.5 Configure foreign key relationships
- [ ] 1.4.6 Configure indexes
- [ ] 1.4.7 Apply configurations in DbContext

### 1.5 Initial Migration
- [ ] 1.5.1 Create initial migration
- [ ] 1.5.2 Review migration code
- [ ] 1.5.3 Verify migration matches existing schema
- [ ] 1.5.4 Document migration (don't apply - database exists)

### 1.6 Testing Phase 1
- [ ] 1.6.1 Test database connection
- [ ] 1.6.2 Test querying all Phase 1 entities
- [ ] 1.6.3 Test relationships work correctly
- [ ] 1.6.4 Verify no compilation errors
- [ ] 1.6.5 User confirms Phase 1 complete ✅

---

## Phase 2: Work Management Core (Week 1-2)

### 2.1 OBRA Entity (Project)
- [ ] 2.1.1 Create Obra entity class with all properties
- [ ] 2.1.2 Create ObraConfiguration class
- [ ] 2.1.3 Configure 3 foreign keys to EMPRESA
  - [ ] EmpresaDono relationship
  - [ ] EmpresaContratante relationship
  - [ ] EmpresaContratada relationship
- [ ] 2.1.4 Configure foreign key to MUNICIPIO
- [ ] 2.1.5 Configure foreign key to COLABORADOR
- [ ] 2.1.6 Configure navigation properties
- [ ] 2.1.7 Test OBRA queries with all relationships

### 2.2 ETAPA Entity (Stage)
- [ ] 2.2.1 Create Etapa entity class
- [ ] 2.2.2 Create EtapaConfiguration class
- [ ] 2.2.3 Configure foreign key to OBRA
- [ ] 2.2.4 Configure navigation properties
- [ ] 2.2.5 Test ETAPA queries

### 2.3 TAREFA Entity (Task)
- [ ] 2.3.1 Create Tarefa entity class with all properties
- [ ] 2.3.2 Add water quality fields (8 fields)
  - [ ] tar_nr_nivel_cloro
  - [ ] tar_nr_ph
  - [ ] tar_nr_alcalinidade
  - [ ] tar_nr_limpidez
  - [ ] tar_nr_superficie
  - [ ] tar_nr_fundo
  - [ ] tar_nr_nivel_detritos
  - [ ] tar_nr_nivel_proliferacao
- [ ] 2.3.3 Create TarefaConfiguration class
- [ ] 2.3.4 Configure foreign key to ETAPA
- [ ] 2.3.5 Configure foreign key to STATUS_TAREFA
- [ ] 2.3.6 Configure foreign key to UNIDADE_DE_MEDIDA
- [ ] 2.3.7 Configure foreign key to COLABORADOR (creator)
- [ ] 2.3.8 Configure GUID grouping field
- [ ] 2.3.9 Test TAREFA queries

### 2.4 Additional Entities
- [ ] 2.4.1 Create TAREFA_CODIGO_PARALIZACAO entity
- [ ] 2.4.2 Create IMPRODUTIVIDADE entity
- [ ] 2.4.3 Create MARCA entity
- [ ] 2.4.4 Create MODELO entity
- [ ] 2.4.5 Configure all relationships

### 2.5 Assignment Entities
- [ ] 2.5.1 Create OBRA_COLABORADOR entity (with cargo, grupo)
- [ ] 2.5.2 Create OBRA_EQUIPAMENTO entity
- [ ] 2.5.3 Create OBRA_TAREFA_COLABORADOR entity
- [ ] 2.5.4 Create OBRA_TAREFA_EQUIPAMENTO entity
- [ ] 2.5.5 Configure all junction table relationships
- [ ] 2.5.6 Test assignment queries

### 2.6 Testing Phase 2
- [ ] 2.6.1 Test complete work hierarchy (OBRA→ETAPA→TAREFA)
- [ ] 2.6.2 Test multiple EMPRESA relationships
- [ ] 2.6.3 Test assignment queries
- [ ] 2.6.4 Test water quality fields
- [ ] 2.6.5 Verify no N+1 query issues
- [ ] 2.6.6 User confirms Phase 2 complete ✅

---

## Phase 3: Authentication & Security (Week 2)

### 3.1 ASP.NET Core Identity Setup
- [ ] 3.1.1 Install Identity packages
- [ ] 3.1.2 Create ApplicationUser class (extends IdentityUser)
- [ ] 3.1.3 Configure Identity in Program.cs
- [ ] 3.1.4 Configure cookie authentication
- [ ] 3.1.5 Set password requirements
- [ ] 3.1.6 Configure session timeout

### 3.2 Legacy User Migration
- [ ] 3.2.1 Create USUARIO entity
- [ ] 3.2.2 Map USUARIO to ApplicationUser
- [ ] 3.2.3 Create user migration service
- [ ] 3.2.4 Migrate existing users
- [ ] 3.2.5 Handle COLABORADOR passwords
- [ ] 3.2.6 Test user login with migrated accounts

### 3.3 RBAC Entities
- [ ] 3.3.1 Create GRUPO entity
- [ ] 3.3.2 Create MENU entity
- [ ] 3.3.3 Create MENU_PAGINA entity (self-referencing)
- [ ] 3.3.4 Create PAGINA entity
- [ ] 3.3.5 Create ACAO entity
- [ ] 3.3.6 Create PAGINA_ACAO entity
- [ ] 3.3.7 Create GRUPO_PAGINA_ACAO entity
- [ ] 3.3.8 Configure all RBAC relationships
- [ ] 3.3.9 Configure self-referencing in MENU_PAGINA

### 3.4 Permission Service
- [ ] 3.4.1 Create IPermissionService interface
- [ ] 3.4.2 Implement PermissionService
- [ ] 3.4.3 Implement 5-level permission check
- [ ] 3.4.4 Implement menu generation
- [ ] 3.4.5 Add caching for permissions
- [ ] 3.4.6 Create RdoAuthorizeAttribute
- [ ] 3.4.7 Test permission checking

### 3.5 Account Controller
- [ ] 3.5.1 Create AccountController
- [ ] 3.5.2 Implement Login action (GET)
- [ ] 3.5.3 Implement Login action (POST)
- [ ] 3.5.4 Implement Logout action
- [ ] 3.5.5 Implement AccessDenied action
- [ ] 3.5.6 Add server-side logging (ILogger)

### 3.6 Testing Phase 3
- [ ] 3.6.1 Test user login
- [ ] 3.6.2 Test user logout
- [ ] 3.6.3 Test "Remember Me" functionality
- [ ] 3.6.4 Test permission checking
- [ ] 3.6.5 Test menu generation
- [ ] 3.6.6 Test unauthorized access blocked
- [ ] 3.6.7 User confirms Phase 3 complete ✅

---

## Phase 4: Daily Reporting System (Week 2)

### 4.1 RDO Core Entities
- [ ] 4.1.1 Create RDO entity
- [ ] 4.1.2 Create RDO_TAREFA entity
- [ ] 4.1.3 Create RDO_IMAGEM entity
- [ ] 4.1.4 Create ASSINATURA_RDO entity
- [ ] 4.1.5 Create IMAGEM entity
- [ ] 4.1.6 Configure all RDO relationships

### 4.2 Task History Entities
- [ ] 4.2.1 Create HISTORICO_TAREFA_RDO entity
- [ ] 4.2.2 Create HISTORICO_TAREFA_COLABORADOR entity
- [ ] 4.2.3 Create HISTORICO_TAREFA_EQUIPAMENTO entity
- [ ] 4.2.4 Create HISTORICO_LOGIN entity (composite key)
- [ ] 4.2.5 Configure all history relationships

### 4.3 Additional Entities
- [ ] 4.3.1 Create EFETIVO entity
- [ ] 4.3.2 Create ACIDENTE entity
- [ ] 4.3.3 Create ACIDENTE_COLABORADOR entity
- [ ] 4.3.4 Create LAUDO entity
- [ ] 4.3.5 Create PERFIL_ASSINANTE entity
- [ ] 4.3.6 Create PARAMETRO entity
- [ ] 4.3.7 Configure all relationships

### 4.4 Testing Phase 4
- [ ] 4.4.1 Test RDO creation
- [ ] 4.4.2 Test task history tracking
- [ ] 4.4.3 Test signature workflow
- [ ] 4.4.4 Test image attachments
- [ ] 4.4.5 User confirms Phase 4 complete ✅

---

## Phase 5: UI Migration (Week 2-3)

### 5.1 Layout Setup (CRITICAL - NO INLINE SCRIPTS)
- [ ] 5.1.1 Download Bootstrap 5 locally (NOT CDN)
- [ ] 5.1.2 Create _Layout.cshtml (NO inline scripts)
- [ ] 5.1.3 Create _LoginLayout.cshtml (NO inline scripts)
- [ ] 5.1.4 Create site.css in wwwroot/css/
- [ ] 5.1.5 Verify NO `<script>` tags in layouts
- [ ] 5.1.6 Test layouts render correctly

### 5.2 Login Page (NO INLINE SCRIPTS)
- [ ] 5.2.1 Create Login.cshtml view
- [ ] 5.2.2 Use _LoginLayout
- [ ] 5.2.3 Create login form (email, password, remember me)
- [ ] 5.2.4 Add anti-forgery token
- [ ] 5.2.5 Create login.js in wwwroot/js/ (if needed)
- [ ] 5.2.6 Add server-side logging in controller (ILogger)
- [ ] 5.2.7 Verify NO inline scripts
- [ ] 5.2.8 Test in Chrome
- [ ] 5.2.9 Test in Edge
- [ ] 5.2.10 Test in Firefox
- [ ] 5.2.11 Test in incognito mode
- [ ] 5.2.12 Test after cache clear
- [ ] 5.2.13 User confirms login works ✅

### 5.3 Project Selection Page (NO INLINE SCRIPTS)

#### 5.3.A Escolher Header Implementation (COMPLETED)
- [x] 5.3.A.1 Analyze legacy Escolher header (ESCOLHER-HEADER-FINAL-DIAGNOSTIC.md)
- [x] 5.3.A.2 Create _HeaderEscolher.cshtml (simplified header)
- [x] 5.3.A.3 Create _LayoutEscolher.cshtml (blue layout)
- [x] 5.3.A.4 Create escolher.css (fonts, icons, styling)
- [x] 5.3.A.5 Update Escolher.cshtml to use new layout
- [x] 5.3.A.6 Verify NO inline scripts
- [ ] 5.3.A.7 **MANUAL**: Copy font files to wwwroot/fonts/ (see ESCOLHER-HEADER-IMPLEMENTATION-COMPLETE.md)
- [ ] 5.3.A.8 **MANUAL**: Copy user.png to wwwroot/images/
- [ ] 5.3.A.9 Test header displays correctly
- [ ] 5.3.A.10 User confirms header works ✅

#### 5.3.B Escolher Page Functionality
- [x] 5.3.B.1 Create ObraController
- [x] 5.3.B.2 Create Escolher action (GET)
- [x] 5.3.B.3 Create Escolher.cshtml view
- [x] 5.3.B.4 Query user's projects
- [x] 5.3.B.5 Display projects as cards (Bootstrap 5)
- [ ] 5.3.B.6 Create obra-selection.js in wwwroot/js/ (if needed)
- [x] 5.3.B.7 Add server-side logging (ILogger)
- [x] 5.3.B.8 Verify NO inline scripts
- [x] 5.3.B.9 Verify NO console.log in view
- [x] 5.3.B.10 Verify NO Razor/JavaScript mixing
- [ ] 5.3.B.11 Implement project selection logic
- [ ] 5.3.B.12 Store selection in session
- [ ] 5.3.B.13 Implement redirect to dashboard

#### 5.3.C Testing
- [ ] 5.3.C.1 Test in Chrome
- [ ] 5.3.C.2 Test in Edge
- [ ] 5.3.C.3 Test in Firefox
- [ ] 5.3.C.4 Test in incognito mode
- [ ] 5.3.C.5 Test after cache clear
- [ ] 5.3.C.6 User confirms page works ✅

**Reference Documents:**
- `ESCOLHER-HEADER-FINAL-DIAGNOSTIC.md` - Legacy header analysis
- `ESCOLHER-HEADER-IMPLEMENTATION-COMPLETE.md` - Implementation guide
- `MOBILE-LOGIN-BRIEFING-CARLOS.md` - Mobile specs for React Native

### 5.4 Project Dashboard
- [ ] 5.4.1 Create Dashboard action
- [ ] 5.4.2 Create Dashboard.cshtml view
- [ ] 5.4.3 Display project stages
- [ ] 5.4.4 Display tasks within stages
- [ ] 5.4.5 Show status colors
- [ ] 5.4.6 Show progress indicators
- [ ] 5.4.7 Create dashboard.js in wwwroot/js/
- [ ] 5.4.8 Verify NO inline scripts
- [ ] 5.4.9 Test in multiple browsers
- [ ] 5.4.10 User confirms dashboard works ✅

### 5.5 Task Management Pages
- [ ] 5.5.1 Create task list view
- [ ] 5.5.2 Create task create view
- [ ] 5.5.3 Create task edit view
- [ ] 5.5.4 Create task detail view
- [ ] 5.5.5 Add water quality fields to forms
- [ ] 5.5.6 Create task.js in wwwroot/js/
- [ ] 5.5.7 Verify NO inline scripts
- [ ] 5.5.8 Test all task operations
- [ ] 5.5.9 User confirms task management works ✅

### 5.6 Daily Report Pages
- [ ] 5.6.1 Create RDO list view
- [ ] 5.6.2 Create RDO create view
- [ ] 5.6.3 Create RDO detail view
- [ ] 5.6.4 Add task selection interface
- [ ] 5.6.5 Add image upload interface
- [ ] 5.6.6 Add signature collection interface
- [ ] 5.6.7 Create rdo.js in wwwroot/js/
- [ ] 5.6.8 Verify NO inline scripts
- [ ] 5.6.9 Test RDO workflow
- [ ] 5.6.10 User confirms RDO works ✅

### 5.7 Quality Inspection Pages
- [ ] 5.7.1 Create Laudo list view
- [ ] 5.7.2 Create Laudo create view
- [ ] 5.7.3 Create Laudo detail view
- [ ] 5.7.4 Add water quality measurement fields
- [ ] 5.7.5 Create laudo.js in wwwroot/js/
- [ ] 5.7.6 Verify NO inline scripts
- [ ] 5.7.7 Test Laudo workflow
- [ ] 5.7.8 User confirms Laudo works ✅

---

## Phase 6: Services & Business Logic (Week 3)

### 6.1 Repository Pattern
- [ ] 6.1.1 Create IRepository<T> interface
- [ ] 6.1.2 Implement Repository<T> class
- [ ] 6.1.3 Register repositories in DI container

### 6.2 Service Layer
- [ ] 6.2.1 Create IObraService and implementation
- [ ] 6.2.2 Create IEtapaService and implementation
- [ ] 6.2.3 Create ITarefaService and implementation
- [ ] 6.2.4 Create IRdoService and implementation
- [ ] 6.2.5 Create ILaudoService and implementation
- [ ] 6.2.6 Register services in DI container

### 6.3 DTOs
- [ ] 6.3.1 Create ObraDto and related DTOs
- [ ] 6.3.2 Create TarefaDto and related DTOs
- [ ] 6.3.3 Create RdoDto and related DTOs
- [ ] 6.3.4 Create LaudoDto and related DTOs
- [ ] 6.3.5 Add validation attributes

---

## Phase 7: Testing & Quality Assurance (Week 3-4)

### 7.1 Unit Testing
- [ ] 7.1.1 Set up xUnit test project
- [ ] 7.1.2 Write unit tests for services
- [ ] 7.1.3 Write unit tests for repositories
- [ ] 7.1.4 Write unit tests for business logic
- [ ] 7.1.5 Achieve >80% code coverage
- [ ] 7.1.6 All unit tests pass

### 7.2 Integration Testing
- [ ] 7.2.1 Set up integration test project
- [ ] 7.2.2 Configure test database
- [ ] 7.2.3 Write integration tests for database operations
- [ ] 7.2.4 Write integration tests for authentication
- [ ] 7.2.5 Write integration tests for API endpoints
- [ ] 7.2.6 All integration tests pass

### 7.3 Browser Testing (CRITICAL)
- [ ] 7.3.1 Test all pages in Chrome
- [ ] 7.3.2 Test all pages in Edge
- [ ] 7.3.3 Test all pages in Firefox
- [ ] 7.3.4 Test all pages in incognito mode
- [ ] 7.3.5 Test all pages after cache clear
- [ ] 7.3.6 Verify NO console errors
- [ ] 7.3.7 Verify NO inline scripts
- [ ] 7.3.8 User confirms all pages work ✅

### 7.4 Performance Testing
- [ ] 7.4.1 Profile database queries
- [ ] 7.4.2 Optimize slow queries
- [ ] 7.4.3 Test with large datasets
- [ ] 7.4.4 Verify acceptable load times
- [ ] 7.4.5 User confirms performance acceptable ✅

---

## Phase 8: Deployment (Week 4)

### 8.1 Production Configuration
- [ ] 8.1.1 Create production appsettings.json
- [ ] 8.1.2 Configure production connection string
- [ ] 8.1.3 Configure SSL/TLS
- [ ] 8.1.4 Configure logging
- [ ] 8.1.5 Configure error handling

### 8.2 Database Migration
- [ ] 8.2.1 Create database migration scripts
- [ ] 8.2.2 Test migration scripts
- [ ] 8.2.3 Create rollback scripts
- [ ] 8.2.4 Backup production database
- [ ] 8.2.5 Execute migration (if needed)

### 8.3 Security Hardening
- [ ] 8.3.1 Enable HTTPS only
- [ ] 8.3.2 Configure HSTS
- [ ] 8.3.3 Add security headers
- [ ] 8.3.4 Configure CORS (if needed)
- [ ] 8.3.5 Review and fix security vulnerabilities

### 8.4 Deployment
- [ ] 8.4.1 Publish application
- [ ] 8.4.2 Deploy to production server
- [ ] 8.4.3 Configure IIS/Kestrel
- [ ] 8.4.4 Test production deployment
- [ ] 8.4.5 Monitor for errors
- [ ] 8.4.6 User confirms production works ✅

### 8.5 Documentation
- [ ] 8.5.1 Create deployment guide
- [ ] 8.5.2 Create user manual
- [ ] 8.5.3 Create admin guide
- [ ] 8.5.4 Document API endpoints
- [ ] 8.5.5 Create troubleshooting guide

---

## Critical Checkpoints (Must Verify)

### Before Claiming Any Task Complete:
- [ ] Code compiles without errors
- [ ] No inline scripts in Razor views
- [ ] Server-side logging uses ILogger
- [ ] All JavaScript in separate files
- [ ] Tested in multiple browsers
- [ ] Tested in incognito mode
- [ ] User confirms it works ✅

### Before Moving to Next Phase:
- [ ] All phase tasks complete
- [ ] All tests pass
- [ ] User acceptance testing complete
- [ ] User confirms phase complete ✅
- [ ] Documentation updated

---

## Risk Mitigation Tasks

### If Compilation Errors Occur:
- [ ] Stop all running processes
- [ ] Clean bin/obj folders
- [ ] Rebuild solution
- [ ] Check for process locks
- [ ] Restart Visual Studio if needed

### If Blank Page Occurs:
- [ ] Check for inline scripts in view
- [ ] Check browser console for errors
- [ ] Check server logs for errors
- [ ] Verify all assets loading
- [ ] Test in incognito mode
- [ ] Clear browser cache

### If Authentication Fails:
- [ ] Check connection string
- [ ] Check user exists in database
- [ ] Check password hash
- [ ] Check cookie configuration
- [ ] Check session timeout
- [ ] Test in incognito mode

---

## Success Metrics

### Code Quality Metrics:
- [ ] Zero inline scripts in Razor views
- [ ] All JavaScript in separate files
- [ ] All CSS in separate files
- [ ] Code coverage >80%
- [ ] No code smells

### Functionality Metrics:
- [ ] 100% feature parity with legacy
- [ ] All workflows complete
- [ ] Zero data loss
- [ ] Performance acceptable

### Testing Metrics:
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] All browsers work
- [ ] Incognito mode works
- [ ] User confirms success ✅

---

**Total Tasks:** 200+  
**Estimated Duration:** 4 weeks  
**Status:** ✅ Ready for Execution  
**Next Step:** Begin Phase 1 - Foundation & Database Setup

---

**REMEMBER:**
1. ✅ Copy working code exactly
2. ✅ NO inline scripts in Razor views
3. ✅ Test thoroughly at each step
4. ✅ Get user confirmation before claiming complete
5. ✅ Stop processes before compiling
6. ✅ Focus on one task at a time
7. ✅ Be humble and ask questions
