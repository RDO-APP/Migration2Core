# Database Schema & Relationships Analysis
## Complete Entity Relationship Mapping

**Analysis Date:** January 22, 2026  
**Database:** MySQL (piscinas_rdoapp)  
**Total Entities:** 48  
**Total Foreign Keys:** 62

---

## Executive Summary

The RDO database is a **well-designed, normalized schema** with comprehensive relationships covering:
- Work management (projects, stages, tasks)
- Personnel tracking (workers, assignments, history)
- Equipment management (machinery, assignments, usage)
- Daily reporting (RDO system with signatures)
- Quality control (water quality inspections - Laudo)
- Security & RBAC (users, groups, permissions)
- Audit trails (history tables for tracking changes)

**Key Strength:** Proper normalization with junction tables for many-to-many relationships  
**Key Challenge:** Complex RBAC system with 5-level permission structure

---

## Core Domain Model

### 1. Work Management Hierarchy

```
OBRA (Project)
  ├── ETAPA (Stage/Phase)
  │     └── TAREFA (Task)
  │           ├── ACIDENTE (Accident)
  │           ├── IMAGEM (Image)
  │           ├── OBRA_TAREFA_COLABORADOR (Worker Assignment)
  │           ├── OBRA_TAREFA_EQUIPAMENTO (Equipment Assignment)
  │           └── RDO_TAREFA (Daily Report Task)
  ├── OBRA_COLABORADOR (Worker-Project Assignment)
  ├── OBRA_EQUIPAMENTO (Equipment-Project Assignment)
  ├── RDO (Daily Report)
  ├── EFETIVO (Workforce Headcount)
  └── LAUDO (Quality Inspection Report)
```

**Relationships:**
- **1 OBRA → Many ETAPA** (One project has many stages)
- **1 ETAPA → Many TAREFA** (One stage has many tasks)
- **1 OBRA → Many OBRA_COLABORADOR** (Workers assigned to project)
- **1 OBRA → Many OBRA_EQUIPAMENTO** (Equipment assigned to project)
- **1 OBRA → Many RDO** (Daily reports for project)

---

## Entity Relationship Details

### 2. OBRA (Project) - Central Entity

**Primary Key:** `obr_id_obra`

**Foreign Keys:**
- `obr_id_municipio` → **municipio** (Project location)
- `obr_id_empresa_contratante` → **empresa** (Contracting company)
- `obr_id_empresa_contratada` → **empresa** (Contracted company)
- `obr_id_dono` → **empresa** (Owner company)
- `obr_id_colaborador` → **colaborador** (Responsible person)

**Key Properties:**
- `obr_ds_obra` - Project name
- `obr_dt_inicio` - Start date
- `obr_dt_previsao_fim` - Expected end date
- `obr_dt_fim` - Actual end date
- `obr_nr_area_total` - Total area
- `obr_cd_convite` - Invitation code

**Navigation Properties:**
- `etapa` (Collection) - Project stages
- `obra_colaborador` (Collection) - Worker assignments
- `obra_equipamento` (Collection) - Equipment assignments
- `rdo` (Collection) - Daily reports
- `efetivo` (Collection) - Workforce headcount
- `laudo` (Collection) - Quality inspections

**Business Rules:**
- Can have 3 different companies (owner, contractor, contracted)
- Has working hours configuration (week, Saturday, Sunday)
- Has invitation code for worker access

---

### 3. ETAPA (Stage/Phase)

**Primary Key:** `eta_id_etapa`

**Foreign Keys:**
- `eta_id_obra` → **obra** (Parent project)

**Key Properties:**
- `eta_ds_etapa` - Stage name
- `eta_nr_orderm` - Order/sequence number

**Navigation Properties:**
- `obra` - Parent project
- `tarefa` (Collection) - Tasks in this stage

**Business Rules:**
- Stages are ordered sequentially
- Each stage belongs to one project

