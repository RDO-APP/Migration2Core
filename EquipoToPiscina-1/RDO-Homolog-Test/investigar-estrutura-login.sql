-- Investigar estrutura de login e obras
SELECT 'COLABORADORES' as tabela, COUNT(*) as total FROM colaborador;

-- Ver colaboradores existentes
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha
FROM colaborador 
LIMIT 5;

-- Ver obras disponíveis
SELECT 
    obr_id_obra,
    obr_nm_obra,
    obr_dt_inicio,
    obr_dt_fim
FROM obra 
ORDER BY obr_id_obra
LIMIT 10;

-- Ver relação obra_colaborador
SELECT 
    oco.oco_id_obra_colaborador,
    oco.oco_id_obra,
    oco.oco_id_colaborador,
    o.obr_nm_obra,
    c.col_nm_colaborador,
    c.col_nr_cpf
FROM obra_colaborador oco
JOIN obra o ON oco.oco_id_obra = o.obr_id_obra
JOIN colaborador c ON oco.oco_id_colaborador = c.col_id_colaborador
LIMIT 10;

-- Ver se existe alguma obra específica para teste
SELECT 
    o.obr_id_obra,
    o.obr_nm_obra,
    COUNT(oco.oco_id_obra_colaborador) as total_colaboradores
FROM obra o
LEFT JOIN obra_colaborador oco ON o.obr_id_obra = oco.oco_id_obra
GROUP BY o.obr_id_obra, o.obr_nm_obra
ORDER BY o.obr_id_obra
LIMIT 5;