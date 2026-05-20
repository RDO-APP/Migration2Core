-- INVESTIGAÇÃO RÁPIDA - EXECUTE ESTAS CONSULTAS NO DBEAVER

-- 1. ESTRUTURA DA TABELA LAUDO
DESCRIBE laudo;

-- 2. ESTRUTURA DA TABELA TAREFA  
DESCRIBE tarefa;

-- 3. VERIFICAR DADOS RECENTES NA TABELA LAUDO
SELECT 
    lau_id_laudo,
    lau_id_obra,
    lau_dt_laudo,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_alcalinidade,
    lau_tp_limpidez
FROM laudo 
ORDER BY lau_id_laudo DESC 
LIMIT 5;

-- 4. VERIFICAR DADOS RECENTES NA TABELA TAREFA
SELECT 
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_dt_medicao,
    tar_id_status,
    tar_id_etapa
FROM tarefa 
WHERE tar_dt_medicao >= '2024-12-20'
ORDER BY tar_dt_medicao DESC 
LIMIT 5;

-- 5. VERIFICAR SE EXISTE RELAÇÃO POR OBRA E DATA
SELECT 
    l.lau_id_laudo,
    l.lau_id_obra,
    l.lau_dt_laudo,
    l.lau_tp_nivel_cloro,
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

-- 6. VERIFICAR CAMPOS QUE PODEM FAZER RELAÇÃO
SHOW COLUMNS FROM laudo LIKE '%tarefa%';
SHOW COLUMNS FROM tarefa LIKE '%laudo%';