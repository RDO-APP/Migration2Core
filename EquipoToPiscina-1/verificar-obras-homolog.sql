-- Verificar obras disponíveis no banco homolog
SELECT 
    obr_id_obra as Id,
    obr_ds_obra as Descricao,
    obr_dt_inicio as DataInicio,
    obr_dt_previsao_fim as DataPrevisaoFim,
    obr_id_colaborador as ColaboradorId
FROM obra 
ORDER BY obr_id_obra;

-- Verificar etapas disponíveis
SELECT 
    etp_id_etapa as Id,
    etp_ds_etapa as Descricao,
    etp_id_obra as ObraId
FROM etapa 
ORDER BY etp_id_obra, etp_id_etapa;

-- Verificar tarefas disponíveis
SELECT 
    tar_id_tarefa as Id,
    tar_ds_tarefa as Descricao,
    tar_id_etapa as EtapaId,
    tar_id_obra as ObraId
FROM tarefa 
ORDER BY tar_id_obra, tar_id_etapa, tar_id_tarefa;