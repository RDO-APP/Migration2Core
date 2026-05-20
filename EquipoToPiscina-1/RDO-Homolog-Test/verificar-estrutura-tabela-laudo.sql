-- VERIFICAR ESTRUTURA DA TABELA LAUDO
-- Para investigar erro de salvamento

-- 1. VERIFICAR SE TABELA EXISTE
SHOW TABLES LIKE 'laudo';

-- 2. VERIFICAR ESTRUTURA DA TABELA
DESCRIBE laudo;

-- 3. VERIFICAR CONSTRAINTS E ÍNDICES
SHOW CREATE TABLE laudo;

-- 4. VERIFICAR DADOS EXISTENTES
SELECT COUNT(*) as total_laudos FROM laudo;

-- 5. VERIFICAR ÚLTIMOS LAUDOS
SELECT 
    lau_id_laudo,
    lau_dt_laudo,
    lau_id_obra,
    lau_id_colaborador,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_alcalinidade,
    lau_tp_limpidez
FROM laudo 
ORDER BY lau_id_laudo DESC 
LIMIT 5;

-- 6. VERIFICAR CHAVES ESTRANGEIRAS
SELECT 
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'laudo' 
  AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 7. TESTAR INSERT MANUAL (COMENTADO - DESCOMENTE PARA TESTAR)
/*
INSERT INTO laudo (
    lau_dt_laudo,
    lau_id_status,
    lau_id_obra,
    lau_id_colaborador,
    lau_dt_geracao,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_alcalinidade,
    lau_tp_limpidez
) VALUES (
    '2024-12-27',
    1,
    1,  -- Substitua pelo ID da obra de teste
    1,  -- Substitua pelo ID do colaborador de teste
    NOW(),
    1,
    1,
    3,
    0
);
*/