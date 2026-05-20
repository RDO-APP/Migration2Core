-- Verificar obras disponíveis para criar usuário de teste
SELECT 
    obr_id_obra as ID,
    obr_nm_obra as NOME_OBRA,
    obr_dt_inicio as DATA_INICIO,
    obr_dt_fim as DATA_FIM,
    CASE 
        WHEN obr_dt_fim IS NULL OR obr_dt_fim > NOW() THEN 'ATIVA'
        ELSE 'FINALIZADA'
    END as STATUS
FROM obra 
ORDER BY obr_id_obra
LIMIT 10;