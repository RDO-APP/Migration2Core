# Entity Relationship Diagram
## Visual Database Schema Representation

**Created:** January 22, 2026  
**Database:** piscinas_rdoapp (MySQL)  
**Total Entities:** 48

---

## Core Domain Model - Visual Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                        WORK MANAGEMENT                           │
└─────────────────────────────────────────────────────────────────┘

                            EMPRESA
                         (Company)
                    ┌────────┴────────┐
                    │                 │
              (contratante)      (contratada)
                    │                 │
                    └────────┬────────┘
                             │
                          OBRA ──────────── MUNICIPIO
                        (Project)              (City)
                             │                    │
                    ┌────────┼────────┐          UF
                    │        │        │        (State)
                 ETAPA    RDO    LAUDO
                (Stage) (Report) (Quality)
                    │
                 TAREFA ──────── STATUS_TAREFA
                 (Task)          (Task Status)
                    │
        ┌───────────┼───────────┐
        │           │           │
    ACIDENTE    IMAGEM    OBRA_TAREFA_*
   (Accident)  (Image)   (Assignments)
```

---

## 1. Work Management Core

### OBRA (Project) - Central Hub

```
                    ┌─────────────────┐
                    │     EMPRESA     │
                    │   (3 roles)     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
              (dono/owner)      (contratante)
                    │                 │
                    │        (contratada)
                    │                 │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
    MUNICIPIO            COLABORADOR          LICENCA
     (City)            (Responsible)         (License)
        │                    │
        │                    │
        └────────────────────┼────────────────────┘
                             │
                    ┌────────▼────────┐
                    │      OBRA       │
                    │    (Project)    │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
     ETAPA              OBRA_COLABORADOR    OBRA_EQUIPAMENTO
    (Stage)           (Worker Assignment) (Equipment Assignment)
        │                    │                    │
        ▼                    ▼                    ▼
     TAREFA            COLABORADOR           EQUIPAMENTO
     (Task)              (Worker)            (Equipment)
```

**Key Relationships:**
- OBRA has 3 foreign keys to EMPRESA (owner, contractor, contracted)
- OBRA → MUNICIPIO (project location)
- OBRA → COLABORADOR (responsible person)
- OBRA → Many ETAPA (project stages)
- OBRA → Many OBRA_COLABORADOR (worker assignments)
- OBRA → Many OBRA_EQUIPAMENTO (equipment assignments)

---

## 2. Task Management Hierarchy

```
┌──────────────────────────────────────────────────────────────┐
│                    TASK HIERARCHY                             │
└──────────────────────────────────────────────────────────────┘

                         OBRA
                      (Project)
                          │
                          ▼
                       ETAPA ──────── eta_nr_orderm
                      (Stage)         (Order)
                          │
                          ▼
                       TAREFA ──────── STATUS_TAREFA
                       (Task)          (Status)
                          │
                          ├─── UNIDADE_DE_MEDIDA
                          │    (Unit of Measurement)
                          │
                          ├─── COLABORADOR
                          │    (Creator)
                          │
                          └─── TAREFA_CODIGO_PARALIZACAO
                               (Stoppage Code)
                          
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
    ACIDENTE          IMAGEM        OBRA_TAREFA_*
   (Accident)        (Image)       (Assignments)
        │                              │
        ▼                              ▼
ACIDENTE_COLABORADOR          ┌───────┴───────┐
(Worker Accident)             │               │
                    OBRA_TAREFA_        OBRA_TAREFA_
                    COLABORADOR         EQUIPAMENTO
                  (Worker Assignment) (Equipment Assignment)
```

**Key Properties:**
- `tar_nr_agrupador` (GUID) - Groups related tasks
- `tar_nr_qtd_construida` - Quantity built
- `tar_nr_qtd_previsao` - Expected quantity
- `tar_vl_valor_unitario` - Unit value

**Water Quality Fields (Pool Maintenance):**
- `tar_nr_nivel_cloro` - Chlorine level
- `tar_nr_ph` - pH level
- `tar_nr_alcalinidade` - Alkalinity
- `tar_nr_limpidez` - Clarity
- `tar_nr_superficie` - Surface condition
- `tar_nr_fundo` - Bottom condition
- `tar_nr_nivel_detritos` - Debris level
- `tar_nr_nivel_proliferacao` - Proliferation level

---

## 3. Daily Reporting System (RDO)

```
┌──────────────────────────────────────────────────────────────┐
│                    RDO (DAILY REPORT)                         │
└──────────────────────────────────────────────────────────────┘

                         OBRA
                      (Project)
                          │
                          ▼
                    ┌─────────┐
                    │   RDO   │ ──────── STATUS_RDO
                    │ (Report)│          (Status)
                    └────┬────┘
                         │
                         ├─── COLABORADOR (Creator)
                         ├─── IMPRODUTIVIDADE (Downtime)
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
ASSINATURA_RDO    RDO_TAREFA      RDO_IMAGEM
  (Signature)    (Task Entry)      (Image)
        │                │                │
        ▼                ▼                ▼
