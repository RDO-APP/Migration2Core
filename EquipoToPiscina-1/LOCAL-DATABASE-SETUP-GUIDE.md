# 🚀 LOCAL DATABASE SETUP GUIDE - IMMEDIATE AWS COST REDUCTION

## Quick Setup Steps

### 1. Create Local Database in DBeaver
1. Open DBeaver
2. Create new MySQL connection to localhost
3. Create database: `rdoapp_local`
4. Open SQL editor for the new database

### 2. Import Database Structure & Data
1. Open the file: `local-database-export.sql`
2. Copy all content and paste into DBeaver SQL editor
3. Execute the entire script (Ctrl+Enter or F5)
4. Verify tables created: `Obras`, `Etapas`, `Tarefas`, `Medicoes`, `StatusTarefa`

### 3. Update Connection String
✅ **ALREADY DONE** - Updated `appsettings.Development.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=rdoapp_local;Uid=root;Pwd=your_password_here;CharSet=utf8mb4;"
  }
}
```

**⚠️ IMPORTANT**: Update `your_password_here` with your actual MySQL root password.

### 4. Test Local Connection
Run this PowerShell command to test:
```powershell
# Test compilation and connection
dotnet build RDO-NET8-Migration/RdoApp.Core/RdoApp.Core.csproj
```

## 📊 What You Get Locally

### Test Data Included:
- **Obra 233**: "ESCOLA MUNICIPAL TESTE LOCAL"
- **6 Etapas**: From "Preparação do Terreno" to "Finalização"
- **17 Tarefas**: Various completion states (Completed, In Progress, Planned)
- **15+ Medicoes**: Historical measurement records

### Perfect for Testing Group By Logic:
```sql
-- Test query for your Group By debugging:
SELECT 
    e.Id as EtapaId,
    e.Descricao as EtapaDescricao,
    COUNT(t.Id) as TotalTarefas,
    SUM(CASE WHEN t.StatusId = 3 THEN 1 ELSE 0 END) as TarefasConcluidas,
    AVG(t.QuantidadeConstruida) as MediaProgresso
FROM Etapas e
LEFT JOIN Tarefas t ON e.Id = t.EtapaId
WHERE e.ObraId = 233 AND e.Ativo = 1
GROUP BY e.Id, e.Descricao, e.Ordem
ORDER BY e.Ordem;
```

## 🎯 Immediate Benefits

1. **Zero AWS RDS costs** during development
2. **Faster queries** (local database)
3. **Full control** over test data
4. **No internet dependency** for development
5. **Same data structure** as production

## 🔧 Connection String Options

Choose the connection string that matches your local MySQL setup:

### Option 1: MySQL with root user
```json
"DefaultConnection": "Server=localhost;Database=rdoapp_local;Uid=root;Pwd=your_password;"
```

### Option 2: MySQL with custom user
```json
"DefaultConnection": "Server=localhost;Database=rdoapp_local;Uid=rdouser;Pwd=rdopass;"
```

### Option 3: MySQL on custom port
```json
"DefaultConnection": "Server=localhost;Port=3307;Database=rdoapp_local;Uid=root;Pwd=your_password;"
```

## ✅ Verification Steps

After setup, verify everything works:

1. **Check table count**:
   ```sql
   SELECT COUNT(*) FROM Obras;      -- Should return 1
   SELECT COUNT(*) FROM Etapas;     -- Should return 6  
   SELECT COUNT(*) FROM Tarefas;    -- Should return 17
   SELECT COUNT(*) FROM Medicoes;   -- Should return 15+
   ```

2. **Test your Group By query** (the one causing AWS costs)

3. **Run your application** in Development mode

## 🚨 Emergency Rollback

If you need to quickly switch back to AWS:
1. Comment out the ConnectionStrings section in `appsettings.Development.json`
2. The app will fall back to `appsettings.json` (AWS connection)

---

**🎉 You're now ready to debug locally without AWS costs!**