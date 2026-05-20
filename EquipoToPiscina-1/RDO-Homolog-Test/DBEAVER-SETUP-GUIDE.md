# 🦫 DBeaver Setup Guide - Clonar Banco de Dados de Produção (Português)

## 🎯 **Objetivo: Criar Cópia Completa do Banco de Dados**
bit'
Vamos criar `piscinas_rdoapp_homolog` com a **MESMA estrutura E dados** do banco `piscinas_rdoapp` de produção.

---

## 🔄 **Método 1: Dump do Banco no DBeaver (Recomendado)**

### **Passo 1: Abrir DBeaver**
1. Conecte ao seu servidor MySQL
2. Você deve ver o banco `piscinas_rdoapp` (produção)

### **Passo 2: Fazer Dump do Banco de Dados**
1. **Clique com botão direito** em `piscinas_rdoapp` (banco de produção)
2. Selecione **"Dump do banco de dados"** (ícone de seta para cima)
3. **Configurações do Dump**:
   - ✅ **Estrutura** (tabelas, índices, constraints)
   - ✅ **Dados** (todos os dados de produção para teste)
   - ✅ **Incluir Tabelas**
   - ✅ **Incluir Views** (se houver)
   - ✅ **Incluir Triggers** (se houver)
   - ✅ **Incluir Procedures** (se houver)

### **Passo 3: Configurar Destino**
1. **Escolha onde salvar** o arquivo SQL (ex: `producao_completa.sql`)
2. **Execute o dump** - isso criará um arquivo SQL com tudo
3. **Aguarde a conclusão** (pode demorar alguns minutos com dados)

### **Passo 4: Modificar o SQL para Homologação**
1. **Abra o arquivo SQL** gerado no DBeaver ou editor de texto
2. **Encontre e substitua**:
   - `CREATE DATABASE piscinas_rdoapp` → `CREATE DATABASE piscinas_rdoapp_homolog`
   - `USE piscinas_rdoapp` → `USE piscinas_rdoapp_homolog`
   - Qualquer referência ao banco original

### **Passo 5: Executar o SQL Modificado**
1. **Abra o arquivo SQL modificado** no DBeaver
2. **Execute o script completo**
3. **Aguarde a criação** do banco homolog com todos os dados

---

## 🔄 **Método 2: Restaurar Banco de Dados (Alternativo)**

Se você preferir usar a opção **"Restaurar banco de dados"**:

### **Passo 1: Criar Banco Homolog Vazio**
```sql
-- Execute este SQL no DBeaver primeiro:
CREATE DATABASE IF NOT EXISTS `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### **Passo 2: Usar Restaurar Banco**
1. **Clique com botão direito** em `piscinas_rdoapp_homolog` (banco vazio)
2. Selecione **"Restaurar banco de dados"** (ícone de seta para baixo)
3. **Escolha a fonte**: Banco `piscinas_rdoapp` (produção)
4. **Configure**: Estrutura + Dados
5. **Execute a restauração**

---

## 🔄 **Método 3: Script SQL Manual (Mais Simples)**

Se os métodos acima não funcionarem, use este script SQL:

```sql
-- 1. Criar banco homolog
CREATE DATABASE IF NOT EXISTS `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Copiar estrutura de todas as tabelas
-- Execute este comando no terminal/prompt (fora do DBeaver):
-- mysqldump -h equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com -u rdoadmin -p piscinas_rdoapp | mysql -h equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com -u rdoadmin -p piscinas_rdoapp_homolog

-- OU use o script que criei para você:
```

### **Usar o Script Pronto**
1. **Abra o arquivo**: `RDO-Homolog-Test/setup-homolog-database.sql`
2. **Execute no DBeaver**
3. **Aguarde a conclusão**

### **Step 1: Compare Table Lists**
Run this query to see all tables in production:
```sql
USE piscinas_rdoapp;
SHOW TABLES;
```

Then verify homolog has the same tables:
```sql
USE piscinas_rdoapp_homolog;
SHOW TABLES;
```

### **Step 2: Compare Key Table Structures**
For critical tables, compare structures:

**Production:**
```sql
USE piscinas_rdoapp;
DESCRIBE laudo;
DESCRIBE obra;
DESCRIBE colaborador;
DESCRIBE status_rdo;
```

**Homolog:**
```sql
USE piscinas_rdoapp_homolog;
DESCRIBE laudo;
DESCRIBE obra;
DESCRIBE colaborador;
DESCRIBE status_rdo;
```

### **Step 3: Verify Foreign Keys**
```sql
-- Production
USE piscinas_rdoapp;
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'piscinas_rdoapp'
ORDER BY TABLE_NAME;

-- Homolog
USE piscinas_rdoapp_homolog;
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'piscinas_rdoapp_homolog'
ORDER BY TABLE_NAME;
```

---

## 🔄 **Method 3: Command Line Full Clone (Advanced)**

If you have command line access and want to copy everything:

```bash
# Export production structure AND data
mysqldump -h equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com -u rdoadmin -p --routines --triggers piscinas_rdoapp > production_full_copy.sql

# Edit the SQL file to change database name from piscinas_rdoapp to piscinas_rdoapp_homolog
# Then import to create homolog database with all data
mysql -h equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com -u rdoadmin -p < production_full_copy.sql
```

---

## 📊 **After Full Database Copy: Verify Data**

Once you have copied both structure and data, verify everything:

```sql
USE piscinas_rdoapp_homolog;

-- Check total record counts
SELECT 'Total laudo records:' as info, COUNT(*) as count FROM laudo;
SELECT 'Total obra records:' as info, COUNT(*) as count FROM obra;
SELECT 'Total colaborador records:' as info, COUNT(*) as count FROM colaborador;

-- Show recent laudo records for testing
SELECT 
    lau_id_laudo,
    lau_dt_laudo,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_ds_comentario_geracao
FROM laudo 
ORDER BY lau_dt_laudo DESC 
LIMIT 10;

-- Verify you have real production data (not just test data)
SELECT 'Data verification complete - ready for testing!' as status;
```

---

## ✅ **Verification Checklist**

### **Data Verification:**
- [ ] Homolog database created
- [ ] All production tables exist in homolog
- [ ] Table structures match exactly (same columns, types, constraints)
- [ ] Foreign key relationships preserved
- [ ] Indexes copied correctly
- [ ] **Production data copied successfully**
- [ ] **Laudo records exist and are accessible**
- [ ] **All related data (obra, colaborador, etc.) copied**

### **Connection Verification:**
- [ ] Application can connect to homolog database
- [ ] Entity Framework recognizes all entities
- [ ] No "entity not part of model" errors

---

## 🎯 **Recommended Approach for Full Data Copy**

1. **Use DBeaver Export Database feature** (Method 1)
2. **Export structure AND data** from production
3. **Modify database name** to homolog in the export SQL
4. **Execute to create complete copy** with all production data
5. **Verify data copied correctly** using verification queries
6. **Test with real production data** for comprehensive testing

---

## 🚨 **Safety Notes for Full Data Copy**

- ✅ **Database cloning is safe** - read-only from production
- ✅ **Production data copied for testing** - comprehensive test scenarios
- ✅ **Production database remains untouched** - read-only operations
- ⚠️ **Double-check database names** - ensure you're working with homolog
- ⚠️ **Homolog data is a snapshot** - won't sync with production changes
- ⚠️ **Don't modify homolog data** - it represents production state

---

**🎯 Next Step: Choose your preferred method and execute the structure clone.**

**Time Estimate: 10-15 minutes**
**Risk Level: Zero (read-only from production)**