OBRA_COLABORADOR      TAREFA          IMAGEM
  (Signer)           (Task)          (Image)
        │
        ▼
HISTORICO_TAREFA_RDO ──────── STATUS_TAREFA
(Task History)                (Task Status)
        │
        ├─── HISTORICO_TAREFA_COLABORADOR
        │    (Worker History)
        │         │
        │         ▼
        │    OBRA_COLABORADOR
        │
        └─── HISTORICO_TAREFA_EQUIPAMENTO
             (Equipment History)
                  │
                  ▼
             OBRA_EQUIPAMENTO
```

**RDO Flow:**
1. RDO created for project on specific date
2. Tasks added via RDO_TAREFA
3. Task history recorded in HISTORICO_TAREFA_RDO
4. Workers and equipment linked to history
5. Signatures collected via ASSINATURA_RDO
6. Images attached via RDO_IMAGEM

---

## 4. Personnel Management

```
┌──────────────────────────────────────────────────────────────┐
│                  PERSONNEL MANAGEMENT                         │
└──────────────────────────────────────────────────────────────┘

                      MUNICIPIO
                        (City)
                          │
                          ▼
                    COLABORADOR ──────── col_st_admin
                     (Worker)            (Is Admin)
                          │
                          ├─── col_ds_foto (Photo)
                          ├─── col_ds_assinatura (Signature)
                          ├─── col_ds_crea (Engineer License)
                          └─── col_ds_senha (Legacy Password)
                          
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
    EMPRESA          OBRA            OBRA_COLABORADOR
   (Company)      (Projects)        (Project Assignment)
 (Representative)  (Responsible)            │
                                            ├─── CARGO (Position)
                                            ├─── GRUPO (Security Group)
                                            │
                        ┌───────────────────┼───────────────────┐
                        │                   │                   │
                        ▼                   ▼                   ▼
                   EFETIVO          ASSINATURA_RDO    HISTORICO_TAREFA_
                 (Workforce)         (Signatures)      COLABORADOR
                        │                                (Task History)
                        ▼
                 EFETIVO_STATUS
                   (Status)
```

**Key Relationships:**
- COLABORADOR can be admin
- COLABORADOR → MUNICIPIO (residence)
- COLABORADOR → EMPRESA (as representative)
- COLABORADOR → OBRA (as responsible)
- COLABORADOR → OBRA_COLABORADOR (project assignments)
- OBRA_COLABORADOR → CARGO (job position)
- OBRA_COLABORADOR → GRUPO (security group)

---

## 5. Equipment Management

```
┌──────────────────────────────────────────────────────────────┐
│                  EQUIPMENT MANAGEMENT                         │
└──────────────────────────────────────────────────────────────┘

                  TIPO_EQUIPAMENTO
                  (Equipment Type)
                          │
                          ▼
                    EQUIPAMENTO
                    (Equipment)
                          │
                          ├─── equ_ds_marca (Brand)
                          ├─── equ_ds_modelo (Model)
                          └─── equ_ds_imagem (Image)
                          │
                          ▼
                 OBRA_EQUIPAMENTO
              (Project Assignment)
                          │
                          ├─── OBRA (Project)
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
OBRA_TAREFA_      HISTORICO_TAREFA_    (Other uses)
EQUIPAMENTO        EQUIPAMENTO
(Task Assignment) (Usage History)
        │                 │
        ▼                 ▼
     TAREFA        HISTORICO_TAREFA_RDO
     (Task)         (Task History)
```

---

## 6. Security & RBAC System

```
┌──────────────────────────────────────────────────────────────┐
│              RBAC (ROLE-BASED ACCESS CONTROL)                 │
└──────────────────────────────────────────────────────────────┘

                      LICENCA
                     (License)
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
    EMPRESA           GRUPO             (Others)
   (Company)        (Group/Role)
                          │
                          ├─── MENU (Menu Structure)
                          │       │
                          │       ▼
                          │  MENU_PAGINA ──┐
                          │  (Menu Items)  │ (Self-referencing)
                          │       │        │ mpa_id_pagina_pai
                          │       │        │
                          │       ▼        ▼
                          │    PAGINA   MENU_PAGINA
                          │    (Page)    (Parent)
                          │
                          ├─── USUARIO (Users)
                          │
                          └─── GRUPO_PAGINA_ACAO
                               (Permissions)
                                    │
                                    ▼
                              PAGINA_ACAO
                             (Page Actions)
                                    │
                        ┌───────────┴───────────┐
                        │                       │
                        ▼                       ▼
                     PAGINA                  ACAO
                     (Page)                (Action)
                                          (View/Edit/Delete)
