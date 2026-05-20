-- INVESTIGAÇÃO DA ESTRUTURA DO BANCO DE PRODUÇÃO
-- Objetivo: Entender como Gilberto implementou a relação laudo x tarefa

-- 1. ESTRUTURA DA TABELA LAUDO
DESCRIBE laudo;

-- 2. ESTRUTURA DA TABELA TAREFA  
DESCRIBE tarefa;

-- 3. VERIFICAR CHAVES ESTRANGEIRAS DA TABELA LAUDO
SELECT 
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'laudo' 
  AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 4. VERIFICAR CHAVES ESTRANGEIRAS DA TABELA TAREFA
SELECT 
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_NAME = 'tarefa' 
  AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 5. VERIFICAR DADOS EXISTENTES NA TABELA LAUDO
SELECT 
    lau_id_laudo,
    lau_id_obra,
    lau_dt_laudo,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_alcalinidade,
    lau_tp_limpidez,
    lau_tp_superficie,
    lau_tp_fundo
FROM laudo 
ORDER BY lau_id_laudo DESC 
LIMIT 5;

-- 6. VERIFICAR DADOS EXISTENTES NA TABELA TAREFA (campos de laudo se existirem)
SELECT 
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_dt_medicao,
    tar_id_status
FROM tarefa 
WHERE tar_dt_medicao >= '2024-12-20'
ORDER BY tar_dt_medicao DESC 
LIMIT 5;

-- 7. VERIFICAR SE EXISTE RELAÇÃO DIRETA ENTRE LAUDO E TAREFA
-- Tentativa 1: Por obra e data
SELECT 
    l.lau_id_laudo,
    l.lau_id_obra,
    l.lau_dt_laudo,
    t.tar_id_tarefa,
    t.tar_ds_tarefa,
    t.tar_dt_medicao,
    e.eta_id_obra
FROM laudo l
LEFT JOIN tarefa t ON DATE(t.tar_dt_medicao) = DATE(l.lau_dt_laudo)
LEFT JOIN etapa e ON t.tar_id_etapa = e.eta_id_etapa AND e.eta_id_obra = l.lau_id_obra
WHERE l.lau_dt_laudo >= '2024-12-20'
ORDER BY l.lau_dt_laudo DESC
LIMIT 10;

-- 8. VERIFICAR CAMPOS ESPECÍFICOS QUE PODEM FAZER A RELAÇÃO
SHOW COLUMNS FROM laudo LIKE '%tarefa%';
SHOW COLUMNS FROM laudo LIKE '%tar_%';
SHOW COLUMNS FROM tarefa LIKE '%laudo%';
SHOW COLUMNS FROM tarefa LIKE '%lau_%';

-- 9. VERIFICAR SE HÁ TABELA DE RELACIONAMENTO
SHOW TABLES LIKE '%laudo%';
SHOW TABLES LIKE '%tarefa%';

-- 10. ANÁLISE DOS ÚLTIMOS REGISTROS SALVOS
SELECT 'LAUDO' as tabela, COUNT(*) as total FROM laudo
UNION ALL
SELECT 'TAREFA' as tabela, COUNT(*) as total FROM tarefa;

-- 11. VERIFICAR REGISTROS RECENTES (últimos 7 dias)
SELECT 
    'LAUDO' as tabela,
    COUNT(*) as registros_recentes
FROM laudo 
WHERE lau_dt_laudo >= DATE_SUB(NOW(), INTERVAL 7 DAY)
UNION ALL
SELECT 
    'TAREFA' as tabela,
    COUNT(*) as registros_recentes
FROM tarefa 
WHERE tar_dt_medicao >= DATE_SUB(NOW(), INTERVAL 7 DAY);