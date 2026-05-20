# STRATEGY 2: OBRA CARDS IMPLEMENTATION PLAN

**Date**: February 4, 2026  
**Scope**: Fix obra cards area (filters + enhanced cards)  
**Status**: PLAN READY - NO CODE CHANGES YET

---

## OVERVIEW

This strategy fixes **2 critical obra cards issues**:
1. ❌ **Filters completely missing** - Need to add filter section
2. ❌ **Cards oversimplified** - Need to add progress bars, status colors, municipality, legend

**Estimated Time**: 2-3 hours  
**Risk Level**: MEDIUM (requires backend changes + frontend logic)

---

## ISSUE #4: FILTERS COMPLETELY MISSING

### Root Cause:
Filters were never migrated from legacy AngularJS implementation.

### Legacy Filter Structure:
```html
<div class="container text-center">
    <div class="row">
        <!-- Label -->
        <div class="col">
            <label class="control-label filtro">Filtros</label>
        </div>

        <!-- Filter 1: Unidade Escolar -->
        <div class="col-md-3 col-md-offset-3">
            <input class="form-control" 
                   type="text" 
                   placeholder="Unidade escolar" 
                   autofocus 
                   ng-model="controller.filtroUnidade"/>
        </div>
        
        <!-- Filter 2: Município -->
        <div class="col-md-3">
            <input class="form-control" 
                   type="text" 
                   placeholder="Município" 
                   ng-model="controller.filtroMunicipio"/>
        </div>
    </div>
</div>
```

### Legacy Filter Logic:
```html
<div class="item" ng-repeat="obra in controller.obras | filter:{ 
    descricao: controller.filtroUnidade, 
    cidadeEstado: controller.filtroMunicipio 
}">
```

**How it works**:
- AngularJS `filter` pipe filters array **client-side**
- Real-time filtering as user types
- Filters by partial match (case-insensitive)

### Solution Options:

#### Option A: Client-Side Filtering (RECOMMENDED for MVP)
**Pros**:
- Matches legacy behavior exactly
- Fast (no server round-trip)
- Simple implementation
- Works with current data

**Cons**:
- Not scalable for large datasets (1000+ obras)
- All data loaded upfront

**Implementation**:
1. Add filter HTML
2. Add JavaScript to filter cards on keyup
3. Show/hide cards based on filter match

#### Option B: Server-Side Filtering
**Pros**:
- Scalable for large datasets
- Reduces initial page load
- Better for production

**Cons**:
- Requires API endpoint
- More complex (AJAX + JSON)
- Different from legacy behavior

**RECOMMENDATION**: Start with Option A (client-side) for MVP, migrate to Option B later if needed.

---

## ISSUE #5: CARDS OVERSIMPLIFIED

### Root Cause:
Cards were simplified during initial migration, missing critical visual information.

### Missing Data Fields:

| Field | Legacy | Current | Purpose |
|-------|--------|---------|---------|
| `contratanteContratada` | ✅ | ❌ | Dynamic icon type |
| `descricao` | ✅ | ✅ (as NomeObra) | Obra name |
| `cidadeEstado` | ✅ | ❌ | Municipality + State |
| `statusBasicaGratuita` | ✅ | ❌ | Status text (Básica/Gratuita) |
| `progressoPorcentagem` | ✅ | ❌ | Progress percentage (0-100) |
| `classeStatusCss` | ✅ | ❌ | Status color class |

### Progress Calculation Logic:
**Question for user**: How is progress calculated in legacy?
- Based on completed tasks vs total tasks?
- Based on deadline vs current date?
- Manual field in database?

**Assumption**: Progress = (Completed Tasks / Total Tasks) * 100

### Status Color Logic:
**Question for user**: How is status color determined?
- Green (bg-verde): Progress >= 100% OR deadline met?
- Red (bg-vermelho): Deadline exceeded?
- Gray (bg-cinza): In progress (default)?

**Assumption**:
- Green: Progress >= 100%
- Red: Progress < 100% AND deadline exceeded
- Gray: Progress < 100% AND deadline not exceeded

---

## IMPLEMENTATION STEPS

### Phase 1: Add Filters (30 minutes)