```

**Permission Flow:**
1. USUARIO → GRUPO (User belongs to group)
2. GRUPO → MENU (Group has menu structure)
3. GRUPO → GRUPO_PAGINA_ACAO (Group has permissions)
4. GRUPO_PAGINA_ACAO → PAGINA_ACAO (Links to page-action)
5. PAGINA_ACAO → PAGINA + ACAO (Page and action)

**Example:**
- User "João" belongs to Group "Engenheiro"
- Group "Engenheiro" has permission to:
  - PAGINA "Obras" + ACAO "Visualizar"
  - PAGINA "Obras" + ACAO "Editar"
  - PAGINA "Tarefas" + ACAO "Visualizar"

---

## 7. Geographic Hierarchy

```
┌──────────────────────────────────────────────────────────────┐
│                    GEOGRAPHIC DATA                            │
└──────────────────────────────────────────────────────────────┘

                         UF
                      (State)
                    ufe_id_uf
                         │
                         ▼
                    MUNICIPIO
                      (City)
                  mun_id_municipio
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
  COLABORADOR        EMPRESA           OBRA
   (Worker)         (Company)       (Project)
```

**Brazilian Geographic Structure:**
- UF = Unidade Federativa (State) - e.g., SP, RJ, MG
- MUNICIPIO = City/Municipality - e.g., São Paulo, Rio de Janeiro

---

## 8. Reference/Lookup Tables

```
┌──────────────────────────────────────────────────────────────┐
│                    LOOKUP TABLES                              │
└──────────────────────────────────────────────────────────────┘

STATUS TABLES:
├── STATUS_TAREFA (Task Status)
├── STATUS_RDO (Report Status)
└── EFETIVO_STATUS (Workforce Status)

CLASSIFICATION TABLES:
├── CARGO (Job Position)
├── SETOR (Department)
├── RAMO (Business Sector)
├── TIPO_EQUIPAMENTO (Equipment Type)
├── UNIDADE_DE_MEDIDA (Unit of Measurement)
├── TAREFA_CODIGO_PARALIZACAO (Stoppage Code)
└── IMPRODUTIVIDADE (Downtime Reason)

SYSTEM TABLES:
├── ACAO (Action/Permission)
├── PAGINA (Page/Screen)
├── MENU (Menu Item)
├── PARAMETRO (System Parameter)
└── LICENCA (License)
```

---

## 9. Audit & History Tables

```
┌──────────────────────────────────────────────────────────────┐
│                    AUDIT TRAIL                                │
└──────────────────────────────────────────────────────────────┘

HISTORICO_LOGIN
(Login History)
├── col_id_colaborador
├── obr_id_obra
└── data_login

HISTORICO_TAREFA_RDO
(Task History in Reports)
├── his_id_tarefa
├── his_id_rdo
├── his_id_status
└── his_dt_data
     │
     ├─── HISTORICO_TAREFA_COLABORADOR
     │    (Workers involved)
     │
     └─── HISTORICO_TAREFA_EQUIPAMENTO
          (Equipment used)
```

---

## 10. Junction Tables Summary

```
┌──────────────────────────────────────────────────────────────┐
│              MANY-TO-MANY RELATIONSHIPS                       │
└──────────────────────────────────────────────────────────────┘

WORK ASSIGNMENTS:
├── OBRA_COLABORADOR (Project ↔ Worker)
├── OBRA_EQUIPAMENTO (Project ↔ Equipment)
├── OBRA_TAREFA_COLABORADOR (Task ↔ Worker)
└── OBRA_TAREFA_EQUIPAMENTO (Task ↔ Equipment)

REPORTING:
├── RDO_TAREFA (Report ↔ Task)
└── RDO_IMAGEM (Report ↔ Image)

INCIDENTS:
└── ACIDENTE_COLABORADOR (Accident ↔ Worker)

SECURITY:
├── GRUPO_PAGINA_ACAO (Group ↔ Page-Action)
├── MENU_PAGINA (Menu ↔ Page)
└── PAGINA_ACAO (Page ↔ Action)
```

---

## 11. Complex Relationships

### Multiple Foreign Keys to Same Table

**OBRA → EMPRESA (3 relationships):**
```
OBRA
├── obr_id_dono → EMPRESA (Owner)
├── obr_id_empresa_contratante → EMPRESA (Contractor)
└── obr_id_empresa_contratada → EMPRESA (Contracted)
```

**EMPRESA → COLABORADOR:**
```
EMPRESA
└── emp_id_colaborador → COLABORADOR (Representative)

