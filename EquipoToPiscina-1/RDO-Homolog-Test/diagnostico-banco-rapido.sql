-- DIAGNÓSTICO RÁPIDO - Execute no DBeaver
-- Banco: piscinas_rdoapp_homologa

-- 1. VERIFICAR USUÁRIO E SUA OBRA
SELECT 
    usr_id_usuario as id_usuario,
    usr_ds_nome as nome_usuario, 
    usr_ds_cpf as cpf,
    usr_id_obra as id_obra
FROM usuario 
WHERE usr_ds_cpf = '567.065.455-20';

-- 2. VERIFICAR SE HÁ OBRAS
SELECT 
    obr_id_obra as id_obra,
    obr_ds_nome as nome_obra,
    obr_bl_ativo as ativo
FROM obra 
LIMIT 5;

-- 3. VERIFICAR SE HÁ ETAPAS
SELECT 
    eta_id_etapa as id_etapa,
    eta_ds_etapa as titulo_etapa,
    eta_id_obra as id_obra
FROM etapa 
LIMIT 5;

-- 4. VERIFICAR SE HÁ TAREFAS
SELECT 
    tar_id_tarefa as id_tarefa,
    tar_ds_tarefa as descricao_tarefa,
    tar_id_etapa as id_etapa,
    tar_id_status as status
FROM tarefa 
LIMIT 5;

-- 5. CONTAR REGISTROS
SELECT 
    'USUARIOS' as tabela, COUNT(*) as total FROM usuario
UNION ALL
SELECT 
    'OBRAS' as tabela, COUNT(*) as total FROM obra
UNION ALL
SELECT 
    'ETAPAS' as tabela, COUNT(*) as total FROM etapa
UNION ALL
SELECT 
    'TAREFAS' as tabela, COUNT(*) as total FROM tarefa;