---

### 4. TAREFA (Task) - Complex Entity

**Primary Key:** `tar_id_tarefa`

**Foreign Keys:**
- `tar_id_etapa` → **etapa** (Parent stage)
- `tar_id_status` → **status_tarefa** (Task status)
- `tar_id_unidade` → **unidade_de_medida** (Unit of measurement)
- `tar_id_colaborador_insercao` → **colaborador** (Creator)
- `tar_codigo_paralizacao` → **tarefa_codigo_paralizacao** (Stoppage code)

**Key Properties:**
- `tar_nr_agrupador` - GUID for grouping related tasks
- `tar_ds_tarefa` - Task description
- `tar_nr_qtd_construida` - Quantity built
- `tar_nr_qtd_previsao` - Expected quantity
- `tar_dt_inicio` - Start date
- `tar_dt_previsao_fim` - Expected end date
- `tar_dt_fim` - Actual end date
- `tar_vl_valor_unitario` - Unit value

**Water Quality Fields (Laudo):**
- `tar_nr_nivel_cloro` - Chlorine level
- `tar_nr_ph` - pH level
- `tar_nr_alcalinidade` - Alkalinity
- `tar_nr_limpidez` - Clarity
- `tar_nr_superficie` - Surface condition
- `tar_nr_fundo` - Bottom condition
- `tar_nr_nivel_detritos` - Debris level
- `tar_nr_nivel_proliferacao` - Proliferation level

**Navigation Properties:**
- `etapa` - Parent stage
- `status_tarefa` - Current status
- `colaborador` - Creator
- `acidente` (Collection) - Accidents related to task
- `imagem` (Collection) - Images
- `obra_tarefa_colaborador` (Collection) - Worker assignments
- `obra_tarefa_equipamento` (Collection) - Equipment assignments
- `rdo_tarefa` (Collection) - Daily report entries
- `historico_tarefa_rdo` (Collection) - Task history

**Business Rules:**
- Tasks can be grouped using GUID
- Tracks both expected and actual quantities
- Has water quality measurements (pool maintenance)
- Can have stoppage/paralyzation codes

---

### 5. COLABORADOR (Worker/Employee)

**Primary Key:** `col_id_colaborador`

**Foreign Keys:**
- `col_id_municipio` → **municipio** (City of residence)

**Key Properties:**
- `col_nr_cpf` - CPF (Brazilian ID)
- `col_nm_colaborador` - Name
- `col_ds_email` - Email
- `col_ds_telefone_principal` - Primary phone
- `col_ds_foto` - Photo path
- `col_ds_assinatura` - Signature image path
- `col_ds_senha` - Password (legacy)
- `col_ds_login` - Login username
- `col_ds_crea` - CREA registration (engineer)
- `col_st_admin` - Is admin flag

**Navigation Properties:**
- `municipio` - City
- `obra_colaborador` (Collection) - Project assignments
- `obra` (Collection) - Projects where responsible
- `empresa` (Collection) - Companies where representative
- `rdo` (Collection) - Daily reports created
- `tarefa` (Collection) - Tasks created

**Business Rules:**
- Can be admin
- Has signature image for report signing
- Can have CREA registration (engineers)
- Has legacy password field (needs migration)

---

### 6. OBRA_COLABORADOR (Worker-Project Assignment)

**Primary Key:** `oco_id_obra_colaborador`

**Foreign Keys:**
- `oco_id_obra` → **obra** (Project)
- `oco_id_colaborador` → **colaborador** (Worker)
- `oco_id_cargo` → **cargo** (Job position)
- `oco_id_grupo` → **grupo** (Security group/role)

**Navigation Properties:**
- `obra` - Project
- `colaborador` - Worker
- `cargo` - Job position
- `grupo` - Security group
- `assinatura_rdo` (Collection) - Report signatures
- `efetivo` (Collection) - Workforce records
- `historico_tarefa_colaborador` (Collection) - Task history
- `obra_tarefa_colaborador` (Collection) - Task assignments
- `acidente_colaborador` (Collection) - Accident records

