-- Verificar dados básicos no banco piscinas_rdoapp_homologa
-- Execute no DBeaver

-- 1. Verificar se há obras
SELECT COUNT(*) as total_obras FROM obra;
SELECT obr_id_obra as id, obr_ds_nome as nome FROM obra LIMIT 5;

-- 2. Verificar se há usuários
SELECT COUNT(*) as total_usuarios FROM usuario;
SELECT usr_id_usuario as id, usr_ds_nome as nome, usr_ds_cpf as cpf, usr_id_obra as idObra 
FROM usuario WHERE usr_ds_cpf = '567.065.455-20';

-- 3. Verificar se há etapas
SELECT COUNT(*) as total_etapas FROM etapa;
SELECT eta_id_etapa as id, eta_ds_etapa as titulo, eta_id_obra as idObra FROM etapa LIMIT 5;

-- 4. Verificar se há tarefas
SELECT COUNT(*) as total_tarefas FROM tarefa;
SELECT tar_id_tarefa as id, tar_ds_tarefa as descricao, tar_id_etapa as idEtapa, tar_id_status as status FROM tarefa LIMIT 5;

-- 5. Verificar estrutura das tabelas
DESCRIBE etapa;
DESCRIBE tarefa;