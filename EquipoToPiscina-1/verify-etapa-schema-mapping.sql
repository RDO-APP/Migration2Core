-- CRITICAL SCHEMA VERIFICATION: Check if table names and column mappings match Entity Framework configuration
-- This will identify the #1 cause of empty results in migrations: schema mapping mismatches

-- 1. CHECK TABLE NAMES: Verify if table is named 'etapa' (singular) or 'etapas' (plural)
SELECT TABLE_NAME, TABLE_SCHEMA 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%etapa%' 
ORDER BY TABLE_NAME;

-- 2. CHECK ETAPA TABLE STRUCTURE: Verify column names match Etapa.cs entity
DESCRIBE etapa;

-- 3. CHECK ACTUAL DATA IN ETAPA TABLE: Verify data exists and ObraId values
SELECT 
    eta_id_etapa as Id,
    eta_id_obra as ObraId, 
    eta_ds_etapa as Descricao,
    COUNT(*) as RecordCount
FROM etapa 
GROUP BY eta_id_etapa, eta_id_obra, eta_ds_etapa
ORDER BY eta_id_obra, eta_id_etapa;

-- 4. CHECK SPECIFIC OBRA: Test the exact query that EtapaService is running
SELECT 
    eta_id_etapa as Id,
    eta_id_obra as ObraId, 
    eta_ds_etapa as Descricao
FROM etapa 
WHERE eta_id_obra = 1
ORDER BY eta_id_etapa;

-- 5. CHECK TAREFA TABLE RELATIONSHIP: Verify foreign key relationship
SELECT 
    e.eta_id_etapa as EtapaId,
    e.eta_ds_etapa as EtapaDescricao,
    COUNT(t.tar_id_tarefa) as TarefaCount
FROM etapa e
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
WHERE e.eta_id_obra = 1
GROUP BY e.eta_id_etapa, e.eta_ds_etapa
ORDER BY e.eta_id_etapa;

-- 6. CHECK STATUS_TAREFA TABLE: Verify navigation property table exists
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME LIKE '%status%tarefa%' OR TABLE_NAME LIKE '%tarefa%status%';

-- 7. VERIFY CONNECTION STRING DATABASE: Check which database we're actually connected to
SELECT DATABASE() as CurrentDatabase;

-- 8. CHECK ALL OBRA IDs: See what obra IDs actually exist
SELECT DISTINCT eta_id_obra as ObraId, COUNT(*) as EtapaCount
FROM etapa 
GROUP BY eta_id_obra
ORDER BY eta_id_obra;