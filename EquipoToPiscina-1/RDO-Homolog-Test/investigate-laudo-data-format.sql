-- INVESTIGAÇÃO: COMO OS DADOS DO LAUDO ESTÃO SENDO SALVOS
-- Objetivo: Entender se os campos Cloro, PH, Alcalinidade são salvos como IDs ou boolean

-- 1. VERIFICAR ESTRUTURA DA TABELA LAUDO
DESCRIBE laudo;

-- 2. VERIFICAR DADOS EXISTENTES NA TABELA LAUDO
SELECT 
    lau_id_laudo,
    lau_id_obra,
    lau_dt_laudo,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_limpidez,
    lau_tp_superficie,
    lau_tp_fundo,
    lau_tp_nivel_cloro_2,
    lau_tp_nivel_bacterias,
    lau_tp_nivel_proliferacao,
    lau_ds_comentario_geracao
FROM laudo 
ORDER BY lau_dt_laudo DESC 
LIMIT 10;

-- 3. VERIFICAR TIPOS DE DADOS DOS CAMPOS ESPECÍFICOS
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'laudo' 
AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
AND COLUMN_NAME IN (
    'lau_tp_nivel_cloro',
    'lau_tp_ph', 
    'lau_tp_limpidez',
    'lau_tp_superficie',
    'lau_tp_fundo',
    'lau_tp_nivel_bacterias',
    'lau_tp_nivel_proliferacao'
);

-- 4. VERIFICAR SE EXISTEM LAUDOS SALVOS RECENTEMENTE
SELECT 
    COUNT(*) as total_laudos,
    MAX(lau_dt_laudo) as ultimo_laudo,
    MIN(lau_dt_laudo) as primeiro_laudo
FROM laudo;

-- 5. VERIFICAR VALORES ÚNICOS DOS CAMPOS CLORO E PH (para entender o padrão)
SELECT DISTINCT 
    lau_tp_nivel_cloro,
    COUNT(*) as qtd_cloro
FROM laudo 
WHERE lau_tp_nivel_cloro IS NOT NULL
GROUP BY lau_tp_nivel_cloro;

SELECT DISTINCT 
    lau_tp_ph,
    COUNT(*) as qtd_ph  
FROM laudo 
WHERE lau_tp_ph IS NOT NULL
GROUP BY lau_tp_ph;

-- 6. VERIFICAR SE EXISTE CAMPO ALCALINIDADE (que não deveria existir no banco real)
SELECT 
    COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'laudo' 
AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
AND COLUMN_NAME LIKE '%alcalin%';

-- 7. COMPARAR COM ESTRUTURA DA TABELA TAREFA (abordagem do Gilberto)
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'tarefa' 
AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
AND COLUMN_NAME IN (
    'tar_nr_nivel_cloro',
    'tar_nr_ph',
    'tar_nr_alcalinidade',
    'tar_nr_limpidez'
);

-- 8. VERIFICAR DADOS DA TABELA TAREFA (se Gilberto usou essa abordagem)
SELECT 
    tar_id_tarefa,
    tar_dt_medicao,
    tar_nr_nivel_cloro,
    tar_nr_ph,
    tar_nr_alcalinidade,
    tar_nr_limpidez
FROM tarefa 
WHERE (tar_nr_nivel_cloro IS NOT NULL 
    OR tar_nr_ph IS NOT NULL 
    OR tar_nr_alcalinidade IS NOT NULL)
ORDER BY tar_dt_medicao DESC 
LIMIT 5;