#### Step 1.1: Add Filter HTML
```razor
@* File: Views/Obra/Escolher.cshtml *@
@* Location: Inside .conteudo, before obra cards *@

<div class="container text-center">
    <div class="row">
        <div class="col">
            <label class="control-label filtro">Filtros</label>
        </div>

        <div class="col-md-3 offset-md-3">
            <input class="form-control" 
                   type="text" 
                   id="filtroUnidade"
                   placeholder="Unidade escolar" 
                   autofocus />
        </div>
        
        <div class="col-md-3">
            <input class="form-control" 
                   type="text" 
                   id="filtroMunicipio"
                   placeholder="Município" />
        </div>
    </div>
</div>

<h2>Selecione uma das unidades escolares abaixo:</h2>
```

#### Step 1.2: Add Filter JavaScript
```razor
@* File: Views/Obra/Escolher.cshtml *@
@* Location: At bottom of file, before closing tag *@

@section Scripts {
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const filtroUnidade = document.getElementById('filtroUnidade');
        const filtroMunicipio = document.getElementById('filtroMunicipio');
        const cards = document.querySelectorAll('.lista-obras .item');

        function filterCards() {
            const unidadeValue = filtroUnidade.value.toLowerCase();
            const municipioValue = filtroMunicipio.value.toLowerCase();

            cards.forEach(card => {
                const nomeObra = card.querySelector('h5').textContent.toLowerCase();
                const municipio = card.querySelector('p').textContent.toLowerCase();

                const matchUnidade = nomeObra.includes(unidadeValue);
                const matchMunicipio = municipio.includes(municipioValue);

                if (matchUnidade && matchMunicipio) {
                    card.style.display = '';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        filtroUnidade.addEventListener('keyup', filterCards);
        filtroMunicipio.addEventListener('keyup', filterCards);
    });
</script>
}
```

#### Step 1.3: Test Filters
```powershell
# Refresh browser
# Type in "Unidade escolar" filter → cards should filter
# Type in "Município" filter → cards should filter further
# Clear filters → all cards should appear
```

---

### Phase 2: Enhance Controller (45 minutes)

#### Step 2.1: Update ObraController.Escolher()
```csharp
// File: Controllers/ObraController.cs
// Method: Escolher()

public async Task<IActionResult> Escolher()
{
    var colaboradorId = HttpContext.Session.GetInt32("ColaboradorId");
    
    if (!colaboradorId.HasValue)
    {
        return RedirectToAction("Login", "Account");
    }

    // Get obras with enhanced data
    var obras = await _context.Obras
        .Where(o => o.ObrStAtivo == true)
        .Select(o => new
        {
            IdObra = o.ObrIdObra,
            NomeObra = o.ObrDsObra,
            
            // ADD: Municipality + State
            CidadeEstado = (o.ObrDsCidade ?? "") + 
                          (string.IsNullOrEmpty(o.ObrDsEstado) ? "" : " - " + o.ObrDsEstado),
            
            // ADD: Status text (TODO: Get from database or calculate)
            StatusBasicaGratuita = "Básica",  // Placeholder
            
            // ADD: Icon type (TODO: Get from database)
            ContratanteContratada = "contratante",  // Placeholder
            
            // ADD: Progress calculation (TODO: Calculate from tasks)
            ProgressoPorcentagem = 0,  // Placeholder - will calculate below
            
            // ADD: Status color class (TODO: Calculate from deadline)
            ClasseStatusCss = "bg-cinza",  // Placeholder - will calculate below
            
            // Need these for calculations
            DataInicio = o.ObrDtInicio,
            DataTermino = o.ObrDtTermino,
            TotalTarefas = o.Tarefas.Count(),
            TarefasConcluidas = o.Tarefas.Count(t => t.TarStConcluida == true)
        })
        .ToListAsync();

    // Calculate progress and status for each obra
    var obrasEnhanced = obras.Select(o => new
    {
        o.IdObra,
        o.NomeObra,
        o.CidadeEstado,
        o.StatusBasicaGratuita,
        o.ContratanteContratada,
        
        // Calculate progress percentage
        ProgressoPorcentagem = o.TotalTarefas > 0 
            ? (int)((double)o.TarefasConcluidas / o.TotalTarefas * 100) 
            : 0,
        
        // Calculate status color class
        ClasseStatusCss = CalcularStatusCss(
            o.TotalTarefas > 0 ? (int)((double)o.TarefasConcluidas / o.TotalTarefas * 100) : 0,
            o.DataTermino
        )
    }).ToList();

    ViewData["NomeColaborador"] = User.Identity?.Name ?? "Usuário";
    ViewData["ColaboradorId"] = colaboradorId.Value;

    return View(obrasEnhanced);
}

// Helper method to calculate status CSS class
private string CalcularStatusCss(int progressoPorcentagem, DateTime? dataTermino)
{
    // Green: 100% complete
    if (progressoPorcentagem >= 100)
    {
        return "bg-verde";
    }
    
    // Red: Deadline exceeded
    if (dataTermino.HasValue && DateTime.Now > dataTermino.Value)
    {
        return "bg-vermelho";
    }
    
    // Gray: In progress
    return "bg-cinza";
}
```

