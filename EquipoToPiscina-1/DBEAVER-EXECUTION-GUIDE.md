# 🚀 DBeaver Execution Guide - Stop AWS RDS Costs NOW

## Step-by-Step Instructions to Execute setup_local_db.sql

### 1. Open DBeaver
- Launch DBeaver on your machine
- Make sure you have a local SQL Server connection configured

### 2. Connect to Local SQL Server
- **Right-click** in the Database Navigator (left panel)
- Select **"Create" → "Connection"**
- Choose **"SQL Server"** 
- Configure connection:
  ```
  Server Host: localhost
  Port: 1433 (default)
  Database: master (initially)
  Authentication: Windows Authentication (Trusted_Connection=True)
  ```
- Click **"Test Connection"** to verify
- Click **"Finish"**

### 3. Open SQL Editor
- **Right-click** on your SQL Server connection
- Select **"SQL Editor" → "Open SQL Script"**
- OR use shortcut: **Ctrl+]** or **F3**

### 4. Load the Script
**Option A - Copy/Paste:**
1. Open the file `setup_local_db.sql` in your text editor
2. **Select All** (Ctrl+A) and **Copy** (Ctrl+C)
3. **Paste** (Ctrl+V) into the DBeaver SQL Editor

**Option B - Import File:**
1. In SQL Editor, click **"File" → "Open"**
2. Navigate to your project folder
3. Select `setup_local_db.sql`
4. Click **"Open"**

### 5. Execute the Script
- **IMPORTANT**: Make sure you're connected to the **master** database first
- **Select All** text in the SQL Editor (Ctrl+A)
- **Execute** the script:
  - Click the **"Execute SQL Script"** button (▶️ icon)
  - OR press **Ctrl+Alt+Shift+X**
  - OR press **F5**

### 6. Monitor Execution
- Watch the **"Output"** panel at the bottom
- You should see messages like:
  ```
  Database 'GilbertoLegacy' created
  Table 'uf' created
  Table 'municipio' created
  Table 'obra' created
  Table 'etapa' created
  Table 'tarefa' created
  Table 'medicao' created
  Data inserted successfully
  ```

### 7. Verify Database Creation
- **Refresh** the Database Navigator (F5)
- Expand your SQL Server connection
- You should see **"GilbertoLegacy"** database
- Expand it to see the tables:
  - `uf`
  - `municipio` 
  - `obra`
  - `etapa`
  - `tarefa`
  - `medicao`
  - `status_tarefa`

### 8. Verify Data Import
Run these verification queries in a new SQL Editor:

```sql
-- Connect to GilbertoLegacy database first
USE GilbertoLegacy;

-- Check Obra 233 exists
SELECT * FROM obra WHERE id = 233;

-- Check 6 etapas created
SELECT COUNT(*) as etapa_count FROM etapa WHERE obra_id = 233;

-- Check 17 tarefas created  
SELECT COUNT(*) as tarefa_count FROM tarefa 
WHERE etapa_id IN (SELECT id FROM etapa WHERE obra_id = 233);

-- Check medicoes created (should be 30+)
SELECT COUNT(*) as medicao_count FROM medicao 
WHERE tarefa_id IN (
    SELECT id FROM tarefa 
    WHERE etapa_id IN (SELECT id FROM etapa WHERE obra_id = 233)
);

-- Test the 30-card duplication problem
SELECT 'PROBLEM QUERY - Returns 30+ rows:' as description;
SELECT COUNT(*) as duplicate_cards
FROM etapa e
LEFT JOIN tarefa t ON e.id = t.etapa_id AND t.ativo = 1
LEFT JOIN medicao m ON t.id = m.tarefa_id AND m.ativo = 1
WHERE e.obra_id = 233 AND e.ativo = 1;

-- Test the correct GROUP BY solution
SELECT 'SOLUTION QUERY - Returns 6 rows:' as description;
SELECT COUNT(DISTINCT e.id) as correct_cards
FROM etapa e
WHERE e.obra_id = 233 AND e.ativo = 1;
```

## 🎯 Expected Results:
- **Obra count**: 1 (Obra 233)
- **Etapa count**: 6 (should show 6 cards, not 30)
- **Tarefa count**: 17 
- **Medicao count**: 30+ (this causes the duplication)
- **Problem query**: Returns 30+ rows (the bug)
- **Solution query**: Returns 6 rows (the fix)

## ⚠️ Troubleshooting:

### If Connection Fails:
- Make sure SQL Server is running locally
- Try SQL Server Authentication instead:
  ```
  Username: sa
  Password: [your_sa_password]
  ```

### If Script Fails:
- Make sure you're connected to **master** database initially
- Execute the script in smaller chunks if needed
- Check the Output panel for specific error messages

### If Database Already Exists:
- Drop it first: `DROP DATABASE GilbertoLegacy;`
- Then re-run the script

## ✅ Success Confirmation:
Once complete, you should see:
1. **GilbertoLegacy** database in DBeaver
2. **7 tables** created with data
3. **Obra 233** with 6 etapas and 30+ medicoes
4. **Zero AWS RDS costs** from this point forward!

## 🚀 Next Step:
Test your application with the new connection string:
```json
"DefaultConnection": "Server=localhost;Database=GilbertoLegacy;Trusted_Connection=True;"
```

**Your AWS RDS spike will stop immediately once this local database is active!**