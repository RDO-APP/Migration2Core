-- CRITICAL: Verify actual column names in tarefa table
-- This will help us identify if tar_id_obra exists or if it's named differently

-- Show table structure
DESCRIBE tarefa;

-- Alternative way to show columns
SHOW COLUMNS FROM tarefa;

-- Check if tar_id_obra column exists
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'rdoapp_homologa' 
  AND TABLE_NAME = 'tarefa' 
  AND COLUMN_NAME LIKE '%obra%';

-- Check all columns that might be related to obra
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'rdoapp_homologa' 
  AND TABLE_NAME = 'tarefa' 
ORDER BY ORDINAL_POSITION;

-- Sample data to see actual column values
SELECT tar_id_tarefa, tar_id_etapa, tar_id_obra
FROM tarefa 
WHERE tar_id_etapa IN (880, 881, 883, 884)
LIMIT 5;