**Business Rules:**
- Junction table for many-to-many relationship
- Assigns security group at project level
- Assigns job position for this project
- Used for report signatures

---

### 7. EQUIPAMENTO (Equipment)

**Primary Key:** `equ_id_equipamento`

**Foreign Keys:**
- `equ_id_tipo_equipamento` → **tipo_equipamento** (Equipment type)

**Key Properties:**
- `equ_ds_equipamento` - Equipment name
- `equ_ds_marca` - Brand
- `equ_ds_modelo` - Model
- `equ_ds_imagem` - Image path

**Navigation Properties:**
- `tipo_equipamento` - Equipment type
- `obra_equipamento` (Collection) - Project assignments

---

### 8. OBRA_EQUIPAMENTO (Equipment-Project Assignment)

**Primary Key:** `oeq_id_obra_equipamento`

**Foreign Keys:**
- `oeq_id_obra` → **obra** (Project)
- `oeq_id_equipamento` → **equipamento** (Equipment)

**Navigation Properties:**
- `obra` - Project
- `equipamento` - Equipment
- `historico_tarefa_equipamento` (Collection) - Usage history
- `obra_tarefa_equipamento` (Collection) - Task assignments

---

### 9. RDO (Daily Report) - Core Reporting Entity

**Primary Key:** `rdo_id_rdo`

**Foreign Keys:**
- `rdo_id_obra` → **obra** (Project)
- `rdo_id_status` → **status_rdo** (Report status)
- `rdo_id_colaborador` → **colaborador** (Creator)
- `rdo_id_improdutividade` → **improdutividade** (Downtime reason)

**Key Properties:**
- `rdo_dt_data` - Report date
- `rdo_ds_comentario` - Comments
- `rdo_nr_temperatura` - Temperature
- `rdo_ds_clima` - Weather conditions

**Navigation Properties:**
- `obra` - Project
- `status_rdo` - Status
- `colaborador` - Creator
- `improdutividade` - Downtime reason
- `assinatura_rdo` (Collection) - Signatures
- `historico_tarefa_rdo` (Collection) - Task history
- `rdo_imagem` (Collection) - Images
- `rdo_tarefa` (Collection) - Tasks in report

**Business Rules:**
- One report per day per project
- Requires signatures for approval
- Tracks weather and temperature
- Can have downtime reasons

---

### 10. HISTORICO_TAREFA_RDO (Task History in Daily Report)

**Primary Key:** `his_id_historico_tarefa_rdo`

**Foreign Keys:**
- `his_id_tarefa` → **tarefa** (Task)
- `his_id_rdo` → **rdo** (Daily report)
- `his_id_status` → **status_tarefa** (Task status)

**Key Properties:**
- `his_dt_data` - Date
- `his_ds_foto` - Photo
- `his_ds_comentario` - Comment
- `his_nr_horas_trabalhadas` - Hours worked

**Navigation Properties:**
- `tarefa` - Task
- `rdo` - Daily report
- `status_tarefa` - Status
- `historico_tarefa_colaborador` (Collection) - Workers involved
- `historico_tarefa_equipamento` (Collection) - Equipment used

**Business Rules:**
- Tracks task progress in daily reports
- Records workers and equipment used
- Captures status changes over time

---

### 11. LAUDO (Quality Inspection Report)

**Primary Key:** `lau_id_laudo`

**Foreign Keys:**
- `lau_id_obra` → **obra** (Project)
- `lau_id_status` → **status_rdo** (Status)
- `lau_id_colaborador` → **colaborador** (Inspector)

**Key Properties:**
- Water quality measurements (inherited from tarefa)
- Inspection date
- Comments
- Status