#### Step 2.2: Test Enhanced Data
```powershell
# Rebuild project
dotnet build

# Run and check browser console
# Verify cards show municipality, progress, etc.
```

---

### Phase 3: Update Card HTML (30 minutes)

#### Step 3.1: Update Card Structure
```razor
@* File: Views/Obra/Escolher.cshtml *@
@* Replace current card HTML with enhanced version *@

@if (Model != null && Model.Any())
{
    <div class="lista-obras">
        @foreach (var obra in Model)
        {
            <div class="item">
                <form asp-action="Selecionar" asp-controller="Obra" method="post">
                    @Html.AntiForgeryToken()
                    <input type="hidden" name="idObra" value="@obra.IdObra" />
                    
                    <button type="submit" class="btn change-background">
                        <!-- Dynamic Icon -->
                        <i class="icon-@obra.ContratanteContratada"></i>
                        
                        <!-- Obra Name -->
                        <h5>@obra.NomeObra</h5>
                        
                        <!-- Municipality + State -->
                        <p>@obra.CidadeEstado</p>
                        
                        <!-- Status Text -->
                        <p>(@obra.StatusBasicaGratuita)</p>

                        <!-- Progress Bar -->
                        <small>STATUS</small>
                        <div class="progress progress-line-info @obra.ClasseStatusCss">
                            <div class="progress-bar progress-bar-info" 
                                 role="progressbar"
                                 aria-valuenow="@obra.ProgressoPorcentagem" 
                                 aria-valuemin="0" 
                                 aria-valuemax="100"
                                 style="width: @(100 - obra.ProgressoPorcentagem)%;">
                                <span class="branco">@obra.ProgressoPorcentagem%</span>
                            </div>
                            <span class="azul">@obra.ProgressoPorcentagem%</span>
                        </div>
                    </button>
                </form>
            </div>
        }
    </div>
}
else
{
    <div class="alert alert-warning text-center">
        <strong>Nenhuma unidade escolar encontrada.</strong><br />
        Você não está associado a nenhuma unidade escolar.
    </div>
}
```

#### Step 3.2: Test Enhanced Cards
```powershell
# Refresh browser
# Verify cards show:
#   - Dynamic icon
#   - Obra name
#   - Municipality
#   - Status text
#   - Progress bar with percentage
#   - Color-coded status (green/red/gray)
```

---

### Phase 4: Add Legend (15 minutes)

#### Step 4.1: Add Legend HTML
```razor
@* File: Views/Obra/Escolher.cshtml *@
@* Location: After lista-obras div, before closing .conteudo *@

@if (Model != null && Model.Any())
{
    <div class="col-xs-12 no-padding area-legenda">
        <div class="">
            <label>BARRA DE PROGRESSO DA UNIDADE ESCOLAR:</label>
            
            <div class="legenda">
                <i class="status bg-verde"></i>
                <small>UNIDADE ESCOLAR COM PRAZO ESTIMADO ATINGIDO</small>
            </div>
            
            <div class="legenda">
                <i class="status bg-vermelho"></i>
                <small>UNIDADE ESCOLAR COM PRAZO ESTIMADO ULTRAPASSADO</small>
            </div>
            
            <div class="legenda">
                <i class="status bg-cinza"></i>
                <small>UNIDADE ESCOLAR EM ANDAMENTO</small>
            </div>
        </div>
    </div>
}
```

