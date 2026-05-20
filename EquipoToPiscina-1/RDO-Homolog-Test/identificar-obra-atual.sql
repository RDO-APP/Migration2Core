-- Identificar a obra que está sendo usada para teste
-- Para criar usuário específico para essa obra

-- 1. Ver qual obra o usuário atual (567.065.455-20) está usando
SELECT 'OBRA ATUAL DO USUARIO DE TESTE:' as info;
SELECT 
    o.obr_id_obra as ID_OBRA,
    o.obr_nm_obra as NOME_OBRA,
    o.obr_dt_inicio as DATA_INICIO,
    o.obr_dt_fim as DATA_FIM,
    c.col_nm_colaborador as COLABORADOR,
    c.col_nr_cpf as CPF
FROM obra o
JOIN obra_colaborador oc ON o.obr_id_obra = oc.oco_id_obra
JOIN colaborador c ON oc.oco_id_colaborador = c.col_id_colaborador
WHERE c.col_nr_cpf = '56706545520'
ORDER BY o.obr_id_obra;

-- 2. Ver todas as obras disponíveis (para escolher uma específica)
SELECT 'TODAS AS OBRAS DISPONIVEIS:' as info;
SELECT 
    obr_id_obra as ID,
    obr_nm_obra as NOME_OBRA,
    obr_dt_inicio as DATA_INICIO,
    CASE 
        WHEN obr_dt_fim IS NULL OR obr_dt_fim > NOW() THEN 'ATIVA'
        ELSE 'FINALIZADA'
    END as STATUS
FROM obra 
ORDER BY obr_id_obra
LIMIT 10;

-- 3. Ver quantas tarefas cada obra tem (para escolher uma com dados)
SELECT 'OBRAS COM TAREFAS (MELHORES PARA TESTE):' as info;
SELECT 
    o.obr_id_obra as ID_OBRA,
    o.obr_nm_obra as NOME_OBRA,
    COUNT(DISTINCT e.eta_id_etapa) as TOTAL_ETAPAS,
    COUNT(DISTINCT t.tar_id_tarefa) as TOTAL_TAREFAS
FROM obra o
LEFT JOIN etapa e ON o.obr_id_obra = e.eta_id_obra
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
GROUP BY o.obr_id_obra, o.obr_nm_obra
HAVING TOTAL_TAREFAS > 0
ORDER BY TOTAL_TAREFAS DESC
LIMIT 5;