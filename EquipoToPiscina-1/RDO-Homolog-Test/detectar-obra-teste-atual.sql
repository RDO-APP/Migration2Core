-- Detectar qual obra está sendo usada para testes
-- Analisa atividade recente para identificar a obra de teste

-- 1. LAUDOS MAIS RECENTES (onde você está testando)
SELECT 'LAUDOS RECENTES - OBRA DE TESTE:' as info;
SELECT 
    l.lau_id_laudo as ID_LAUDO,
    l.lau_dt_laudo as DATA_LAUDO,
    l.lau_dt_geracao as DATA_CRIACAO,
    o.obr_id_obra as ID_OBRA,
    o.obr_nm_obra as NOME_OBRA,
    c.col_nm_colaborador as COLABORADOR,
    c.col_nr_cpf as CPF
FROM laudo l
JOIN obra o ON l.lau_id_obra = o.obr_id_obra
LEFT JOIN colaborador c ON l.lau_id_colaborador = c.col_id_colaborador
ORDER BY l.lau_dt_geracao DESC
LIMIT 10;

-- 2. TAREFAS MAIS RECENTES (atividade de teste)
SELECT 'TAREFAS RECENTES - ATIVIDADE DE TESTE:' as info;
SELECT 
    t.tar_id_tarefa as ID_TAREFA,
    t.tar_dt_medicao as DATA_MEDICAO,
    t.tar_dt_ultima_atualizacao as ULTIMA_ATUALIZACAO,
    o.obr_id_obra as ID_OBRA,
    o.obr_nm_obra as NOME_OBRA,
    t.tar_ds_tarefa as DESCRICAO_TAREFA,
    c.col_nm_colaborador as COLABORADOR
FROM tarefa t
JOIN etapa e ON t.tar_id_etapa = e.eta_id_etapa
JOIN obra o ON e.eta_id_obra = o.obr_id_obra
LEFT JOIN colaborador c ON t.tar_id_colaborador_insercao = c.col_id_colaborador
WHERE t.tar_dt_ultima_atualizacao >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY t.tar_dt_ultima_atualizacao DESC
LIMIT 10;

-- 3. OBRA COM MAIS ATIVIDADE RECENTE
SELECT 'OBRA COM MAIS ATIVIDADE (PROVAVEL TESTE):' as info;
SELECT 
    o.obr_id_obra as ID_OBRA,
    o.obr_nm_obra as NOME_OBRA,
    COUNT(DISTINCT l.lau_id_laudo) as TOTAL_LAUDOS,
    COUNT(DISTINCT t.tar_id_tarefa) as TOTAL_TAREFAS_RECENTES,
    MAX(l.lau_dt_geracao) as ULTIMO_LAUDO,
    MAX(t.tar_dt_ultima_atualizacao) as ULTIMA_TAREFA
FROM obra o
LEFT JOIN laudo l ON o.obr_id_obra = l.lau_id_obra
LEFT JOIN etapa e ON o.obr_id_obra = e.eta_id_obra
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa 
    AND t.tar_dt_ultima_atualizacao >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY o.obr_id_obra, o.obr_nm_obra
HAVING (TOTAL_LAUDOS > 0 OR TOTAL_TAREFAS_RECENTES > 0)
ORDER BY TOTAL_LAUDOS DESC, TOTAL_TAREFAS_RECENTES DESC
LIMIT 5;

-- 4. COLABORADOR MAIS ATIVO (você)
SELECT 'COLABORADOR MAIS ATIVO (USUARIO DE TESTE):' as info;
SELECT 
    c.col_id_colaborador as ID_COLABORADOR,
    c.col_nm_colaborador as NOME,
    c.col_nr_cpf as CPF,
    COUNT(DISTINCT l.lau_id_laudo) as LAUDOS_CRIADOS,
    COUNT(DISTINCT t.tar_id_tarefa) as TAREFAS_ATUALIZADAS,
    MAX(l.lau_dt_geracao) as ULTIMO_LAUDO,
    MAX(t.tar_dt_ultima_atualizacao) as ULTIMA_TAREFA
FROM colaborador c
LEFT JOIN laudo l ON c.col_id_colaborador = l.lau_id_colaborador
LEFT JOIN tarefa t ON c.col_id_colaborador = t.tar_id_colaborador_insercao
    AND t.tar_dt_ultima_atualizacao >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY c.col_id_colaborador, c.col_nm_colaborador, c.col_nr_cpf
HAVING (LAUDOS_CRIADOS > 0 OR TAREFAS_ATUALIZADAS > 0)
ORDER BY LAUDOS_CRIADOS DESC, TAREFAS_ATUALIZADAS DESC
LIMIT 5;

-- 5. RESUMO FINAL - OBRA RECOMENDADA PARA USUARIO DEDICADO
SELECT 'RECOMENDACAO - OBRA PARA USUARIO DEDICADO:' as info;
SELECT 
    o.obr_id_obra as ID_OBRA_RECOMENDADA,
    o.obr_nm_obra as NOME_OBRA,
    COUNT(DISTINCT l.lau_id_laudo) as LAUDOS_TESTE,
    COUNT(DISTINCT t.tar_id_tarefa) as TAREFAS_ATIVAS,
    COUNT(DISTINCT e.eta_id_etapa) as ETAPAS_DISPONIVEIS,
    CASE 
        WHEN COUNT(DISTINCT l.lau_id_laudo) > 0 THEN 'OBRA COM TESTES DE LAUDO'
        WHEN COUNT(DISTINCT t.tar_id_tarefa) > 0 THEN 'OBRA COM ATIVIDADE RECENTE'
        ELSE 'OBRA DISPONIVEL'
    END as MOTIVO_RECOMENDACAO
FROM obra o
LEFT JOIN laudo l ON o.obr_id_obra = l.lau_id_obra
LEFT JOIN etapa e ON o.obr_id_obra = e.eta_id_obra
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
GROUP BY o.obr_id_obra, o.obr_nm_obra
ORDER BY LAUDOS_TESTE DESC, TAREFAS_ATIVAS DESC, ETAPAS_DISPONIVEIS DESC
LIMIT 3;