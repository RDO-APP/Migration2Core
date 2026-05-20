# OBRA CARD DATA FIX - REQUIREMENTS SPECIFICATION

## Status: 🔧 IN PROGRESS - FIXING CARD DATA ISSUES

**Date**: 28 Dec 2025  
**Priority**: HIGH - User reported multiple data issues  
**Context**: User identified that obra cards are showing incorrect/hardcoded data instead of real database values

---

## 🚨 USER REPORTED ISSUES

### **Issue 1: StatusBasicaGratuita (Tipo de Assinatura)**
- **Current**: Shows hardcoded values or incorrect data
- **Expected**: Should show real group name from database (BÁSICA, GRATUITA, DIRETOR, etc.)
- **Source**: `grupo.gru_nm_nome` field from Gilberto's code

### **Issue 2: ContratanteContratada (Perfil de Acesso)**
- **Current**: Not showing "Diretor Contratada" as expected
- **Expected**: Should show user's profile based on group status
- **Source**: `grupo.gru_st_contratante == 1 ? "contratante" : "contratada"` from Gilberto's code

### **Issue 3: Progress Bar Colors**
- **Current**: All bars showing same color
- **Expected**: Different colors based on status (verde/vermelho/cinza)
- **Source**: `ClasseStatusCss(obra)` method from Gilberto's code

### **Issue 4: Progress Percentage**
- **Current**: May be showing hardcoded 100%
- **Expected**: Real calculation based on obra dates
- **Source**: `ProgressoPorcentagem(obra)` method from Gilberto's code

---

## 📋 ANALYSIS OF GILBERTO'S IMPLEMENTATION

### **Exact Field Mapping from ObraModel.cs:**

```csharp
// Line 87-94 in Gilberto's ObraModel.cs
grupo grupo = obr.obra_colaborador.FirstOrDefault(x => x.oco_id_colaborador == idColaborador).grupo;
Lista.Add(new ObraViewModel
{
    // ... other fields ...
    ContratanteContratada = grupo == null ? "" : grupo.gru_st_contratante == 1 ? "contratante" : "contratada",
    StatusBasicaGratuita = grupo == null ? "" : grupo.gru_nm_nome,
    ClasseStatusCss = ClasseStatusCss(obr),
    ProgressoPorcentagem = ProgressoPorcentagem(obr)
});
```

### **Progress Calculation (Lines 119-135):**
```csharp
public static int ProgressoPorcentagem(obra obra)
{
    DateTime inicio = obra.obr_dt_inicio;
    DateTime fim = (DateTime)obra.obr_dt_previsao_fim;
    DateTime atual = DateTime.Now;

    double total = fim.Subtract(inicio).Days;
    double decorrido = atual.Subtract(inicio).Days;

    if (atual >= fim) return 100;
    else if (atual < inicio) return 0;

    int result = Convert.ToInt32(Math.Round(100 / total * decorrido, 2));
    return result;
}
```

### **CSS Class Determination (Lines 136-152):**
```csharp
private static string ClasseStatusCss(obra obra)
{
    if (ProgressoPorcentagem(obra) == 100)
    {
        // Complex logic to check for pending tasks
        List<int> idsTarefas = new List<int>();
        foreach (etapa et in obra.etapa)
        {
            // Check for pending tasks logic...
        }
        
        bool existeTarefaPendente = idsTarefas.Count() > 0;
        if (existeTarefaPendente) return "bg-vermelho";
        return "bg-verde";
    }
    return "bg-cinza";
}
```

---

## ✅ CURRENT IMPLEMENTATION STATUS

### **What's Already Implemented:**
1. ✅ Navigation properties for ObraColaborador and Grupo
2. ✅ Include statements for related entities
3. ✅ Basic calculation methods
4. ✅ CSS classes for different colors

### **What Needs Fixing:**
1. ❌ StatusBasicaGratuita may not be showing correct group names
2. ❌ ContratanteContratada logic needs verification
3. ❌ Progress bar colors may not be working correctly
4. ❌ Progress percentage calculation needs verification

---

## 🎯 ACCEPTANCE CRITERIA

### **AC1: StatusBasicaGratuita Shows Real Group Names**
- **Given** a user views the obra selection page
- **When** they see the obra cards
- **Then** each card should show the real group name (e.g., "BÁSICA", "GRATUITA", "DIRETOR")
- **And** no hardcoded values should appear

