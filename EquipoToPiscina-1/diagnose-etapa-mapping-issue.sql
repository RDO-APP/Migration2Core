-- COMPREHENSIVE ETAPA MAPPING DIAGNOSIS
-- Database: piscinas_rdoapp_homologa
-- Goal: Find why _context.Etapas.Where(e => e.ObraId == 1).ToListAsync() returns 0 when DBeaver shows 4 rows

-- STEP 1: Verify we're connected to the correct database
SELECT 
    DATABASE() as CurrentDatabase,
    USER() as CurrentUser,
    @@hostname as ServerHost;

-- STEP 2: Check exact table name (case sensitivity matters in MySQL)
SELECT TABLE_NAME, TABLE_SCHEMA, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
  AND TABLE_NAME LIKE '%etapa%'
ORDER BY TABLE_NAME;

-- STEP 3: Verify etapa table structure matches Entity Framework mapping
-- Entity expects: eta_id_etapa, eta_id_obra, eta_ds_etapa
SHOW COLUMNS FROM etapa;

-- STEP 4: Check actual data in etapa table
SELECT 
    eta_id_etapa as EtapaId,
    eta_id_obra as ObraId,
    eta_ds_etapa as Descricao,
    'Raw Data' as Source
FROM etapa
ORDER BY eta_id_obra, eta_id_etapa;

-- STEP 5: Test the EXACT query that Entity Framework generates
-- This simulates: _context.Etapas.Where(e => e.ObraId == obraId)
SELECT 
    eta_id_etapa as Id,
    eta_id_obra as ObraId,
    eta_ds_etapa as Descricao
FROM etapa 
WHERE eta_id_obra = 1
ORDER BY eta_id_etapa;

-- STEP 6: Check if there are any hidden characters or data type issues
SELECT 
    eta_id_etapa,
    eta_id_obra,
    CHAR_LENGTH(eta_ds_etapa) as DescricaoLength,
    HEX(eta_ds_etapa) as DescricaoHex,
    eta_ds_etapa
FROM etapa 
WHERE eta_id_obra = 1;

-- STEP 7: Check tarefa table relationship (for Include operations)
SELECT 
    e.eta_id_etapa as EtapaId,
    e.eta_ds_etapa as EtapaDescricao,
    COUNT(t.tar_id_tarefa) as TarefaCount
FROM etapa e
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
WHERE e.eta_id_obra = 1
GROUP BY e.eta_id_etapa, e.eta_ds_etapa
ORDER BY e.eta_id_etapa;

-- STEP 8: Check status_tarefa table for navigation properties
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
  AND (TABLE_NAME LIKE '%status%' AND TABLE_NAME LIKE '%tarefa%');

-- STEP 9: Verify all obra IDs that exist
SELECT 
    eta_id_obra as ObraId,
    COUNT(*) as EtapaCount,
    GROUP_CONCAT(eta_id_etapa ORDER BY eta_id_etapa) as EtapaIds
FROM etapa 
GROUP BY eta_id_obra
ORDER BY eta_id_obra;

-- STEP 10: Check for any potential filtering columns (like 'ativo' field)
SHOW COLUMNS FROM etapa WHERE Field LIKE '%ativo%' OR Field LIKE '%active%' OR Field LIKE '%deleted%';

-- STEP 11: Raw count verification
SELECT 
    COUNT(*) as TotalEtapas,
    COUNT(CASE WHEN eta_id_obra = 1 THEN 1 END) as EtapasObra1
FROM etapa;