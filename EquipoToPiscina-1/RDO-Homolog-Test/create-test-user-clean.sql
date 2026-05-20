-- Criar usuario de teste para obra especifica
-- Isso vai acelerar o carregamento e facilitar os testes

-- 1. Verificar obras disponiveis
SELECT 'OBRAS DISPONIVEIS:' as info;
SELECT 
    obr_id_obra as ID,
    obr_nm_obra as NOME_OBRA,
    obr_dt_inicio as DATA_INICIO
FROM obra 
ORDER BY obr_id_obra
LIMIT 5;

-- 2. Criar usuario de teste (se nao existir)
INSERT INTO colaborador (
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha,
    col_dt_nascimento,
    col_st_ativo
) VALUES (
    'Usuario Teste Obra',
    '11111111111',
    '1234',
    '1990-01-01',
    's'
) ON DUPLICATE KEY UPDATE col_nm_colaborador = col_nm_colaborador;

-- 3. Obter ID do colaborador
SET @colaborador_id = (SELECT col_id_colaborador FROM colaborador WHERE col_nr_cpf = '11111111111');

-- 4. Associar a primeira obra disponivel
INSERT IGNORE INTO obra_colaborador (
    oco_id_obra,
    oco_id_colaborador,
    oco_id_grupo,
    oco_id_cargo,
    oco_st_contratante_contratada,
    oco_st_ativo
) VALUES (
    1,
    @colaborador_id,
    1,
    1,
    'd',
    's'
);

-- 5. Verificar resultado
SELECT 'USUARIO CRIADO COM SUCESSO:' as info;
SELECT 
    c.col_nm_colaborador as NOME,
    c.col_nr_cpf as CPF,
    c.col_ds_senha as SENHA,
    o.obr_nm_obra as OBRA
FROM colaborador c
JOIN obra_colaborador oc ON c.col_id_colaborador = oc.oco_id_colaborador
JOIN obra o ON oc.oco_id_obra = o.obr_id_obra
WHERE c.col_nr_cpf = '11111111111';