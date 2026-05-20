-- ANÁLISE DA RELAÇÃO LAUDO x TAREFA NO BANCO DE DADOS
-- Investigando se Gilberto usa tabela laudo separada ou campos na tabela tarefa

-- 1. VERIFICAR ESTRUTURA DA TABELA TAREFA
DESCRIBE tarefa;

-- 2. VERIFICAR SE EXISTEM CAMPOS DE LAUDO NA TABELA TAREFA
SHOW COLUMNS FROM tarefa LIKE '%cloro%';
SHOW COLUMNS FROM tarefa LIKE '%ph%';
SHOW COLUMNS FROM tarefa LIKE '%alcalin%';
SHOW COLUMNS FROM tarefa LIKE '%limpidez%';
SHOW COLUMNS FROM tarefa LIKE '%superficie%';
SHOW COLUMNS FROM tarefa LIKE '%fundo%';
SHOW COLUMNS FROM tarefa LIKE '%detrito%';
SHOW COLUMNS FROM tarefa LIKE '%prolifera%';

-- 3. VERIFICAR ESTRUTURA DA TABELA LAUDO
DESCRIBE laudo;

-- 4. VERIFICAR DADOS EXISTENTES
SELECT COUNT(*) as total_tarefas FROM tarefa;
SELECT COUNT(*) as total_laudos FROM laudo;

-- 5. VERIFICAR SE HÁ DADOS NOS CAMPOS DE LAUDO DA TABELA TAREFA
SELECT 
    tar_id_tarefa,
    tar_nr_nivel_cloro,
    tar_nr_ph,
    tar_nr_alcalinidade,
    tar_nr_limpidez,
    tar_nr_superficie,
    tar_nr_fundo,
    tar_nr_nivel_detritos,
    tar_nr_nivel_proliferacao
FROM tarefa 
WHERE tar_nr_nivel_cloro IS NOT NULL 
   OR tar_nr_ph IS NOT NULL 
   OR tar_nr_alcalinidade IS NOT NULL
LIMIT 10;

-- 6. VERIFICAR RELAÇÃO ENTRE LAUDO E TAREFA
SELECT 
    l.lau_id_laudo,
    l.lau_id_tarefa,
    l.lau_tp_nivel_cloro,
    t.tar_id_tarefa,
    t.tar_nr_nivel_cloro
FROM laudo l
LEFT JOIN tarefa t ON l.lau_id_tarefa = t.tar_id_tarefa
LIMIT 10;

-- 7. VERIFICAR SE GILBERTO USA AMBAS AS ABORDAGENS
SELECT 
    'TAREFA' as fonte,
    COUNT(*) as registros_com_dados
FROM tarefa 
WHERE tar_nr_nivel_cloro IS NOT NULL

UNION ALL

SELECT 
    'LAUDO' as fonte,
    COUNT(*) as registros_com_dados
FROM laudo 
WHERE lau_tp_nivel_cloro IS NOT NULL;