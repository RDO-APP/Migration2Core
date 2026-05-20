-- VERIFICAR SE COLABORADOR FOI SALVO COM SUCESSO
-- Data: 27/12/2024

-- 1. VERIFICAR COLABORADOR NA TABELA colaborador
SELECT 
    col_id_colaborador,
    col_nr_cpf,
    col_nm_colaborador,
    col_ds_email,
    col_ds_telefone_principal,
    col_ds_logradouro,
    col_ds_numero,
    col_ds_cep
FROM colaborador 
WHERE col_nr_cpf = '12345678909'  -- CPF sem formatação
   OR col_nm_colaborador LIKE '%Usuario Teste%'
ORDER BY col_id_colaborador DESC;

-- 2. VERIFICAR RELACIONAMENTO obra_colaborador
SELECT 
    oco.oco_id_obra_colaborador,
    oco.oco_id_obra,
    oco.oco_id_colaborador,
    oco.oco_id_cargo,
    oco.oco_id_grupo,
    oco.oco_dt_contratacao,
    c.col_nm_colaborador,
    c.col_nr_cpf,
    car.car_ds_cargo,
    g.gru_nm_nome
FROM obra_colaborador oco
INNER JOIN colaborador c ON c.col_id_colaborador = oco.oco_id_colaborador
LEFT JOIN cargo car ON car.car_id_cargo = oco.oco_id_cargo
LEFT JOIN grupo g ON g.gru_id_grupo = oco.oco_id_grupo
WHERE c.col_nr_cpf = '12345678909'
   OR c.col_nm_colaborador LIKE '%Usuario Teste%'
ORDER BY oco.oco_id_obra_colaborador DESC;

-- 3. CONTAR TOTAL DE COLABORADORES
SELECT COUNT(*) as total_colaboradores FROM colaborador;

-- 4. ÚLTIMOS 5 COLABORADORES CRIADOS
SELECT 
    col_id_colaborador,
    col_nr_cpf,
    col_nm_colaborador,
    col_ds_email
FROM colaborador 
ORDER BY col_id_colaborador DESC 
LIMIT 5;