-- 🔍 COMPARE PRODUCTION vs HOMOLOG WATER QUALITY FIELDS
-- Execute this to compare field types between both databases

-- PRODUCTION DATABASE FIELDS
SELECT 
    'PRODUCTION' as DATABASE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp' 
  AND TABLE_NAME = 'tarefa'
  AND COLUMN_NAME IN (
    'tar_nr_nivel_cloro',
    'tar_nr_ph', 
    'tar_nr_alcalinidade',
    'tar_nr_limpidez',
    'tar_nr_superficie',
    'tar_nr_fundo',
    'tar_nr_nivel_detritos',
    'tar_nr_nivel_proliferacao'
  )

UNION ALL

-- HOMOLOG DATABASE FIELDS
SELECT 
    'HOMOLOG' as DATABASE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' 
  AND TABLE_NAME = 'tarefa'
  AND COLUMN_NAME IN (
    'tar_nr_nivel_cloro',
    'tar_nr_ph', 
    'tar_nr_alcalinidade',
    'tar_nr_limpidez',
    'tar_nr_superficie',
    'tar_nr_fundo',
    'tar_nr_nivel_detritos',
    'tar_nr_nivel_proliferacao'
  )

ORDER BY COLUMN_NAME, DATABASE_NAME;