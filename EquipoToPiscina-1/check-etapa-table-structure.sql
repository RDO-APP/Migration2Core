-- Check the actual structure of the etapa table
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'etapa'
ORDER BY ORDINAL_POSITION;

-- Also check the actual data in etapa table
SELECT 
    eta_id_etapa,
    eta_id_obra,
    eta_ds_etapa,
    -- Check if there are any other columns
    *
FROM etapa 
WHERE eta_id_obra = 1  -- Assuming obra ID 1 for testing
LIMIT 10;