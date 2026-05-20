-- Verificar se os laudos foram salvos corretamente
-- Execute no DBeaver conectado ao banco piscinas_rdoapp_homologa

-- 1. Verificar laudos recém-criados
SELECT 
    lau_id_laudo,
    lau_dt_laudo,
    lau_id_status,
    lau_id_obra,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_limpidez,
    lau_tp_superficie,
    lau_tp_fundo,
    lau_tp_nivel_cloro_2,
    lau_ds_comentario_geracao,
    lau_dt_geracao
FROM laudo 
WHERE lau_id_laudo IN (4, 5)
ORDER BY lau_id_laudo DESC;

-- 2. Verificar todos os laudos da obra 233
SELECT 
    lau_id_laudo,
    lau_dt_laudo,
    lau_id_status,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_limpidez
FROM laudo 
WHERE lau_id_obra = 233
ORDER BY lau_dt_geracao DESC;

-- 3. Verificar status disponíveis
SELECT 
    str_id_status,
    str_ds_status
FROM status_rdo
ORDER BY str_id_status;