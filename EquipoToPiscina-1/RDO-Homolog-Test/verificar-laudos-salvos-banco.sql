-- Verificar se os laudos estão sendo salvos no banco de dados
-- Execute este script no DBeaver para verificar

-- 1. Ver todos os laudos existentes (ordenados por mais recente)
SELECT 'TODOS OS LAUDOS NO BANCO:' as info;
SELECT 
    lau_id_laudo as ID,
    lau_dt_laudo as DATA_LAUDO,
    lau_dt_geracao as DATA_CRIACAO,
    lau_id_obra as ID_OBRA,
    lau_id_colaborador as ID_COLABORADOR,
    lau_tp_nivel_cloro as CLORO,
    lau_tp_ph as PH,
    lau_tp_alcalinidade as ALCALINIDADE,
    lau_tp_limpidez as LIMPIDEZ
FROM laudo 
ORDER BY lau_dt_geracao DESC
LIMIT 10;

-- 2. Ver laudos criados hoje
SELECT 'LAUDOS CRIADOS HOJE:' as info;
SELECT 
    lau_id_laudo as ID,
    lau_dt_laudo as DATA_LAUDO,
    lau_dt_geracao as DATA_CRIACAO,
    TIME(lau_dt_geracao) as HORA_CRIACAO,
    lau_id_obra as ID_OBRA
FROM laudo 
WHERE DATE(lau_dt_geracao) = CURDATE()
ORDER BY lau_dt_geracao DESC;

-- 3. Ver laudos do novo usuário (se conseguir identificar)
SELECT 'LAUDOS DO NOVO USUARIO:' as info;
SELECT 
    l.lau_id_laudo as ID,
    l.lau_dt_laudo as DATA_LAUDO,
    l.lau_dt_geracao as DATA_CRIACAO,
    c.col_nm_colaborador as COLABORADOR,
    c.col_nr_cpf as CPF,
    o.obr_nm_obra as OBRA
FROM laudo l
LEFT JOIN colaborador c ON l.lau_id_colaborador = c.col_id_colaborador
LEFT JOIN obra o ON l.lau_id_obra = o.obr_id_obra
WHERE c.col_nm_colaborador LIKE '%TESTE%' 
   OR c.col_nm_colaborador LIKE '%Usuario%'
   OR c.col_nr_cpf IN ('99999999999', '22222222222', '11111111111')
ORDER BY l.lau_dt_geracao DESC;

-- 4. Contar total de laudos por data
SELECT 'ESTATISTICAS POR DATA:' as info;
SELECT 
    DATE(lau_dt_geracao) as DATA,
    COUNT(*) as TOTAL_LAUDOS,
    COUNT(DISTINCT lau_id_obra) as OBRAS_DIFERENTES,
    COUNT(DISTINCT lau_id_colaborador) as COLABORADORES_DIFERENTES
FROM laudo 
WHERE lau_dt_geracao >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE(lau_dt_geracao)
ORDER BY DATA DESC;