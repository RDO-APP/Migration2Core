-- VERIFICAÇÃO COMPLETA DA ESTRUTURA DO BANCO PARA LAUDO

-- 1. Verificar se os campos de laudo existem na tabela tarefa
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'tarefa' 
AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
AND (
    COLUMN_NAME LIKE '%nivel%' OR 
    COLUMN_NAME LIKE '%ph%' OR 
    COLUMN_NAME LIKE '%alcalin%' OR 
    COLUMN_NAME LIKE '%limpidez%' OR
    COLUMN_NAME LIKE '%superficie%' OR
    COLUMN_NAME LIKE '%fundo%' OR
    COLUMN_NAME LIKE '%proliferacao%' OR
    COLUMN_NAME LIKE '%detritos%'
)
ORDER BY COLUMN_NAME;

-- 2. Verificar se existem tarefas na base
SELECT COUNT(*) as total_tarefas FROM tarefa;

-- 3. Verificar tarefas recentes (últimas 24h)
SELECT 
    COUNT(*) as tarefas_ultimas_24h,
    MAX(tar_dt_ultima_atualizacao) as ultima_atualizacao
FROM tarefa 
WHERE tar_dt_ultima_atualizacao >= NOW() - INTERVAL 1 DAY;

-- 4. Verificar se alguma tarefa já tem dados de laudo
SELECT 
    COUNT(*) as tarefas_com_laudo_cloro,
    COUNT(CASE WHEN tar_nr_ph IS NOT NULL THEN 1 END) as tarefas_com_laudo_ph,
    COUNT(CASE WHEN tar_nr_alcalinidade IS NOT NULL THEN 1 END) as tarefas_com_laudo_alcalinidade
FROM tarefa 
WHERE tar_nr_nivel_cloro IS NOT NULL;

-- 5. Mostrar algumas tarefas de exemplo para teste
SELECT 
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_id_status,
    tar_dt_ultima_atualizacao,
    tar_nr_nivel_cloro,
    tar_nr_ph,
    tar_nr_alcalinidade
FROM tarefa 
ORDER BY tar_dt_ultima_atualizacao DESC
LIMIT 10;

-- 6. Verificar se há alguma constraint ou trigger que possa estar impedindo o update
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME = 'tarefa' 
AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa';

-- 7. Verificar permissões na tabela tarefa
SHOW GRANTS FOR CURRENT_USER();