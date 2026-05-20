-- Verificar se os dados do laudo estão sendo salvos na tabela tarefa
SELECT 
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_dt_medicao,
    tar_nr_nivel_cloro,
    tar_nr_ph,
    tar_nr_alcalinidade,
    tar_nr_limpidez,
    tar_nr_superficie,
    tar_nr_fundo,
    tar_nr_nivel_detritos,
    tar_nr_nivel_proliferacao,
    tar_dt_ultima_atualizacao
FROM tarefa 
WHERE tar_dt_medicao >= '2025-12-23'  -- Dados de hoje
ORDER BY tar_dt_ultima_atualizacao DESC
LIMIT 10;