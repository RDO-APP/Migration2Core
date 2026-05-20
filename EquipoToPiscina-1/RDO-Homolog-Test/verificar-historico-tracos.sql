-- VERIFICAR POR QUE HISTÓRICO AINDA MOSTRA TRAÇOS
-- Este script verifica se os laudos estão sendo salvos e se a integração está funcionando

-- 1. Verificar se laudos foram salvos recentemente
SELECT TOP 10 
    lau_id_laudo,
    lau_id_obra,
    lau_dt_laudo,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_limpidez,
    lau_tp_superficie,
    lau_tp_fundo,
    lau_tp_nivel_proliferacao,
    lau_tp_nivel_bacterias,
    lau_dt_geracao
FROM laudo 
ORDER BY lau_dt_geracao DESC;

-- 2. Verificar tarefas recentes
SELECT TOP 10
    tar_id_tarefa,
    tar_ds_tarefa,
    tar_dt_medicao,
    tar_id_etapa,
    eta_id_obra
FROM tarefa t
INNER JOIN etapa e ON t.tar_id_etapa = e.eta_id_etapa
ORDER BY tar_dt_medicao DESC;

-- 3. Verificar se existe JOIN entre laudo e tarefa
SELECT TOP 10
    t.tar_id_tarefa,
    t.tar_dt_medicao,
    e.eta_id_obra,
    l.lau_id_laudo,
    l.lau_dt_laudo,
    l.lau_tp_nivel_cloro,
    l.lau_tp_ph,
    l.lau_tp_limpidez
FROM tarefa t
INNER JOIN etapa e ON t.tar_id_etapa = e.eta_id_etapa
LEFT JOIN laudo l ON (
    l.lau_id_obra = e.eta_id_obra 
    AND YEAR(l.lau_dt_laudo) = YEAR(t.tar_dt_medicao)
    AND MONTH(l.lau_dt_laudo) = MONTH(t.tar_dt_medicao)
    AND DAY(l.lau_dt_laudo) = DAY(t.tar_dt_medicao)
)
ORDER BY t.tar_dt_medicao DESC;

-- 4. Verificar laudos de hoje especificamente
SELECT 
    lau_id_laudo,
    lau_id_obra,
    lau_dt_laudo,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_limpidez,
    CASE 
        WHEN lau_tp_nivel_cloro = 1 THEN 'Sim'
        WHEN lau_tp_nivel_cloro = 0 THEN 'Não'
        ELSE 'NULL'
    END as Cloro_Formatado
FROM laudo 
WHERE CAST(lau_dt_laudo AS DATE) = CAST(GETDATE() AS DATE)
ORDER BY lau_dt_geracao DESC;