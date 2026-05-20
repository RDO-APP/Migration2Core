# 🧪 Local Homologation Testing - No Code Changes

## Objective
Test the homologation environment locally to verify our proposed fixes work before deploying to production.

## Approach
Create a **separate testing copy** of the project to validate fixes without modifying the original codebase.

## Setup Steps

### Step 1: Create Testing Copy (5 minutes)

```powershell
# Create a testing directory
New-Item -ItemType Directory -Path "RDO-Homolog-Test" -Force

# Copy the entire project
Copy-Item -Path "rdoappClass" -Destination "RDO-Homolog-Test\rdoappClass" -Recurse
Copy-Item -Path "rdoappProject" -Destination "RDO-Homolog-Test\rdoappProject" -Recurse
Copy-Item -Path "solution" -Destination "RDO-Homolog-Test\solution" -Recurse

# Copy solution file if it exists
Copy-Item -Path "*.sln" -Destination "RDO-Homolog-Test\" -ErrorAction SilentlyContinue
```

### Step 2: Database Setup (10 minutes)

**Create Homolog Database:**
```sql
-- Connect to MySQL and create homolog database
CREATE DATABASE IF NOT EXISTS `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Copy essential tables structure (you can do this gradually)
-- Start with just the laudo table for testing:

CREATE TABLE `piscinas_rdoapp_homolog`.`laudo` (
  `lau_id_laudo` int(11) NOT NULL AUTO_INCREMENT,
  `lau_id_status` int(11) NOT NULL DEFAULT 1,
  `lau_id_obra` int(11) NOT NULL DEFAULT 1,
  `lau_dt_laudo` date NOT NULL,
  `lau_ds_comentario_assinatura` varchar(2000) DEFAULT NULL,
  `lau_id_colaborador` int(11) DEFAULT 1,
  `lau_dt_geracao` datetime DEFAULT CURRENT_TIMESTAMP,
  `lau_tp_comentario_assinatura` varchar(1) DEFAULT NULL,
  `lau_ds_comentario_geracao` text,
  `lau_tp_comentario_geracao` varchar(1) DEFAULT NULL,
  `lau_tp_nivel_cloro` tinyint(1) DEFAULT 1,
  `lau_tp_ph` tinyint(1) DEFAULT 1,
  `lau_tp_limpidez` tinyint(1) DEFAULT 1,
  `lau_tp_superficie` tinyint(1) DEFAULT 1,
  `lau_tp_fundo` tinyint(1) DEFAULT 1,
  `lau_tp_nivel_cloro_2` tinyint(1) DEFAULT 0,
  `lau_tp_nivel_bacterias` tinyint(1) DEFAULT 0,
  `lau_tp_nivel_proliferacao` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`lau_id_laudo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert test data
INSERT INTO `piscinas_rdoapp_homolog`.`laudo` 
(lau_id_status, lau_id_obra, lau_dt_laudo, lau_ds_comentario_geracao, lau_tp_nivel_cloro, lau_tp_ph) 
VALUES 
(1, 1, CURDATE(), 'Teste de homologação - Laudo 1', 1, 1),
(1, 1, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'Teste de homologação - Laudo 2', 0, 1),
(1, 1, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'Teste de homologação - Laudo 3', 1, 0);

-- Create minimal supporting tables for testing
CREATE TABLE `piscinas_rdoapp_homolog`.`status_rdo` (
  `str_id_status` int(11) NOT NULL AUTO_INCREMENT,
  `str_ds_status` varchar(50) NOT NULL,
  PRIMARY KEY (`str_id_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `piscinas_rdoapp_homolog`.`status_rdo` VALUES (1, 'Pendente'), (2, 'Assinado');

CREATE TABLE `piscinas_rdoapp_homolog`.`obra` (
  `obr_id_obra` int(11) NOT NULL AUTO_INCREMENT,
  `obr_ds_obra` varchar(200) NOT NULL DEFAULT 'Obra de Teste',
  `obr_dt_inicio` date NOT NULL DEFAULT (CURDATE()),
  PRIMARY KEY (`obr_id_obra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `piscinas_rdoapp_homolog`.`obra` VALUES (1, 'Piscina Teste Homologação', CURDATE());

CREATE TABLE `piscinas_rdoapp_homolog`.`colaborador` (
  `col_id_colaborador` int(11) NOT NULL AUTO_INCREMENT,
  `col_nm_colaborador` varchar(100) NOT NULL DEFAULT 'Colaborador Teste',
  PRIMARY KEY (`col_id_colaborador`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `piscinas_rdoapp_homolog`.`colaborador` VALUES (1, 'Técnico de Teste');
```

### Step 3: Apply Fixes to Test Copy Only

**In the RDO-Homolog-Test directory:**

1. **Update Connection String** (RDO-Homolog-Test/rdoappProject/Web.config):
```xml
<!-- Change database name from piscinas_rdoapp to piscinas_rdoapp_homolog -->
<connectionStrings>
  <add name="rdoappEntities" 
       connectionString="metadata=res://*/rdoappModel.csdl|res://*/rdoappModel.ssdl|res://*/rdoappModel.msl;provider=MySql.Data.MySqlClient;provider connection string=&quot;server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;User Id=rdoadmin;password=rdoapp2018aws;database=piscinas_rdoapp_homolog&quot;" 
       providerName="System.Data.EntityClient" />
</connectionStrings>
```

2. **Fix Entity Framework Issue** (RDO-Homolog-Test/rdoappProject/Api/Models/LaudoModel.cs):
```csharp
// Replace all instances of:
context.laudo.

// With:
context.Set<laudo>().
```

3. **Create Missing RDLC** (RDO-Homolog-Test/rdoappProject/Api/Contents/Reports/):
```powershell
# Copy existing template
Copy-Item "RDO-Homolog-Test\rdoappProject\Api\Contents\Reports\Rdo_def.rdlc" `
          "RDO-Homolog-Test\rdoappProject\Api\Contents\Reports\Teste.rdlc"
```

### Step 4: Test Locally (15 minutes)

1. **Open Test Solution in Visual Studio**
   - Open `RDO-Homolog-Test\[solution-name].sln`
   - Set `rdoappProject` as startup project

2. **Build and Run**
   - Right-click `rdoappModel.Context.tt` → Run Custom Tool
   - Right-click `rdoappModel.tt` → Run Custom Tool
   - Build Solution (Ctrl+Shift+B)
   - Run (F5)

3. **Test Laudo Functionality**
   - Navigate to `http://localhost:[port]/laudos/index`
   - Check if page loads without "AGUARDE"
   - Try to access `http://localhost:[port]/laudos/cadastro`
   - Attempt to create a new Laudo
   - Test PDF generation

## Expected Results

### ✅ Success Indicators:
- Application starts without Entity Framework errors
- Laudo index page loads and shows test data
- No "entity not part of model" errors
- No "Teste.rdlc not found" errors
- Can navigate between Laudo pages

### ⚠️ Acceptable Issues:
- PDF formatting may need refinement
- Some UI elements may not work (due to missing related tables)
- Authentication/authorization issues (expected in test environment)

### ❌ Failure Indicators:
- Application crashes on startup
- "Entity not part of model" errors persist
- "Teste.rdlc not found" errors
- Cannot access any Laudo pages

## Testing Checklist

### Database Tests
- [ ] Homolog database created successfully
- [ ] Laudo table exists with test data
- [ ] Connection string points to homolog DB
- [ ] Can query laudo table directly

### Application Tests
- [ ] Solution builds without errors
- [ ] Application starts locally
- [ ] No Entity Framework initialization errors
- [ ] Can access `/laudos/index`
- [ ] Can access `/laudos/cadastro`

### Entity Framework Tests
- [ ] `context.Set<laudo>()` works without errors
- [ ] Can retrieve laudo records from database
- [ ] Can create new laudo records
- [ ] CRUD operations function correctly

### Report Tests
- [ ] `Teste.rdlc` file exists in correct location
- [ ] PDF generation doesn't crash
- [ ] Report parameters are accepted
- [ ] Basic PDF structure is generated

## Troubleshooting

### If Entity Framework Errors Persist:
1. Check connection string format
2. Verify homolog database exists and is accessible
3. Ensure laudo table has correct structure
4. Check Entity Framework model regeneration

### If RDLC Errors Persist:
1. Verify file path and name exactly match
2. Check file properties (Build Action = Embedded Resource)
3. Rebuild solution to embed resources
4. Test with simple report first

### If Application Won't Start:
1. Check Web.config syntax
2. Verify all required NuGet packages
3. Check IIS Express configuration
4. Review Visual Studio output for specific errors

## Next Steps After Local Success

### If Local Testing Succeeds:
1. Document successful test results
2. Create deployment plan for production
3. Prepare rollback strategy
4. Schedule production deployment

### If Local Testing Fails:
1. Analyze specific error messages
2. Refine fixes based on test results
3. Repeat local testing until successful
4. Do not proceed to production until local tests pass

---

## 🎯 Key Benefits of This Approach

- ✅ **Safe Testing**: Original code remains untouched
- ✅ **Isolated Environment**: Test without affecting production
- ✅ **Iterative Refinement**: Fix issues before production deployment
- ✅ **Confidence Building**: Verify solutions work before committing
- ✅ **Easy Rollback**: Original code always available

**Time Estimate: 30-45 minutes**
**Risk Level: Zero (no production impact)**
**Prerequisites: Visual Studio, MySQL access**