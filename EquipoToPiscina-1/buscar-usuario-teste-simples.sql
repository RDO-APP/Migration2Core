-- Busca simples pelo ultimo colaborador criado
-- Provavelmente e o usuario teste que voce criou

-- Consulta principal: ultimos 5 colaboradores criados
SELECT 
    col_id_colaborador as ID,
    col_ds_nome as NOME,
    col_ds_cpf as CPF,
    col_ds_email as EMAIL,
    col_dt_insercao as DATA_CRIACAO,
    col_fl_ativo as ATIVO
FROM colaborador 
WHERE col_fl_ativo = 'S'
ORDER BY col_dt_insercao DESC 
LIMIT 5;

-- Verificar quantas obras cada um tem
SELECT 
    c.col_ds_nome as NOME,
    c.col_ds_cpf as CPF,
    c.col_dt_insercao as DATA_CRIACAO,
    COUNT(o.obr_id_obra) as TOTAL_OBRAS
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
  AND c.col_dt_insercao >= '2024-12-01'
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_dt_insercao
ORDER BY c.col_dt_insercao DESC 
LIMIT 10;