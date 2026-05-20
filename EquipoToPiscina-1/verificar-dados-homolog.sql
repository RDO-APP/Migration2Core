-- Verificar dados da unidade escolar específica no banco de homologação
-- Execute no DBeaver conectado ao banco piscinas_rdoapp_homologa

-- 1. Verificar se a unidade escolar existe
SELECT 
    obr_id_obra,
    obr_ds_obra,
    obr_dt_inicio,
    obr_dt_fim,
    obr_dt_previsao_fim
FROM obra 
WHERE obr_ds_obra LIKE '%CETI PROFESSORA ÁUREA DOS HUMILDES OLIVEIRA%'
   OR obr_ds_obra LIKE '%AUREA%'
   OR obr_ds_obra LIKE '%HUMILDES%';

-- 2. Listar todas as unidades escolares disponíveis
SELECT 
    obr_id_obra,
    obr_ds_obra,
    obr_dt_inicio,
    obr_dt_fim
FROM obra 
ORDER BY obr_ds_obra;

-- 3. Verificar etapas e tarefas de qualquer obra
SELECT 
    o.obr_ds_obra,
    e.eta_ds_etapa,
    t.tar_ds_tarefa,
    t.tar_id_tarefa
FROM obra o
LEFT JOIN etapa e ON e.eta_id_obra = o.obr_id_obra
LEFT JOIN tarefa t ON t.tar_id_etapa = e.eta_id_etapa
WHERE o.obr_id_obra IN (SELECT obr_id_obra FROM obra LIMIT 3)
ORDER BY o.obr_ds_obra, e.eta_ds_etapa, t.tar_ds_tarefa;

-- 4. Verificar laudos existentes
SELECT 
    l.lau_id_laudo,
    l.lau_dt_laudo,
    o.obr_ds_obra,
    l.lau_tp_nivel_cloro,
    l.lau_tp_ph,
    l.lau_tp_limpidez
FROM laudo l
JOIN obra o ON o.obr_id_obra = l.lau_id_obra
ORDER BY l.lau_dt_laudo DESC
LIMIT 10;