COLABORADOR
└── (Can represent multiple companies)
```

### Self-Referencing Relationships

**MENU_PAGINA (Hierarchical Menu):**
```
MENU_PAGINA
├── mpa_id_menu_pagina (PK)
├── mpa_id_pagina_pai → MENU_PAGINA (Parent)
└── (Can have multiple children)

Example:
├── Obras (Parent)
│   ├── Listar Obras (Child)
│   ├── Nova Obra (Child)
│   └── Relatórios (Child)
```

---

## 12. Data Flow Diagrams

### Daily Report Creation Flow

```
1. User logs in
   └── HISTORICO_LOGIN created

2. User selects OBRA
   └── Checks OBRA_COLABORADOR assignment

3. User creates RDO
   ├── RDO record created
   ├── RDO_TAREFA links to tasks
   └── STATUS_RDO = "Em Andamento"

4. User adds task progress
   ├── HISTORICO_TAREFA_RDO created
   ├── HISTORICO_TAREFA_COLABORADOR (workers)
   └── HISTORICO_TAREFA_EQUIPAMENTO (equipment)

5. User adds images
   └── RDO_IMAGEM links images

6. User requests signatures
   └── ASSINATURA_RDO created

7. Report approved
   └── STATUS_RDO = "Aprovado"
```

### Task Assignment Flow

```
1. OBRA created
   └── Project established

2. ETAPA created
   └── Stages defined

3. TAREFA created
   └── Tasks defined in stages

4. Workers assigned
   ├── OBRA_COLABORADOR (project level)
   └── OBRA_TAREFA_COLABORADOR (task level)

5. Equipment assigned
   ├── OBRA_EQUIPAMENTO (project level)
   └── OBRA_TAREFA_EQUIPAMENTO (task level)

6. Work performed
   └── HISTORICO_TAREFA_RDO tracks progress
```

---

## 13. Migration Complexity Map

### Low Complexity (Simple 1:N relationships)
- UF → MUNICIPIO
- TIPO_EQUIPAMENTO → EQUIPAMENTO
- CARGO, SETOR, RAMO (lookup tables)
- STATUS_* tables

### Medium Complexity (Standard relationships)
- OBRA → ETAPA → TAREFA
- COLABORADOR → OBRA_COLABORADOR
- EQUIPAMENTO → OBRA_EQUIPAMENTO
- RDO → RDO_TAREFA

### High Complexity (Special handling required)
- OBRA → EMPRESA (3 foreign keys)
- MENU_PAGINA (self-referencing)
- RBAC system (5-level hierarchy)
- HISTORICO_LOGIN (no primary key)
- Water quality fields in TAREFA

---

## 14. Entity Framework Core Considerations

### Required Fluent API Configurations

**1. Multiple Foreign Keys:**
```csharp
// OBRA → EMPRESA (3 relationships)
HasOne(o => o.EmpresaDono)
HasOne(o => o.EmpresaContratante)
HasOne(o => o.EmpresaContratada)
```

**2. Self-Referencing:**
```csharp
// MENU_PAGINA → MENU_PAGINA
HasOne(mp => mp.MenuPaginaPai)
    .WithMany(mp => mp.MenuPaginasFilhas)
```

**3. Composite Keys:**
```csharp
// HISTORICO_LOGIN
HasKey(hl => new { hl.ColIdColaborador, hl.DataLogin })
```

**4. Many-to-Many with Payload:**
```csharp
// OBRA_COLABORADOR (has cargo, grupo)
// Not a simple many-to-many - has additional fields
```

---

## Summary

**Total Entities:** 48  
**Total Foreign Keys:** 62  
**Junction Tables:** 10  
**Self-Referencing:** 1 (MENU_PAGINA)  
**Multiple FK to Same Table:** 2 (OBRA→EMPRESA, EMPRESA→COLABORADOR)  
**No Primary Key:** 1 (HISTORICO_LOGIN)

**Complexity Rating:**
- Core Work Management: ⭐⭐⭐ (Medium)
- Personnel Management: ⭐⭐ (Low-Medium)
- Equipment Management: ⭐⭐ (Low-Medium)
- Reporting System: ⭐⭐⭐⭐ (High)
- RBAC System: ⭐⭐⭐⭐⭐ (Very High)
- Geographic Data: ⭐ (Low)

**Overall Migration Complexity:** ⭐⭐⭐⭐ (High)

---

**Status:** ✅ Complete  
**Next Step:** Create Entity Framework Core entity classes with proper configurations