#### Step 4.2: Add Legend CSS (if missing)
```css
/* File: wwwroot/css/escolher.css */
/* Add if not present */

.area-legenda {
    margin-top: 20px;
    padding: 20px;
    background: #fff;
    border-radius: 5px;
}

.area-legenda label {
    font-family: 'sf-bd';
    font-size: 14px;
    color: #28496F;
    text-transform: uppercase;
    margin-bottom: 10px;
    display: block;
}

.legenda {
    display: flex;
    align-items: center;
    margin-bottom: 10px;
}

.legenda i.status {
    width: 20px;
    height: 20px;
    border-radius: 3px;
    margin-right: 10px;
}

.legenda small {
    font-family: 'sf-md';
    font-size: 12px;
    color: #666;
}

.bg-verde {
    background-color: #4CAF50 !important;
}

.bg-vermelho {
    background-color: #F44336 !important;
}

.bg-cinza {
    background-color: #9E9E9E !important;
}
```

#### Step 4.3: Test Legend
```powershell
# Refresh browser
# Verify legend appears at bottom
# Verify 3 color indicators with labels
```

---

### Phase 5: Final Integration (15 minutes)

#### Step 5.1: Update Filter JavaScript for Enhanced Cards
```javascript
// Update filterCards() function to work with new card structure

function filterCards() {
    const unidadeValue = filtroUnidade.value.toLowerCase();
    const municipioValue = filtroMunicipio.value.toLowerCase();

    cards.forEach(card => {
        // Get obra name from h5
        const nomeObra = card.querySelector('h5').textContent.toLowerCase();
        
        // Get municipality from first p tag (not status text)
        const paragraphs = card.querySelectorAll('p');
        const municipio = paragraphs.length > 0 
            ? paragraphs[0].textContent.toLowerCase() 
            : '';

        const matchUnidade = nomeObra.includes(unidadeValue);
        const matchMunicipio = municipio.includes(municipioValue);

        if (matchUnidade && matchMunicipio) {
            card.style.display = '';
        } else {
            card.style.display = 'none';
        }
    });
}
```

#### Step 5.2: Final Verification
```powershell
# Test complete flow:
# 1. Login
# 2. Escolher page loads
# 3. Filters visible and working
# 4. Cards show all data (name, municipality, status, progress)
# 5. Progress bars color-coded correctly
# 6. Legend visible at bottom
# 7. Click card → selects obra
```

---

## FILES TO MODIFY

### File 1: ObraController.cs
**Path**: `RDO-CleanMigration-2026/RdoApp.Core/Controllers/ObraController.cs`  
**Method**: `Escolher()`  
**Change**: Add enhanced data fields + progress calculation  
**Lines**: ~30-80

### File 2: Escolher.cshtml
**Path**: `RDO-CleanMigration-2026/RdoApp.Core/Views/Obra/Escolher.cshtml`  
**Changes**:
1. Add filter HTML (top)
2. Update card HTML (middle)
3. Add legend HTML (bottom)
4. Add filter JavaScript (bottom)  
**Lines**: Entire file

### File 3: escolher.css (optional)
**Path**: `RDO-CleanMigration-2026/RdoApp.Core/wwwroot/css/escolher.css`  
**Change**: Add legend CSS (if missing)  
**Lines**: Bottom of file

---

## ROLLBACK PLAN

### If Filters Don't Work:
1. Check JavaScript console for errors
2. Verify filter input IDs match JavaScript selectors
3. Test with simple console.log() statements
4. Fallback: Remove filters, keep enhanced cards

### If Enhanced Cards Break:
1. Check controller returns correct data
2. Verify Razor syntax in view
3. Check browser console for errors
4. Fallback: Revert to simple cards, keep filters

### If Progress Calculation Wrong:
1. Check database has Tarefas relationship
2. Verify TarStConcluida field exists
3. Add debug logging to controller
4. Fallback: Use placeholder progress (0%)

### If Everything Breaks:
```bash
# Revert all changes
git checkout HEAD -- Controllers/ObraController.cs
git checkout HEAD -- Views/Obra/Escolher.cshtml
git checkout HEAD -- wwwroot/css/escolher.css

# Rebuild
dotnet build
```

---

## TESTING CHECKLIST

### Before Changes:
- [ ] Escolher page loads
- [ ] Cards show only name + ID
- [ ] No filters visible
- [ ] No progress bars
- [ ] No legend

