# Legacy Code Structure Analysis
## RDO Production (Gilberto) - Complete Inventory

**Analysis Date:** January 22, 2026  
**Source Location:** `C:\Dev\EquipoToPiscina-1\RDO-Production-Gilberto\`  
**Status:** ✅ Initial Analysis Complete

---

## Project Structure Overview

```
RDO-Production-Gilberto/
├── rdoappClass/          # Entity Framework 6 Data Layer (48 entities)
├── rdoappProject/        # ASP.NET Framework Web API + AngularJS Frontend
├── solution/             # Visual Studio solution with tests
└── KEY_COLUMN_USAGE_*.csv # Database schema reference
```

---

## 1. Data Layer Analysis (rdoappClass/)

### Entity Framework 6 Project
**Technology:** Entity Framework 6 with EDMX (Database First)  
**Database:** MySQL  
**Total Entities:** 48 entities identified

### Core Entities Identified

#### Work Management (Obra/Etapa/Tarefa)
1. **obra.cs** - Construction projects
2. **etapa.cs** - Project phases/stages
3. **tarefa.cs** - Tasks within stages
4. **status_tarefa.cs** - Task status enumeration

#### Personnel Management (Colaborador)
5. **colaborador.cs** - Workers/employees
6. **cargo.cs** - Job positions
7. **setor.cs** - Departments/sectors
8. **obra_colaborador.cs** - Worker-project assignments
9. **obra_tarefa_colaborador.cs** - Worker-task assignments
10. **historico_tarefa_colaborador.cs** - Worker task history

#### Equipment Management (Equipamento)
11. **equipamento.cs** - Equipment/machinery
12. **tipo_equipamento.cs** - Equipment types
13. **marca.cs** - Equipment brands
14. **modelo.cs** - Equipment models
15. **obra_equipamento.cs** - Equipment-project assignments
16. **obra_tarefa_equipamento.cs** - Equipment-task assignments
17. **historico_tarefa_equipamento.cs** - Equipment task history

#### Daily Reports (RDO)
18. **rdo.cs** - Daily work reports
19. **rdo_tarefa.cs** - Tasks in daily reports
20. **rdo_imagem.cs** - Images attached to reports
21. **status_rdo.cs** - Report status enumeration
22. **assinatura_rdo.cs** - Report signatures

#### Quality Control (Laudo)
23. **laudo.cs** - Water quality inspection reports

#### Workforce Tracking (Efetivo)
24. **efetivo.cs** - Workforce headcount
25. **efetivo_status.cs** - Workforce status

#### Incidents & Downtime
26. **acidente.cs** - Accidents/incidents
27. **acidente_colaborador.cs** - Workers involved in accidents
28. **improdutividade.cs** - Downtime/unproductive time
29. **tarefa_codigo_paralizacao.cs** - Task stoppage codes

#### Company & Organization
30. **empresa.cs** - Companies (contractors/clients)
31. **ramo.cs** - Business sectors
32. **licenca.cs** - Licenses

#### Geographic Data
33. **municipio.cs** - Cities/municipalities
34. **uf.cs** - States (Unidades Federativas)

#### User Management & Security
35. **usuario.cs** - System users
36. **grupo.cs** - User groups
37. **perfil_assinante.cs** - Signature profiles
38. **historico_login.cs** - Login history

#### Access Control (RBAC)
39. **menu.cs** - Menu structure
40. **menu_pagina.cs** - Menu-page relationships
41. **pagina.cs** - Pages/screens
42. **pagina_acao.cs** - Page actions
43. **acao.cs** - Actions/permissions
44. **grupo_pagina_acao.cs** - Group-page-action permissions

#### Media & Files
45. **imagem.cs** - Images/photos

#### System Configuration
46. **parametro.cs** - System parameters
47. **unidade_de_medida.cs** - Units of measurement

### Key Files
- **rdoappModel.edmx** - Entity Framework model (Database First)
- **rdoappModel.Context.cs** - DbContext generated code
- **App.Config** - Database connection strings

---

## 2. Web Application Analysis (rdoappProject/)

### Technology Stack
- **Backend:** ASP.NET Framework Web API
- **Frontend:** AngularJS (legacy)
- **Reporting:** ReportViewer (RDLC reports)
- **Authentication:** Custom authentication system

### Folder Structure

#### `/Api/` - Web API Controllers
RESTful API endpoints for:
- Obra (projects)
- Etapa (stages)
- Tarefa (tasks)
- Colaborador (workers)
- Equipamento (equipment)
- RDO (daily reports)
- Laudo (quality reports)
- Usuario (users)
- Authentication

#### `/Client/` - AngularJS Frontend
- Controllers
- Services
- Directives
- Views/Templates
- Routing configuration

#### `/Assets/` - Static Resources
- CSS stylesheets
- JavaScript libraries
- Images
- Fonts (Fontello icons)

#### `/uploads/` - User Uploaded Files
- Images
- Documents
- Reports

### Key Files
- **Global.asax.cs** - Application startup, routing configuration
- **Web.config** - Application configuration, connection strings
- **ReportViewerWebForm.aspx** - Report generation page

---

## 3. Solution Structure (solution/)

### Visual Studio Solution
- **rdoapp.sln** - Main solution file
- **IntegrationTestRdo/** - Integration tests
- **UnitTestRdo/** - Unit tests
- **packages/** - NuGet packages

---

## 4. Database Schema Reference

### KEY_COLUMN_USAGE_202601020935.csv
Contains foreign key relationships and constraints from production database.

**Critical for:**
- Understanding entity relationships
- Mapping foreign keys correctly
- Ensuring referential integrity

---

## 5. Critical Observations

### Strengths of Legacy Code
1. ✅ **Well-structured entities** - 48 entities properly organized
2. ✅ **Comprehensive RBAC** - Full role-based access control
3. ✅ **Complete audit trail** - History tables for tracking changes
4. ✅ **Separation of concerns** - Data layer separate from web layer
5. ✅ **RESTful API** - Clean API design

### Challenges for Migration
1. ⚠️ **Entity Framework 6** - Need to migrate to EF Core
2. ⚠️ **AngularJS** - Legacy frontend needs complete rewrite
3. ⚠️ **Custom authentication** - Need to migrate to ASP.NET Core Identity
4. ⚠️ **EDMX Database First** - Need to convert to Code First
5. ⚠️ **ReportViewer** - Need modern reporting solution
6. ⚠️ **Web.config** - Need to migrate to appsettings.json

---

## 6. Migration Complexity Assessment

### High Complexity Areas
1. **RBAC System** - Complex permission structure (menu → pagina → acao → grupo)
2. **Reporting** - ReportViewer RDLC reports need replacement
3. **File Uploads** - Need to migrate upload handling
4. **AngularJS Frontend** - Complete UI rewrite required

### Medium Complexity Areas
1. **Entity Relationships** - 48 entities with many relationships
2. **Authentication** - Custom auth to ASP.NET Core Identity
3. **API Controllers** - Web API to MVC API controllers

### Low Complexity Areas
1. **Entity Classes** - Straightforward mapping to EF Core
2. **Database Schema** - Already well-designed
3. **Business Logic** - Can be preserved

---

## 7. Recommended Migration Strategy

### Phase 1: Foundation (Week 1)
1. Create .NET 8 project structure
2. Migrate 48 entities to EF Core (Code First)
3. Configure relationships using Fluent API
4. Set up database connections
5. Verify data access layer

### Phase 2: Authentication (Week 1)
1. Implement ASP.NET Core Identity
2. Migrate usuario table structure
3. Implement login/logout
4. Session management
5. Test in multiple scenarios

### Phase 3: API Layer (Week 2)
1. Migrate Web API controllers to MVC API
2. Preserve RESTful endpoints
3. Implement authorization
4. Test API endpoints

### Phase 4: UI Migration (Week 2-3)
1. Replace AngularJS with Razor Pages/Blazor
2. Migrate page by page
3. Match legacy visual design
4. Implement Bootstrap 5
5. No inline scripts in views

### Phase 5: Advanced Features (Week 3)
1. Implement RBAC system
2. File upload handling
3. Reporting solution (FastReport/Telerik)
4. Image management

### Phase 6: Testing & Deployment (Week 4)
1. Comprehensive testing
2. Performance optimization
3. Security hardening
4. Production deployment

---

## 8. Next Steps

1. ✅ **Legacy code structure analyzed**
2. ⏭️ **Analyze database schema in detail** - Read KEY_COLUMN_USAGE.csv
3. ⏭️ **Document entity relationships** - Create ER diagram
4. ⏭️ **Analyze authentication system** - Understand usuario/grupo structure
5. ⏭️ **Create migration spec** - Detailed requirements document
6. ⏭️ **Start Phase 1** - Create .NET 8 project

---

## 9. Files to Analyze Next

### Priority 1 (Critical)
- [ ] `rdoappClass/rdoappModel.edmx` - Entity model
- [ ] `rdoappClass/usuario.cs` - User entity
- [ ] `rdoappClass/obra.cs` - Main work entity
- [ ] `rdoappProject/Global.asax.cs` - Application startup
- [ ] `rdoappProject/Web.config` - Configuration
- [ ] `KEY_COLUMN_USAGE_202601020935.csv` - Database relationships

### Priority 2 (Important)
- [ ] `rdoappProject/Api/` - API controllers
- [ ] `rdoappProject/Client/` - AngularJS code
- [ ] All entity classes in `rdoappClass/`

### Priority 3 (Reference)
- [ ] Test projects
- [ ] Asset files
- [ ] Upload handling

---

**Analysis Status:** ✅ Complete  
**Next Action:** Analyze database schema and entity relationships  
**Estimated Migration Time:** 4 weeks (with lessons learned applied)