**Business Rules:**
- Quality inspection for pool maintenance
- Uses same water quality fields as tarefa
- Requires inspector signature

---

### 12. EMPRESA (Company)

**Primary Key:** `emp_id_empresa`

**Foreign Keys:**
- `emp_id_municipio` → **municipio** (City)
- `emp_id_ramo` → **ramo** (Business sector)
- `emp_id_setor` → **setor** (Department)
- `emp_id_colaborador` → **colaborador** (Representative)
- `emp_id_licenca` → **licenca** (License)

**Key Properties:**
- `emp_ds_razao_social` - Legal name
- `emp_nm_fantasia` - Trade name
- `emp_nr_cnpj` - CNPJ (Brazilian company ID)
- `emp_ds_logo` - Logo path
- `emp_id_token` - API token

**Navigation Properties:**
- `municipio` - City
- `ramo` - Business sector
- `setor` - Department
- `colaborador` - Representative
- `licenca` - License
- `obra` (Collection) - Projects as owner
- `obra1` (Collection) - Projects as contractor
- `obra2` (Collection) - Projects as contracted

**Business Rules:**
- Can be owner, contractor, or contracted company
- Has API token for integrations
- Requires license

---

## Security & RBAC System

### 13. RBAC Structure (5-Level Permission System)

```
USUARIO (User)
  └── GRUPO (Group/Role)
        ├── MENU (Menu)
        └── GRUPO_PAGINA_ACAO (Permissions)
              └── PAGINA_ACAO (Page-Action)
                    ├── PAGINA (Page)
                    └── ACAO (Action)
```

**Relationship Flow:**
1. **USUARIO** belongs to one **GRUPO**
2. **GRUPO** has one **MENU** (menu structure)
3. **GRUPO** has many **GRUPO_PAGINA_ACAO** (permissions)
4. **PAGINA_ACAO** links **PAGINA** and **ACAO**
5. **MENU_PAGINA** links **MENU** and **PAGINA**

**Foreign Key Chain:**
```
usuario.usu_id_grupo → grupo.gru_id_grupo
grupo.gru_id_menu → menu.men_id_menu
grupo_pagina_acao.gpa_id_grupo → grupo.gru_id_grupo
grupo_pagina_acao.gpa_id_pagina_acao → pagina_acao.paa_id_pagina_acao
pagina_acao.paa_id_pagina → pagina.pag_id_pagina
pagina_acao.paa_id_acao → acao.aca_id_acao
menu_pagina.mpa_id_menu → menu.men_id_menu
menu_pagina.mpa_id_pagina → pagina.pag_id_pagina
```

**Business Rules:**
- Users are assigned to groups
- Groups define menu structure
- Groups have granular page-action permissions
- Pages can have multiple actions (view, edit, delete, etc.)
- Menu structure is hierarchical (menu_pagina.mpa_id_pagina_pai)

---

### 14. USUARIO (User)

**Primary Key:** `usu_id_usuario`

**Foreign Keys:**
- `usu_id_grupo` → **grupo** (Security group)

**Key Properties:**
- `usu_ds_email` - Email (login)
- `usu_ds_senha` - Password
- `usu_st_status` - Active status
- `usu_st_alterar_senha` - Force password change

**Navigation Properties:**
- `grupo` - Security group

**Business Rules:**
- Email is used for login
- Can force password change on next login
- Can be active/inactive

---

### 15. GRUPO (Group/Role)

**Primary Key:** `gru_id_grupo`

**Foreign Keys:**
- `gru_id_menu` → **menu** (Menu structure)
- `gru_id_licenca` → **licenca** (License)

**Key Properties:**
- `gru_nm_nome` - Group name
- `gru_st_diretor` - Is director flag
- `gru_st_contratante` - Is contractor flag

**Navigation Properties:**
- `menu` - Menu structure
- `licenca` - License
- `grupo_pagina_acao` (Collection) - Permissions
- `obra_colaborador` (Collection) - Worker assignments
- `usuario` (Collection) - Users in group

