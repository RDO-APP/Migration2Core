-- 🔍 VERIFY TAREFA WATER QUALITY FIELD TYPES IN PRODUCTION DATABASE
-- Execute this query to confirm the exact data types in production

SELECT 
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
ORDER BY COLUMN_NAME;