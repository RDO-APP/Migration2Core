# Escolher Obra Page - Technical Blueprint
**Clean Migration 2026 - Deep-Dive Analysis**  
**Date**: February 3, 2026  
**Status**: Complete Technical Specification  
**Purpose**: Comprehensive blueprint for implementing the Obra Selection page without copying legacy code

---

## 📋 TABLE OF CONTENTS

1. [Executive Summary](#executive-summary)
2. [Page Purpose & User Flow](#page-purpose--user-flow)
3. [Data Model & Entity Structure](#data-model--entity-structure)
4. [Card Anatomy - Visual & Data Specifications](#card-anatomy---visual--data-specifications)
5. [Business Logic - Progress & Status Calculations](#business-logic---progress--status-calculations)
6. [Interactive Behavior - Click & Navigation](#interactive-behavior---click--navigation)
7. [Header & Navigation Elements](#header--navigation-elements)
8. [Filtering System](#filtering-system)
9. [API Endpoints & Data Flow](#api-endpoints--data-flow)
10. [Implementation Checklist](#implementation-checklist)

---

## 1. EXECUTIVE SUMMARY

The **Escolher Obra** page is Step 2 of the authentication flow. After a user logs in with their credentials (Step 1), they must select which construction project (obra) they want to work on. This page displays all obras the user has access to as interactive cards with real-time progress indicators.

### Key Characteristics:
- **Authentication Stage**: Step 2 of 2 (after login, before accessing task cards)
- **Authorization**: User can only see obras they are assigned to via `obra_colaborador` table
- **Visual Design**: Grid of cards with progress bars, status colors, and company icons
- **Business Logic**: Real-time progress calculation based on dates and task completion
- **Navigation Target**: After selection → `/tarefa/cards` (Task Cards page)

---

## 2. PAGE PURPOSE & USER FLOW

### User Journey:
```
[Login Page] 
    ↓ (credentials validated)
[Escolher Obra Page] ← YOU ARE HERE
    ↓ (obra selected)
[Task Cards Page]
    ↓ (work on tasks)
```

### What Happens on This Page:
1. **Display**: Show all obras the logged-in user has access to
2. **Filter**: Allow user to filter by "Unidade Escolar" (school unit) or "Município" (city)
3. **Select**: User clicks on an obra card
4. **Store**: System stores selected obra in session/context
5. **Navigate**: Redirect to Task Cards page with obra context loaded

---

## 3. DATA MODEL & ENTITY STRUCTURE

### Primary Entity: `Obra`

```csharp
// Core fields needed for card display
public class Obra
{
    // Identity
    public int ObrIdObra { get; set; }
    public string ObrDsObra { get; set; }  // Project name/description
    
    // Location
    public int ObrIdMunicipio { get; set; }
    public virtual Municipio Municipio { get; set; }  // For city/state display
    
    // Companies
    public int? ObrIdEmpresaContratante { get; set; }  // Contracting company
    public int? ObrIdEmpresaContratada { get; set; }   // Contracted company
    public virtual Empresa EmpresaContratante { get; set; }
    public virtual Empresa EmpresaContratada { get; set; }
    
    // Dates (critical for progress calculation)
    public DateTime ObrDtInicio { get; set; }          // Start date
    public DateTime? ObrDtPrevisaoFim { get; set; }    // Expected end date
    public DateTime? ObrDtFim { get; set; }            // Actual end date (null if ongoing)
    
    // Relationships
    public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; }
    public virtual ICollection<Etapa> Etapas { get; set; }
}
```

### Related Entity: `ObraColaborador`

```csharp
// Junction table - links users to obras
public class ObraColaborador
{
    public int OcoIdObraColaborador { get; set; }
    public int OcoIdObra { get; set; }
    public int OcoIdColaborador { get; set; }
    public int OcoIdGrupo { get; set; }  // User's role/group in this obra
    
    public virtual Obra Obra { get; set; }
    public virtual Colaborador Colaborador { get; set; }
    public virtual Grupo Grupo { get; set; }  // Contains license type and permissions
}
```

### Related Entity: `Grupo`

```csharp
// User role/group - determines icon and license type
public class Grupo
{
    public int GruIdGrupo { get; set; }
    public string GruNmNome { get; set; }  // "Básica" or "Gratuita"
    public int GruStContratante { get; set; }  // 1 = contratante, 0 = contratada
}
```

### Related Entity: `Municipio`

```csharp
// City information
public class Municipio
{
    public int MunIdMunicipio { get; set; }
    public string MunDsMunicipio { get; set; }  // City name
    public int MunIdUf { get; set; }
    public virtual Uf Uf { get; set; }  // State
}
```

### Related Entity: `Uf`

```csharp
// State information
public class Uf
{
    public int UfeIdUf { get; set; }
    public string UfeDsSigla { get; set; }  // "SP", "RJ", etc.
}
```

---

## 4. CARD ANATOMY - VISUAL & DATA SPECIFICATIONS

### Card Structure (ASCII Mockup):

```
┌─────────────────────────────────────┐
│  [ICON]                             │  ← Company type icon
│                                     │
│  ESCOLA MUNICIPAL JOÃO SILVA        │  ← obra.descricao
│                                     │
│  São Paulo/SP                       │  ← municipio.nome / uf.sigla
│                                     │
│  (Básica)                           │  ← grupo.nome (license type)
│                                     │
│  STATUS                             │
│  ████████░░░░░░░░░░░░ 35%          │  ← Progress bar with percentage
│                                     │
└─────────────────────────────────────┘
```

### Data Fields Required for Each Card:

| Field | Source | Purpose | Example |
|-------|--------|---------|---------|
| **idObra** | `obra.obr_id_obra` | Unique identifier | `42` |
| **descricao** | `obra.obr_ds_obra` | Project name | `"Escola Municipal João Silva"` |
| **cidadeEstado** | `municipio.mun_ds_municipio + "/" + uf.ufe_ds_sigla` | Location | `"São Paulo/SP"` |
| **statusBasicaGratuita** | `grupo.gru_nm_nome` | License type | `"Básica"` or `"Gratuita"` |
| **contratanteContratada** | `grupo.gru_st_contratante` | Company type | `"contratante"` or `"contratada"` |
| **progressoPorcentagem** | Calculated (see below) | Progress % | `35` |
| **classeStatusCss** | Calculated (see below) | Status color | `"bg-verde"`, `"bg-vermelho"`, or `"bg-cinza"` |

### Icon Mapping:

```css
/* Icon based on contratanteContratada field */
.icon-contratante {
    /* Display "T" icon or specific contractor icon */
}

.icon-contratada {
    /* Display "D" icon or specific contracted icon */
}
```

**Business Rule**: 
- If `grupo.gru_st_contratante == 1` → icon class = `"icon-contratante"` (letter "T")
- If `grupo.gru_st_contratante == 0` → icon class = `"icon-contratada"` (letter "D")

---

## 5. BUSINESS LOGIC - PROGRESS & STATUS CALCULATIONS

### 5.1 Progress Percentage Calculation

**Algorithm**:
```csharp
public static int CalculateProgressPercentage(Obra obra)
{
    DateTime startDate = obra.ObrDtInicio;
    DateTime expectedEndDate = obra.ObrDtPrevisaoFim ?? DateTime.MaxValue;
    DateTime currentDate = DateTime.Now;
    
    // Case 1: Current date is after expected end → 100%
    if (currentDate >= expectedEndDate)
    {
        return 100;
    }
    
    // Case 2: Current date is before start → 0%
    if (currentDate < startDate)
    {
        return 0;
    }
    
    // Case 3: In progress → calculate percentage
    double totalDays = expectedEndDate.Subtract(startDate).Days;
    double elapsedDays = currentDate.Subtract(startDate).Days;
    
    int percentage = Convert.ToInt32(Math.Round(100 / totalDays * elapsedDays, 2));
    
    return percentage;
}
```

**Example**:
- Start: January 1, 2026
- Expected End: March 31, 2026 (90 days)
- Current: February 3, 2026 (33 days elapsed)
- Progress: `(33 / 90) * 100 = 36.67%` → rounds to `37%`

### 5.2 Status CSS Class Calculation

**Algorithm**:
```csharp
public static string CalculateStatusCssClass(Obra obra)
{
    int progress = CalculateProgressPercentage(obra);
    
    // If progress is 100% (deadline reached or passed)
    if (progress == 100)
    {
        // Check if there are pending tasks
        bool hasPendingTasks = CheckForPendingTasks(obra);
        
        if (hasPendingTasks)
        {
            return "bg-vermelho";  // RED: Deadline passed with pending tasks
        }
        else
        {
            return "bg-verde";  // GREEN: Deadline reached, all tasks complete
        }
    }
    
    // If progress < 100% (still in progress)
    return "bg-cinza";  // GRAY: Work in progress
}

private static bool CheckForPendingTasks(Obra obra)
{
    // Get all etapas for this obra
    var pendingTaskIds = new List<int>();
    
    foreach (var etapa in obra.Etapas)
    {
        // Group tasks by tar_nr_agrupador (task group number)
        // Get the most recent task in each group
        var latestTasks = etapa.Tarefas
            .GroupBy(t => t.TarNrAgrupador)
            .Select(g => g.OrderByDescending(t => t.TarDtMedicao)
                          .ThenByDescending(t => t.TarDtMedicaoHoraInicial)
                          .First())
            .Where(t => t.TarIdStatus <= 2 || t.TarIdStatus == 4)  // Pending statuses
            .Select(t => t.TarIdTarefa);
        
        pendingTaskIds.AddRange(latestTasks);
    }
    
    return pendingTaskIds.Count > 0;
}
```

**Status Color Legend**:

| Color | CSS Class | Condition | Meaning |
|-------|-----------|-----------|---------|
| 🟢 **GREEN** | `bg-verde` | Progress = 100% AND no pending tasks | Deadline met, all tasks complete |
| 🔴 **RED** | `bg-vermelho` | Progress = 100% AND has pending tasks | Deadline passed, tasks still pending |
| ⚪ **GRAY** | `bg-cinza` | Progress < 100% | Work in progress, deadline not reached |

**Task Status Codes** (for pending check):
- Status ≤ 2: Not started or in progress
- Status = 4: Specific pending state
- Status = 3: Completed (not counted as pending)

---

## 6. INTERACTIVE BEHAVIOR - CLICK & NAVIGATION

### 6.1 Card Click Event

**User Action**: User clicks on any obra card

**Frontend Handler**:
```javascript
// Legacy: controller.escolherObra(obra)
// Modern: POST to /Obra/Selecionar with obra ID
```

### 6.2 Backend Processing

**Endpoint**: `POST /Obra/Selecionar`

**Request Payload**:
```json
{
    "idObra": 42
}
```

**Processing Steps**:

1. **Validate User Session**
   - Verify user is authenticated
   - Get `colaboradorId` from claims/session

2. **Call LoginObra API**
   ```csharp
   var objLogin = new {
       idUsuario = colaboradorId,
       idObra = selectedObraId,
       obra = obraObject,
       user = currentUserObject
   };
   
   // POST to api/login/LoginObra
   ```

3. **LoginObra API Response**
   ```json
   {
       "usuario": { ... },
       "obra": { ... },
       "routes": [
           { "path": "/tarefa/index", "allowed": true },
           { "path": "/tarefa/cards", "allowed": true },
           ...
       ],
       "permissions": [ ... ]
   }
   ```

4. **Permission Check**
   - Verify user has access to `/tarefa/index` route
   - If not found → show error: "Seu usuário não tem permissão. Favor contate o administrador."

5. **Update Session**
   - Store obra context in session
   - Update user claims with obra information
   - Store permissions and routes

6. **Navigate**
   - Redirect to: `/tarefa/cards`

### 6.3 Session Data Stored

After successful selection, store in session:

```csharp
HttpContext.Session.SetInt32("ObraId", selectedObraId);
HttpContext.Session.SetString("ObraDescricao", obra.ObrDsObra);
HttpContext.Session.SetString("ObraLicenca", licenseType);
HttpContext.Session.SetString("UserPermissions", JsonSerializer.Serialize(permissions));
```

---

## 7. HEADER & NAVIGATION ELEMENTS

### 7.1 Header Structure

```
┌────────────────────────────────────────────────────────────┐
│  [LOGO]                    Bem-vindo, Ricardo Freire!  [⚙] │
└────────────────────────────────────────────────────────────┘
```

**Elements**:
1. **Logo** (left): RDO App Piscinas logo
2. **Welcome Message** (center-right): "Bem-vindo, {userName}!"
3. **Settings Icon** (far right): Gear icon for user menu

### 7.2 Page Title

```html
<h2>Selecione uma das unidades escolares abaixo:</h2>
```

**Translation**: "Select one of the school units below:"

### 7.3 Empty State

If user has no obras assigned:

```html
<label>Você deve cadastrar uma unidade escolar para começar a usar o sistema.</label>
```

**Translation**: "You must register a school unit to start using the system."

---

## 8. FILTERING SYSTEM

### 8.1 Filter UI

```
┌─────────────────────────────────────────────────────────┐
│  Filtros:  [Unidade escolar____]  [Município_________] │
└─────────────────────────────────────────────────────────┘
```

**Fields**:
1. **Unidade Escolar** (School Unit): Filters by `obra.descricao`
2. **Município** (City): Filters by `cidadeEstado` (city/state combination)

### 8.2 Filter Logic

**Client-Side Filtering** (real-time as user types):

```javascript
// Filter obras array
filteredObras = obras.filter(obra => {
    let matchesUnidade = true;
    let matchesMunicipio = true;
    
    if (filtroUnidade) {
        matchesUnidade = obra.descricao.toLowerCase().includes(filtroUnidade.toLowerCase());
    }
    
    if (filtroMunicipio) {
        matchesMunicipio = obra.cidadeEstado.toLowerCase().includes(filtroMunicipio.toLowerCase());
    }
    
    return matchesUnidade && matchesMunicipio;
});
```

**Behavior**:
- Case-insensitive
- Partial match (substring search)
- Both filters applied simultaneously (AND logic)
- Real-time update as user types

---

## 9. API ENDPOINTS & DATA FLOW

### 9.1 Get Obras List

**Endpoint**: `POST /api/obra/ObterObras`

**Request**:
```json
{
    "idColaborador": 123
}
```

**Response**:
```json
[
    {
        "idObra": 42,
        "descricao": "Escola Municipal João Silva",
        "cidadeEstado": "São Paulo/SP",
        "statusBasicaGratuita": "Básica",
        "contratanteContratada": "contratante",
        "progressoPorcentagem": 35,
        "classeStatusCss": "bg-cinza",
        "descricaoContratante": "Empresa ABC Ltda",
        "descricaoContratada": "Construtora XYZ",
        "diasDecorridos": 33,
        "dataInicio": "01/01/2026",
        "dataConclusao": "",
        "obraFinalizada": false
    },
    ...
]
```

### 9.2 Select Obra (LoginObra)

**Endpoint**: `POST /api/login/LoginObra`

**Request**:
```json
{
    "idUsuario": 123,
    "idObra": 42,
    "obra": { ... },
    "user": { ... }
}
```

**Response**:
```json
{
    "usuario": {
        "id": 123,
        "nome": "Ricardo Freire",
        "email": "ricardo@example.com",
        "idGrupo": 5
    },
    "obra": {
        "idObra": 42,
        "descricao": "Escola Municipal João Silva",
        "licenca": "Básica"
    },
    "routes": [
        { "path": "/tarefa/index", "allowed": true },
        { "path": "/tarefa/cards", "allowed": true },
        { "path": "/rdo/index", "allowed": true }
    ],
    "permissions": [
        "view_tasks",
        "edit_tasks",
        "create_rdo"
    ]
}
```

---

## 10. IMPLEMENTATION CHECKLIST

### Phase 1: Data Layer ✅
- [x] Obra entity with all required fields
- [x] ObraColaborador junction table
- [x] Grupo entity for roles/licenses
- [x] Municipio and Uf entities for location
- [x] Database relationships configured

### Phase 2: Business Logic
- [ ] Implement `CalculateProgressPercentage()` method
- [ ] Implement `CalculateStatusCssClass()` method
- [ ] Implement `CheckForPendingTasks()` method
- [ ] Create ObraViewModel/DTO with calculated fields

### Phase 3: API Endpoints
- [ ] Create `GET /Obra/Escolher` endpoint
  - Query obras for logged-in user
  - Calculate progress and status for each
  - Return view with obra list
- [ ] Create `POST /Obra/Selecionar` endpoint
  - Validate obra selection
  - Call LoginObra logic
  - Store obra context in session
  - Redirect to task cards

### Phase 4: Frontend - View
- [ ] Create Escolher.cshtml view
- [ ] Implement header with logo and welcome message
- [ ] Implement filter inputs (Unidade Escolar, Município)
- [ ] Implement card grid layout
- [ ] Implement card template with all fields
- [ ] Implement progress bar visualization
- [ ] Implement status color classes
- [ ] Implement icon mapping (contratante/contratada)

### Phase 5: Frontend - Interactivity
- [ ] Implement client-side filtering
- [ ] Implement card click handler
- [ ] Implement form submission to Selecionar endpoint
- [ ] Implement loading states
- [ ] Implement error handling

### Phase 6: Styling
- [ ] Create escolher.css stylesheet
- [ ] Implement card styles
- [ ] Implement progress bar styles
- [ ] Implement status color classes:
  - `bg-verde` (green)
  - `bg-vermelho` (red)
  - `bg-cinza` (gray)
- [ ] Implement responsive grid layout
- [ ] Implement hover effects

### Phase 7: Testing
- [ ] Test with user having 0 obras (empty state)
- [ ] Test with user having 1 obra (auto-select?)
- [ ] Test with user having multiple obras
- [ ] Test progress calculation edge cases:
  - Before start date
  - After end date
  - Exactly on end date
- [ ] Test status color logic:
  - Green: 100% progress, no pending tasks
  - Red: 100% progress, has pending tasks
  - Gray: < 100% progress
- [ ] Test filtering:
  - By unidade escolar
  - By município
  - Both filters together
  - Clear filters
- [ ] Test navigation to task cards
- [ ] Test permission validation

### Phase 8: Integration
- [ ] Integrate with authentication flow
- [ ] Integrate with session management
- [ ] Integrate with LoginObra API
- [ ] Integrate with task cards page
- [ ] Test full user journey: Login → Escolher → Task Cards

---

## 📊 SUMMARY STATISTICS

**Total Data Fields**: 7 per card  
**Calculated Fields**: 2 (progressoPorcentagem, classeStatusCss)  
**Database Tables Involved**: 6 (obra, obra_colaborador, grupo, municipio, uf, etapa)  
**API Endpoints**: 2 (ObterObras, LoginObra)  
**Status Colors**: 3 (green, red, gray)  
**Filter Fields**: 2 (unidade escolar, município)  

---

## 🎯 KEY TAKEAWAYS

1. **Progress is date-based**: Calculated from start date, expected end date, and current date
2. **Status is task-based**: Green/red determined by pending tasks when deadline reached
3. **Icon is role-based**: Contratante (T) vs Contratada (D) from grupo table
4. **Filtering is client-side**: Real-time substring matching on description and location
5. **Selection triggers LoginObra**: Full context loading with permissions and routes
6. **Navigation target**: Always `/tarefa/cards` after successful selection

---

**Document Status**: ✅ Complete  
**Next Step**: Implement Phase 2 (Business Logic) from checklist  
**Estimated Implementation Time**: 8-12 hours for full implementation

