-- Criar dados de teste para etapas e tarefas
-- Execute no DBeaver conectado ao banco piscinas_rdoapp_homologa

-- Primeiro, verificar se já existem dados
SELECT 'OBRAS EXISTENTES:' as info;
SELECT obr_id_obra as id, obr_ds_nome as nome FROM obra;

SELECT 'USUÁRIOS EXISTENTES:' as info;
SELECT usr_id_usuario as id, usr_ds_nome as nome, usr_ds_cpf as cpf, usr_id_obra as idObra 
FROM usuario WHERE usr_ds_cpf = '567.065.455-20';

-- Se não houver obra, criar uma obra de teste
INSERT IGNORE INTO obra (obr_id_obra, obr_ds_nome, obr_bl_ativo, obr_ds_endereco, obr_ds_cidade, obr_ds_estado, obr_ds_cep) 
VALUES (1, 'Obra Teste Piscinas', 1, 'Rua Teste, 123', 'São Paulo', 'SP', '01234-567');

-- Se não houver usuário, atualizar o usuário existente para ter uma obra
UPDATE usuario 
SET usr_id_obra = 1 
WHERE usr_ds_cpf = '567.065.455-20' AND (usr_id_obra IS NULL OR usr_id_obra = 0);

-- Criar etapas de teste se não existirem
INSERT IGNORE INTO etapa (eta_id_etapa, eta_ds_etapa, eta_id_obra, eta_nr_orderm) VALUES
(1, 'Preparação da Piscina', 1, 1),
(2, 'Limpeza e Manutenção', 1, 2),
(3, 'Tratamento Químico', 1, 3);

-- Criar tarefas de teste se não existirem
INSERT IGNORE INTO tarefa (tar_id_tarefa, tar_ds_tarefa, tar_id_etapa, tar_id_status, tar_nr_agrupador, tar_dt_inicio, tar_dt_previsao_fim) VALUES
(1, 'Aspiração do fundo da piscina', 1, 2, UUID(), '2025-01-01', '2025-01-05'),
(2, 'Limpeza das bordas', 1, 2, UUID(), '2025-01-06', '2025-01-10'),
(3, 'Verificação do sistema de filtração', 2, 1, UUID(), '2025-01-16', '2025-01-20'),
(4, 'Teste de pH da água', 3, 1, UUID(), '2025-02-01', '2025-02-05'),
(5, 'Aplicação de cloro', 3, 1, UUID(), '2025-02-06', '2025-02-10');

-- Verificar se os dados foram criados
SELECT 'ETAPAS CRIADAS:' as info;
SELECT e.eta_id_etapa as id, e.eta_ds_etapa as titulo, e.eta_id_obra as idObra FROM etapa e ORDER BY e.eta_id_etapa;

SELECT 'TAREFAS CRIADAS:' as info;
SELECT t.tar_id_tarefa as id, t.tar_ds_tarefa as descricao, t.tar_id_etapa as idEtapa, t.tar_id_status as status FROM tarefa t ORDER BY t.tar_id_tarefa;

SELECT 'ETAPAS COM TAREFAS:' as info;
SELECT 
    e.eta_id_etapa as etapa_id,
    e.eta_ds_etapa as etapa_titulo,
    COUNT(t.tar_id_tarefa) as total_tarefas
FROM etapa e
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
WHERE e.eta_id_obra = 1
GROUP BY e.eta_id_etapa, e.eta_ds_etapa
ORDER BY e.eta_id_etapa;