### **AC2: ContratanteContratada Shows Correct Profile**
- **Given** a user with "Diretor Contratada" profile
- **When** they view obra cards
- **Then** the cards should show "Diretor Contratada" or similar profile indication
- **And** the profile should be based on the user's group status

### **AC3: Progress Bars Have Different Colors**
- **Given** obras with different statuses
- **When** user views the cards
- **Then** progress bars should show:
  - **Green (bg-verde)**: Completed obras without pending tasks
  - **Red (bg-vermelho)**: Completed obras with pending tasks  
  - **Gray (bg-cinza)**: Obras in progress

### **AC4: Progress Percentage is Calculated Correctly**
- **Given** an obra with start and end dates
- **When** user views the card
- **Then** the percentage should be calculated based on:
  - **0%**: If current date is before start date
  - **100%**: If current date is after end date
  - **Calculated %**: Based on days elapsed vs total days

---

## 🔧 IMPLEMENTATION TASKS

### **Task 1: Verify Database Relationships**
- [ ] Confirm ObraColaborador → Grupo relationship is working
- [ ] Verify that Grupo.Nome contains expected values
- [ ] Check that Grupo.StatusContratante field exists and has correct values

### **Task 2: Fix StatusBasicaGratuita Logic**
- [ ] Ensure query correctly gets group name for current user
- [ ] Verify LINQ query is returning actual group names
- [ ] Test with different user profiles

### **Task 3: Fix ContratanteContratada Logic**
- [ ] Verify StatusContratante field mapping (1 = contratante, 0 = contratada)
- [ ] Ensure logic matches Gilberto's exact implementation
- [ ] Test with different user types

### **Task 4: Implement Complete ClasseStatusCss Logic**
- [ ] Add task checking logic for completed obras
- [ ] Implement proper color determination
- [ ] Ensure CSS classes are applied correctly in HTML

### **Task 5: Verify Progress Calculation**
- [ ] Test with different date scenarios
- [ ] Ensure null date handling works correctly
- [ ] Verify percentage calculation matches Gilberto's logic

---

## 🧪 TESTING STRATEGY

### **Manual Testing:**
1. **Login** with test user (CPF: 567.065.455-20)
2. **Navigate** to `/Obra/Escolher`
3. **Verify** each card shows:
   - Real group name in parentheses (not hardcoded)
   - Correct user profile indication
   - Different progress bar colors
   - Calculated percentages based on dates

### **Database Verification:**
1. **Query** obra_colaborador table to verify relationships
2. **Check** grupo table for available group names
3. **Verify** StatusContratante values (1/0)
4. **Confirm** obra dates for percentage calculations

---

## 📊 SUCCESS METRICS

### **Before (Current Issues):**
- ❌ StatusBasicaGratuita: Hardcoded or incorrect values
- ❌ ContratanteContratada: Not showing expected profile
- ❌ Progress bars: All same color
- ❌ Percentages: May be hardcoded

### **After (Expected Results):**
- ✅ StatusBasicaGratuita: Real group names from database
- ✅ ContratanteContratada: Correct profile based on user's group
- ✅ Progress bars: Different colors (green/red/gray)
- ✅ Percentages: Calculated based on real dates

---

## 🔗 RELATED FILES

### **Files to Modify:**
- `RDO-NET8-Migration/RdoApp.Core/Controllers/ObraController.cs`
- `RDO-NET8-Migration/RdoApp.Core/Views/Obra/Escolher.cshtml`

### **Files to Reference:**
- `RDO-Production-Gilberto/rdoappProject/Api/Models/ObraModel.cs`
- `RDO-NET8-Migration/RdoApp.Core/Models/Entities/Grupo.cs`
- `RDO-NET8-Migration/RdoApp.Core/Models/Entities/ObraColaborador.cs`

---

## 🚀 NEXT STEPS

1. **Analyze current query** in ObraController.cs
2. **Compare with Gilberto's exact logic** in ObraModel.cs
3. **Fix any discrepancies** in field mapping
4. **Test with F5** to verify corrections
5. **Document results** for user verification

---

## 💡 NOTES

- **Critical**: Must match Gilberto's exact logic, not create new interpretations
- **Database**: Use homolog database for testing
- **User Testing**: User will verify with F5 in Visual Studio
- **Approach**: "COMPILAR PRIMEIRO, FUNCIONALIDADE DEPOIS"