-- Verificar o último colaborador criado no banco homologa
-- Para encontrar o usuário teste que você criou

-- 1. Últimos colaboradores criados (ordenado por data de inserção)
SELECT 
    col_id_colaborador,
    col_ds_nome,
    col_ds_cpf,
    col_ds_email,
    col_fl_ativo,
    col_dt_insercao,
    col_dt_ultima_atualizacao
FROM colaborador 
WHERE col_fl_ativo = 'S'
ORDER BY col_dt_insercao DESC 
LIMIT 10;

-- 2. Último colaborador criado com suas obras
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    c.col_fl_ativo,
    c.col_dt_insercao,
    COUNT(o.obr_id_obra) as total_obras,
    GROUP_CONCAT(o.obr_ds_descricao SEPARATOR ' | ') as obras
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, c.col_fl_ativo, c.col_dt_insercao
ORDER BY c.col_dt_insercao DESC 
LIMIT 5;

-- 3. Colaboradores criados hoje ou nos últimos dias
SELECT 
    col_id_colaborador,
    col_ds_nome,
    col_ds_cpf,
    col_ds_email,
    col_fl_ativo,
    col_dt_insercao,
    DATEDIFF(NOW(), col_dt_insercao) as dias_desde_criacao
FROM colaborador 
WHERE col_fl_ativo = 'S'
  AND col_dt_insercao >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY col_dt_insercao DESC;

-- 4. Verificar se existe colaborador com data de inserção recente e poucas obras
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    c.col_dt_insercao,
    COUNT(o.obr_id_obra) as total_obras
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
  AND c.col_dt_insercao >= '2024-12-01'  -- Dezembro 2024 em diante
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, c.col_dt_insercao
HAVING COUNT(o.obr_id_obra) <= 2  -- Máximo 2 obras
ORDER BY c.col_dt_insercao DESC;