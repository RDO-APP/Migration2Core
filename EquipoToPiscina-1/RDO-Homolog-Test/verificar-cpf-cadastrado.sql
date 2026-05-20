-- VERIFICAR CPF CADASTRADO RECENTEMENTE
-- Buscar colaboradores criados hoje ou recentemente

SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF,
    col_dt_nascimento as DataNascimento,
    col_nr_telefone as Telefone,
    col_ds_email as Email,
    col_dt_insercao as DataCadastro
FROM colaborador 
WHERE col_nr_cpf LIKE '123%'
   OR col_dt_insercao >= CURDATE() - INTERVAL 1 DAY
ORDER BY col_dt_insercao DESC
LIMIT 10;

-- Verificar também na tabela obra_colaborador
SELECT DISTINCT
    c.col_nm_colaborador as Nome,
    c.col_nr_cpf as CPF,
    oc.oco_dt_insercao as DataAssociacao,
    o.obr_ds_obra as Obra
FROM obra_colaborador oc
JOIN colaborador c ON c.col_id_colaborador = oc.oco_id_colaborador  
JOIN obra o ON o.obr_id_obra = oc.oco_id_obra
WHERE c.col_nr_cpf LIKE '123%'
   OR oc.oco_dt_insercao >= CURDATE() - INTERVAL 1 DAY
ORDER BY oc.oco_dt_insercao DESC
LIMIT 5;