**Business Rules:**
- Defines menu structure for users
- Has special flags (director, contractor)
- Controls page-action permissions

---

## Geographic & Reference Data

### 16. Geographic Hierarchy

```
UF (State)
  └── MUNICIPIO (City)
        ├── COLABORADOR (Workers)
        ├── EMPRESA (Companies)
        └── OBRA (Projects)
```

**Foreign Keys:**
```
municipio.mun_id_uf → uf.ufe_id_uf
colaborador.col_id_municipio → municipio.mun_id_municipio
empresa.emp_id_municipio → municipio.mun_id_municipio
obra.obr_id_municipio → municipio.mun_id_municipio
```

---

### 17. Reference/Lookup Tables

**Status Tables:**
- `status_tarefa` - Task statuses
- `status_rdo` - Report statuses
- `efetivo_status` - Workforce statuses

**Classification Tables:**
- `cargo` - Job positions
- `setor` - Departments
- `ramo` - Business sectors
- `tipo_equipamento` - Equipment types
- `unidade_de_medida` - Units of measurement
- `tarefa_codigo_paralizacao` - Stoppage codes
- `improdutividade` - Downtime reasons

**System Tables:**
- `acao` - Actions/permissions
- `pagina` - Pages/screens
- `menu` - Menu items
- `parametro` - System parameters
- `licenca` - Licenses

---

## Audit & History Tables

### 18. History Tracking

**HISTORICO_LOGIN** (Login History)
- Tracks user logins
- Records which project was accessed
- Timestamp of login

**HISTORICO_TAREFA_RDO** (Task History in Reports)
- Tracks task progress over time
- Records status changes
- Links to workers and equipment used

**HISTORICO_TAREFA_COLABORADOR** (Worker Task History)
- Links workers to task history entries

**HISTORICO_TAREFA_EQUIPAMENTO** (Equipment Task History)
- Links equipment to task history entries

---

## Junction Tables (Many-to-Many)

### 19. Assignment Tables

**OBRA_COLABORADOR** - Workers assigned to projects
- Links: obra ↔ colaborador
- Additional: cargo, grupo

**OBRA_EQUIPAMENTO** - Equipment assigned to projects
- Links: obra ↔ equipamento

**OBRA_TAREFA_COLABORADOR** - Workers assigned to tasks
- Links: tarefa ↔ obra_colaborador

**OBRA_TAREFA_EQUIPAMENTO** - Equipment assigned to tasks
- Links: tarefa ↔ obra_equipamento

**RDO_TAREFA** - Tasks in daily reports
- Links: rdo ↔ tarefa

**RDO_IMAGEM** - Images in daily reports
- Links: rdo ↔ imagem

**ACIDENTE_COLABORADOR** - Workers involved in accidents
- Links: acidente ↔ obra_colaborador

**GRUPO_PAGINA_ACAO** - Group permissions
- Links: grupo ↔ pagina_acao

**MENU_PAGINA** - Menu structure
- Links: menu ↔ pagina
- Self-referencing: mpa_id_pagina_pai

**PAGINA_ACAO** - Page actions
- Links: pagina ↔ acao

---

## Critical Observations

### Strengths

1. ✅ **Proper Normalization** - Well-designed schema with appropriate junction tables
2. ✅ **Comprehensive Audit Trail** - History tables track changes over time
3. ✅ **Flexible RBAC** - Granular permission system
4. ✅ **Clear Hierarchy** - Obra → Etapa → Tarefa structure
5. ✅ **Multi-Company Support** - Handles owner, contractor, contracted
6. ✅ **Geographic Data** - Proper UF → Municipio hierarchy

### Challenges for Migration

