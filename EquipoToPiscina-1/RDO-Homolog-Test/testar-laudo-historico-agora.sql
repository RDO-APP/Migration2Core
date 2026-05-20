-- Teste: Verificar dados de laudo e histórico
-- Execute no DBeaver

-- 1. Verificar tarefas recentes com dados de laudo
SELECT 
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_nr_agrupador,
    tar_dt_medicao,
    tar_nr_nivel_cloro,
    tar_nr_ph,
    tar_nr_alcalinidade,
    tar_nr_limpidez,
    tar_nr_superficie,
    tar_nr_fundo,
    tar_nr_nivel_detritos,
    tar_nr_nivel_proliferacao
FROM tarefa 
WHERE tar_dt_medicao >= '2025-12-20'
ORDER BY tar_dt_ultima_atualizacao DESC;

-- 2. Verificar se há tarefas com mesmo agrupador
SELECT 
    tar_nr_agrupador,
    COUNT(*) as total_tarefas,
    GROUP_CONCAT(tar_id_tarefa ORDER BY tar_dt_medicao DESC) as ids_tarefas,
    MAX(tar_dt_medicao) as ultima_medicao
FROM tarefa 
WHERE tar_nr_agrupador IS NOT NULL
GROUP BY tar_nr_agrupador
HAVING total_tarefas > 1
ORDER BY ultima_medicao DESC
LIMIT 5;

-- 3. Se necessário, criar dados de teste para histórico
-- (Execute apenas se não houver dados de histórico)
/*
-- Pegar uma tarefa existente para criar histórico
SET @tarefa_id = (SELECT tar_id_tarefa FROM tarefa WHERE tar_dt_medicao >= '2025-12-20' LIMIT 1);
SET @agrupador = (SELECT tar_nr_agrupador FROM tarefa WHERE tar_id_tarefa = @tarefa_id);

-- Inserir uma segunda medição para a mesma tarefa (mesmo agrupador)
INSERT INTO tarefa (
    tar_ds_tarefa, tar_nr_agrupador, tar_dt_medicao, tar_dt_inicio, tar_dt_previsao_fim,
    tar_id_status, tar_id_etapa, tar_id_colaborador, tar_id_unidade,
    tar_nr_nivel_cloro, tar_nr_ph, tar_nr_alcalinidade, tar_nr_limpidez,
    tar_nr_superficie, tar_nr_fundo, tar_nr_nivel_detritos, tar_nr_nivel_proliferacao,
    tar_dt_medicao_hora_inicial, tar_dt_medicao_hora_final
)
SELECT 
    tar_ds_tarefa, 
    tar_nr_agrupador,
    DATE_SUB(tar_dt_medicao, INTERVAL 1 DAY) as tar_dt_medicao,
    tar_dt_inicio, 
    tar_dt_previsao_fim,
    2 as tar_id_status, -- Em Execução
    tar_id_etapa, 
    tar_id_colaborador, 
    tar_id_unidade,
    2 as tar_nr_nivel_cloro,    -- 0,5 < 1,0
    3 as tar_nr_ph,             -- 7.2 < 7.4
    2 as tar_nr_alcalinidade,   -- 70 < 80
    1 as tar_nr_limpidez,       -- Sim
    1 as tar_nr_superficie,     -- Sim
    0 as tar_nr_fundo,          -- Não
    0 as tar_nr_nivel_detritos, -- Não
    0 as tar_nr_nivel_proliferacao, -- Não
    '14:00:00' as tar_dt_medicao_hora_inicial,
    '15:00:00' as tar_dt_medicao_hora_final
FROM tarefa 
WHERE tar_id_tarefa = @tarefa_id;
*/