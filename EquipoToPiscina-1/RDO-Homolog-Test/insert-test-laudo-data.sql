-- Script para inserir dados de teste do laudo diretamente no banco
-- Execute este comando no DBeaver para testar os dados do laudo

-- Primeiro, vamos verificar as tarefas existentes
SELECT tar_id_tarefa, tar_ds_tarefa, tar_nr_nivel_cloro, tar_nr_ph, tar_nr_alcalinidade, tar_tp_limpidez
FROM tarefa 
WHERE tar_id_tarefa IN (SELECT MAX(tar_id_tarefa) FROM tarefa)
LIMIT 5;

-- Inserir dados de teste do laudo na tarefa mais recente
UPDATE tarefa 
SET 
    tar_nr_nivel_cloro = 3,  -- 1,5 < 2,0
    tar_nr_ph = 4,           -- 7.4 < 7.6  
    tar_nr_alcalinidade = 3, -- 90 < 100
    tar_tp_limpidez = 'sim',
    tar_tp_superficie = 'sim',
    tar_tp_fundo = 'nao',
    tar_tp_proliferacao = 'nao',
    tar_tp_detritos = 'sim'
WHERE tar_id_tarefa = (SELECT MAX(tar_id_tarefa) FROM (SELECT tar_id_tarefa FROM tarefa) AS t);

-- Verificar se os dados foram inseridos
SELECT tar_id_tarefa, tar_ds_tarefa, tar_nr_nivel_cloro, tar_nr_ph, tar_nr_alcalinidade, tar_tp_limpidez, tar_tp_superficie, tar_tp_fundo, tar_tp_proliferacao, tar_tp_detritos
FROM tarefa 
WHERE tar_id_tarefa = (SELECT MAX(tar_id_tarefa) FROM (SELECT tar_id_tarefa FROM tarefa) AS t);

-- Verificar se os dados aparecem no histórico
SELECT 
    t.tar_id_tarefa,
    t.tar_ds_tarefa,
    t.tar_dt_medicao,
    t.tar_nr_nivel_cloro,
    t.tar_nr_ph,
    t.tar_nr_alcalinidade,
    t.tar_tp_limpidez,
    t.tar_tp_superficie,
    t.tar_tp_fundo,
    t.tar_tp_proliferacao,
    t.tar_tp_detritos
FROM tarefa t
WHERE t.tar_id_tarefa = (SELECT MAX(tar_id_tarefa) FROM (SELECT tar_id_tarefa FROM tarefa) AS t2)
ORDER BY t.tar_dt_medicao DESC;