### After Phase 1 (Filters):
- [ ] Filter inputs visible
- [ ] Typing in "Unidade" filter → cards filter
- [ ] Typing in "Município" filter → cards filter
- [ ] Clearing filters → all cards appear

### After Phase 2 (Enhanced Data):
- [ ] Controller returns enhanced data
- [ ] No compilation errors
- [ ] Page loads without errors

### After Phase 3 (Enhanced Cards):
- [ ] Cards show municipality
- [ ] Cards show status text
- [ ] Cards show progress bar
- [ ] Progress bars color-coded
- [ ] Progress percentage visible

### After Phase 4 (Legend):
- [ ] Legend visible at bottom
- [ ] 3 color indicators present
- [ ] Labels correct

### Final Verification:
- [ ] Filters work with enhanced cards
- [ ] All data visible
- [ ] Progress bars accurate
- [ ] Colors match status
- [ ] Legend explains colors
- [ ] Cards clickable

---

## QUESTIONS FOR USER

Before implementing, confirm:

1. **Progress Calculation**: How is progress calculated?
   - Completed tasks / Total tasks?
   - Manual field in database?
   - Other formula?

2. **Status Color Logic**: How is status color determined?
   - Green: Progress >= 100%?
   - Red: Deadline exceeded?
   - Gray: In progress?

3. **Status Text**: What is "statusBasicaGratuita"?
   - Database field?
   - Calculated value?
   - Always "Básica"?

4. **Icon Type**: What is "contratanteContratada"?
   - Database field?
   - Always "contratante"?
   - Different icons for different types?

5. **Municipality Field**: Does database have separate city/state fields?
   - `ObrDsCidade` + `ObrDsEstado`?
   - Single field `ObrDsCidadeEstado`?

---

## SUCCESS CRITERIA

### Filters Working:
- ✅ Filter inputs visible
- ✅ Real-time filtering as user types
- ✅ Filters by obra name
- ✅ Filters by municipality
- ✅ Combined filtering works
- ✅ Clearing filters shows all cards

### Cards Enhanced:
- ✅ Dynamic icon based on type
- ✅ Obra name visible
- ✅ Municipality + state visible
- ✅ Status text visible
- ✅ Progress bar with percentage
- ✅ Color-coded status (green/red/gray)
- ✅ Progress bar fills correctly

### Legend Added:
- ✅ Legend visible at bottom
- ✅ 3 color indicators
- ✅ Labels explain each color
- ✅ Colors match card progress bars

---

## ESTIMATED TIME

| Phase | Task | Time |
|-------|------|------|
| Phase 1 | Add filter HTML | 10 min |
| Phase 1 | Add filter JavaScript | 15 min |
| Phase 1 | Test filters | 5 min |
| Phase 2 | Update controller | 30 min |
| Phase 2 | Test enhanced data | 15 min |
| Phase 3 | Update card HTML | 20 min |
| Phase 3 | Test enhanced cards | 10 min |
| Phase 4 | Add legend HTML | 10 min |
| Phase 4 | Add legend CSS | 5 min |
| Phase 5 | Final integration | 10 min |
| Phase 5 | Final verification | 10 min |
| **TOTAL** | | **140 min (2h 20min)** |

**Buffer**: +40 minutes for unexpected issues  
**Total with buffer**: **3 hours**

---

## RISK ASSESSMENT

### Low Risk:
- Adding filter HTML (isolated change)
- Adding legend HTML (isolated change)
- Adding CSS (doesn't break existing styles)

### Medium Risk:
- Filter JavaScript (might conflict with existing JS)
- Enhanced card HTML (might break layout)
- Progress calculation (depends on database structure)

### High Risk:
- Controller changes (affects data loading)
- Database queries (might be slow with many obras)
- Status color logic (might not match legacy)

---

## DEPENDENCIES

### Required for Phase 2:
- Database has `Tarefas` relationship
- Database has `TarStConcluida` field
- Database has `ObrDsCidade` and `ObrDsEstado` fields
- Database has `ObrDtTermino` field

### Optional:
- Database has `contratanteContratada` field
- Database has `statusBasicaGratuita` field

---

## NEXT STEPS

After Strategy 2 complete:
1. Test obra cards thoroughly
2. Get user confirmation
3. Move to next feature (Dashboard? Etapas/Tarefas?)

---

**STATUS**: PLAN READY - AWAITING USER APPROVAL TO IMPLEMENT
