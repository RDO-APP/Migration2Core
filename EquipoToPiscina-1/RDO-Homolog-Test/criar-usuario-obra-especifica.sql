-- Criar usuário de teste para obra específica
-- Isso vai acelerar o carregamento e facilitar os testes

-- 1. Inserir novo colaborador
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
);

-- 2. Obter o ID do colaborador criado
SET @colaborador_id = LAST_INSERT_ID();

-- 3. Associar colaborador à obra ID 1 (primeira obra disponível)
-- Verificar se existe grupo (assumindo grupo ID 1 para contratada)
INSERT INTO obra_colaborador (
    oco_id_obra,
    oco_id_colaborador,
    oco_id_grupo,
    oco_id_cargo,
    oco_st_contratante_contratada,
    oco_st_ativo
) VALUES (
    1,  -- ID da obra (ajustar conforme necessário)
    @colaborador_id,
    1,  -- ID do grupo (ajustar conforme necessário)
    1,  -- ID do cargo (ajustar conforme necessário)
    'd', -- 'd' para contratada, 't' para contratante
    's'
);

-- 4. Verificar se foi criado corretamente
SELECT 
    c.col_id_colaborador,
    c.col_nm_colaborador,
    c.col_nr_cpf,
    o.obr_nm_obra,
    oc.oco_st_contratante_contratada
FROM colaborador c
JOIN obra_colaborador oc ON c.col_id_colaborador = oc.oco_id_colaborador
JOIN obra o ON oc.oco_id_obra = o.obr_id_obra
WHERE c.col_nr_cpf = '11111111111';