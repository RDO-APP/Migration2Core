-- =====================================================
-- EXTRACT EXACT STRUCTURE FROM piscinas_rdoapp_homologa
-- This script will generate CREATE TABLE statements that match exactly
-- =====================================================

-- Connect to piscinas_rdoapp_homologa first, then run this script

-- 1. Get all table names
SELECT 'TABLES IN piscinas_rdoapp_homologa:' as info;
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
ORDER BY TABLE_NAME;

-- 2. Get CREATE TABLE statement for each important table
-- Run these one by one to get exact structure:

SHOW CREATE TABLE obra;
SHOW CREATE TABLE etapa;  
SHOW CREATE TABLE tarefa;
SHOW CREATE TABLE medicao;
SHOW CREATE TABLE laudo;
SHOW CREATE TABLE colaborador;
SHOW CREATE TABLE status_tarefa;
SHOW CREATE TABLE uf;
SHOW CREATE TABLE municipio;

-- 3. Get detailed column information for verification
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    COLUMN_TYPE,
    EXTRA
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
  AND TABLE_NAME IN ('obra', 'etapa', 'tarefa', 'medicao', 'laudo', 'colaborador', 'status_tarefa', 'uf', 'municipio')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 4. Get foreign key relationships
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;