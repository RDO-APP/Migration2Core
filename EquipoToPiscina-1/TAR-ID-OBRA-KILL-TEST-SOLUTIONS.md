# TAR_ID_OBRA KILL TEST - Solutions Analysis

## Current Status: KILL TEST IMPLEMENTED ✅

The KILL TEST has been successfully implemented in `EtapaService.cs` line 59:
```csharp
// KILL TEST: Remove .Include entirely to test if tar_id_obra column mapping is the issue
var etapas = await _context.Etapas
    .Where(e => e.ObraId == obraId)
    .OrderBy(e => e.Id)
    .ToListAsync();
```

**Original problematic code:**
```csharp
var etapas = await _context.Etapas
    .Include(e => e.Tarefas)  // ← This was causing: Unknown column 't.tar_id_obra' in 'field list'
    .Where(e => e.ObraId == obraId)
    .OrderBy(e => e.Id)
    .ToListAsync();
```

## Root Cause Analysis

### ✅ CONFIRMED: Column Exists
- `tar_id_obra` column EXISTS in production database
- Entity mapping is CORRECT: `[Column("tar_id_obra")] public int IdObra`
- Fluent API mapping is CORRECT: `.HasColumnName("tar_id_obra")`

### ❌ PROBLEM: EF Core Include Query Generation
- When `.Include(e => e.Tarefas)` executes, EF Core generates SQL that references `t.tar_id_obra`
- MySQL throws: `Unknown column 't.tar_id_obra' in 'field list'`
- This suggests EF Core is generating incorrect SQL or there's a case sensitivity issue

## KILL TEST Expected Results

### ✅ SUCCESS SCENARIO: 4 Etapas Appear
- **Meaning**: tar_id_obra column mapping is the ONLY issue
- **Next Step**: Implement one of the 3 solutions below

### ❌ FAILURE SCENARIO: Still Empty UI
- **Meaning**: There's another issue beyond tar_id_obra
- **Next Step**: Investigate other potential causes (Session, obraId, etc.)

## Solution Options (If KILL TEST Succeeds)

### Solution A: Fix Entity Framework Relationship Mapping
```csharp
// In TarefaConfiguration.cs - Add explicit foreign key mapping
builder.HasOne(t => t.Etapa)
    .WithMany(e => e.Tarefas)
    .HasForeignKey(t => t.EtapaId)  // Use EtapaId, not IdObra
    .OnDelete(DeleteBehavior.Restrict);

// Remove or fix the IdObra mapping if it's causing conflicts
// The issue might be that IdObra should not be used for Etapa relationship
```

### Solution B: Load Tarefas Separately (Recommended)
```csharp
public async Task<List<EtapaViewModel>> ObterEtapasViewModelAsync(int obraId, int colaboradorId)
{
    // Load etapas first
    var etapas = await _context.Etapas
        .Where(e => e.ObraId == obraId)
        .OrderBy(e => e.Id)
        .ToListAsync();

    // Load tarefas separately for each etapa
    foreach (var etapa in etapas)
    {
        etapa.Tarefas = await _context.Tarefas
            .Include(t => t.Status)
            .Where(t => t.EtapaId == etapa.Id)
            .ToListAsync();
    }

    // Continue with existing mapping logic...
}
```

### Solution C: Use Raw SQL Query
```csharp
public async Task<List<EtapaViewModel>> ObterEtapasViewModelAsync(int obraId, int colaboradorId)
{
    // Use raw SQL to avoid EF Core query generation issues
    var etapasWithTarefas = await _context.Etapas
        .FromSqlRaw(@"
            SELECT e.*, t.*
            FROM etapa e
            LEFT JOIN tarefa t ON t.tar_id_etapa = e.eta_id_etapa
            WHERE e.eta_id_obra = {0}
            ORDER BY e.eta_id_etapa", obraId)
        .Include(e => e.Tarefas)
        .ToListAsync();

    // Continue with existing mapping logic...
}
```

## Implementation Priority

1. **FIRST**: Verify KILL TEST results in browser
2. **IF SUCCESS**: Implement Solution B (separate loading) - safest approach
3. **IF NEEDED**: Investigate Solution A (fix relationship mapping)
4. **LAST RESORT**: Solution C (raw SQL)

## Files Modified for KILL TEST

- ✅ `RDO-NET8-Migration/RdoApp.Core/Services/Implementations/EtapaService.cs` (line 59)
- ✅ Application compiles successfully
- ✅ Application runs on http://localhost:5031

## Test Instructions

1. Open browser to: http://localhost:5031/Auth/Login
2. Login with: ricardo / 123456
3. Select any obra
4. Check if 4 etapas (880, 881, 883, 884) appear in the UI
5. Report results to determine next steps

## Expected Debug Output

If KILL TEST works, you should see in console:
```
Etapas encontradas no banco: 4
  - Etapa 880: [Description] com 0 tarefas
  - Etapa 881: [Description] com 0 tarefas
  - Etapa 883: [Description] com 0 tarefas
  - Etapa 884: [Description] com 0 tarefas
```

And the UI should show 4 accordion sections (even if empty of tasks).