1. ⚠️ **Complex RBAC** - 5-level permission system needs careful migration
2. ⚠️ **Multiple Company Roles** - Obra has 3 empresa foreign keys
3. ⚠️ **Self-Referencing** - menu_pagina has parent-child relationship
4. ⚠️ **Legacy Authentication** - colaborador and usuario both have passwords
5. ⚠️ **Water Quality Fields** - Added to tarefa (not normalized)
6. ⚠️ **GUID Grouping** - tar_nr_agrupador for task grouping

---

## Migration Strategy Recommendations

### Phase 1: Core Entities (Week 1)
1. **Geographic** - uf, municipio
2. **Reference** - All lookup tables (status, cargo, setor, etc.)
3. **Company** - empresa, ramo, setor, licenca
4. **Personnel** - colaborador, cargo
5. **Equipment** - equipamento, tipo_equipamento, marca, modelo

### Phase 2: Work Management (Week 1)
1. **Project** - obra
2. **Stage** - etapa
3. **Task** - tarefa, status_tarefa, unidade_de_medida
4. **Assignments** - obra_colaborador, obra_equipamento

### Phase 3: Reporting (Week 2)
1. **Daily Reports** - rdo, status_rdo, improdutividade
2. **Task History** - historico_tarefa_rdo
3. **Worker/Equipment History** - historico_tarefa_colaborador, historico_tarefa_equipamento
4. **Junction Tables** - rdo_tarefa, rdo_imagem
5. **Signatures** - assinatura_rdo

### Phase 4: Quality & Incidents (Week 2)
1. **Quality** - laudo
2. **Incidents** - acidente, acidente_colaborador
3. **Workforce** - efetivo, efetivo_status
4. **Images** - imagem

### Phase 5: Security & RBAC (Week 3)
1. **Authentication** - usuario, grupo
2. **Menu** - menu, menu_pagina
3. **Permissions** - pagina, acao, pagina_acao, grupo_pagina_acao
4. **Audit** - historico_login

---

## Entity Framework Core Configuration

### Required Fluent API Configurations

**Multiple Foreign Keys to Same Table:**
```csharp
// obra → empresa (3 relationships)
modelBuilder.Entity<Obra>()
    .HasOne(o => o.EmpresaDono)
    .WithMany(e => e.ObrasComoDono)
    .HasForeignKey(o => o.ObrIdDono);

modelBuilder.Entity<Obra>()
    .HasOne(o => o.EmpresaContratante)
    .WithMany(e => e.ObrasComoContratante)
    .HasForeignKey(o => o.ObrIdEmpresaContratante);

modelBuilder.Entity<Obra>()
    .HasOne(o => o.EmpresaContratada)
    .WithMany(e => e.ObrasComoContratada)
    .HasForeignKey(o => o.ObrIdEmpresaContratada);
```

**Self-Referencing:**
```csharp
// menu_pagina → menu_pagina (parent-child)
modelBuilder.Entity<MenuPagina>()
    .HasOne(mp => mp.MenuPaginaPai)
    .WithMany(mp => mp.MenuPaginasFilhas)
    .HasForeignKey(mp => mp.MpaIdPaginaPai);
```

**Composite Unique Keys:**
```csharp
// historico_login (no primary key in legacy)
modelBuilder.Entity<HistoricoLogin>()
    .HasKey(hl => new { hl.ColIdColaborador, hl.DataLogin });
```

---

## Next Steps

1. ✅ **Database schema analyzed**
2. ✅ **All 62 foreign key relationships documented**
3. ⏭️ **Create Entity Framework Core entities**
4. ⏭️ **Configure Fluent API relationships**
5. ⏭️ **Create migration spec document**
6. ⏭️ **Start Phase 1 implementation**

---

**Analysis Status:** ✅ Complete  
**Total Entities:** 48  
**Total Relationships:** 62 foreign keys  
**Complexity Level:** High (due to RBAC system)  
**Estimated Migration Time:** 4 weeks

---

**Ready for:** Entity Framework Core implementation and migration spec creation
