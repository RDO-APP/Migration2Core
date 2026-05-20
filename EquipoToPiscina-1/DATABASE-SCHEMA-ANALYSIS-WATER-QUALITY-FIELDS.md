# Database Schema Analysis - Water Quality Fields

## CRITICAL FINDINGS: Field Mapping Analysis Complete

### TAREFA Entity Water Quality Fields (8 fields)
```csharp
// Integer fields (dropdown selections 0-5/0-6)
[Column("tar_nr_nivel_cloro")]     public int? NivelCloro { get; set; }
[Column("tar_nr_ph")]              public int? Ph { get; set; }
[Column("tar_nr_alcalinidade")]    public int? Alcalinidade { get; set; }

// Boolean fields (checkbox selections)
[Column("tar_nr_limpidez")]        public bool? Limpidez { get; set; }
[Column("tar_nr_superficie")]      public bool? Superficie { get; set; }
[Column("tar_nr_fundo")]           public bool? Fundo { get; set; }
[Column("tar_nr_nivel_detritos")]  public bool? NivelDetritos { get; set; }
[Column("tar_nr_nivel_proliferacao")] public bool? NivelProliferacao { get; set; }
```

### LAUDO Entity Water Quality Fields (9 fields)
```csharp
// Integer fields (dropdown selections 0-5/0-6)
[Column("lau_tp_nivel_cloro")]     public int? NivelCloro { get; set; }
[Column("lau_tp_ph")]              public int? Ph { get; set; }
[Column("lau_tp_alcalinidade")]    public int? Alcalinidade { get; set; }

// Boolean fields (checkbox selections)
[Column("lau_tp_limpidez")]        public bool? Limpidez { get; set; }
[Column("lau_tp_superficie")]      public bool? Superficie { get; set; }
[Column("lau_tp_fundo")]           public bool? Fundo { get; set; }
[Column("lau_tp_nivel_cloro_2")]   public bool? NivelCloro2 { get; set; }
[Column("lau_tp_nivel_bacterias")] public bool? NivelBacterias { get; set; }
[Column("lau_tp_nivel_proliferacao")] public bool? NivelProliferacao { get; set; }
```

## FIELD MAPPING CORRECTIONS NEEDED

### 1. NovaMedicaoViewModel Field Name Issues
- **WRONG**: `NivelPH` → **CORRECT**: `Ph` (matches entity property)
- **WRONG**: `NivelAlcalinidade` → **CORRECT**: `Alcalinidade` (matches entity property)
- **WRONG**: `Detritos` → **CORRECT**: `NivelDetritos` (matches entity property)
- **WRONG**: `Proliferacao` → **CORRECT**: `NivelProliferacao` (matches entity property)

### 2. Data Type Validation
- **NivelCloro**: `int?` (0-5 range) ✓ CORRECT
- **Ph**: `int?` (0-6 range) ✓ CORRECT  
- **Alcalinidade**: `int?` (0-6 range) ✓ CORRECT
- **Boolean fields**: `bool?` ✓ CORRECT (nullable in database)

### 3. Dropdown Value Mappings (Gilberto Standard)
**Cloro (0-5):**
- 0: "0 ppm"
- 1: "0,5 < 1,0"
- 2: "1,5 < 2,0"
- 3: "2,5 < 3,0"
- 4: "> 3,0"

**PH (0-6):**
- 0: "< 7.0"
- 1: "7.0 < 7.2"
- 2: "7.2 < 7.4"
- 3: "7.4 < 7.6"
- 4: "7.6 < 7.8"
- 5: "> 7.8"

**Alcalinidade (0-6):**
- 0: "< 70"
- 1: "70 < 80"
- 2: "90 < 100"
- 3: "110 < 120"
- 4: "130 > 140"
- 5: "> 140"

## RELATIONSHIP ANALYSIS

### Nova Medição Workflow:
1. **Primary Target**: TAREFA entity (tar_* fields)
2. **Secondary Target**: LAUDO entity (lau_* fields) - for report generation
3. **Key Relationship**: Tarefa → Etapa → Obra → Laudo

### Database Column Prefixes:
- **TAREFA**: `tar_nr_*` (number fields) and `tar_tp_*` (type fields)
- **LAUDO**: `lau_tp_*` (type fields only)

## COMPILATION FIX PRIORITY:
1. ✅ **CRITICAL**: Fix NovaMedicaoViewModel field names
2. ✅ **CRITICAL**: Update TarefaController.cs SalvarMedicao method
3. ✅ **CRITICAL**: Verify _NovaMedicaoModal.cshtml field bindings
4. ✅ **CRITICAL**: Test compilation and field mapping accuracy

## NEXT STEPS:
1. Apply field name corrections to NovaMedicaoViewModel
2. Update controller method parameter mappings
3. Verify modal form field bindings match corrected names
4. Test Nova Medição workflow end-to-end