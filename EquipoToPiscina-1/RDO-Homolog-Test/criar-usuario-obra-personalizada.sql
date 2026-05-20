-- Criar usuário para obra específica personalizada
-- INSTRUCOES: 
-- 1. Execute primeiro: identificar-obra-atual.sql
-- 2. Escolha o ID da obra desejada
-- 3. Altere a variável @obra_id abaixo
-- 4. Execute este script

-- ===== CONFIGURACAO =====
-- ALTERE AQUI O ID DA OBRA DESEJADA:
SET @obra_id = 1;  -- <-- ALTERAR ESTE NUMERO

-- Credenciais do novo usuário
SET @cpf_usuario = '22222222222';
SET @senha_usuario = '1234';
SET @nome_usuario = 'Teste Obra Especifica';

-- ===== EXECUCAO =====

-- 1. Verificar se a obra existe
SELECT 'VERIFICANDO OBRA ESCOLHIDA:' as info;
SELECT 
    obr_id_obra as ID,
    obr_nm_obra as NOME,
    obr_dt_inicio as INICIO,
    CASE 
        WHEN obr_dt_fim IS NULL OR obr_dt_fim > NOW() THEN 'ATIVA'
        ELSE 'FINALIZADA'
    END as STATUS
FROM obra 
WHERE obr_id_obra = @obra_id;

-- 2. Criar o colaborador (se não existir)
INSERT INTO colaborador (
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha,
    col_dt_nascimento,
    col_st_ativo
) VALUES (
    @nome_usuario,
    @cpf_usuario,
    @senha_usuario,
    '1990-01-01',
    's'
) ON DUPLICATE KEY UPDATE 
    col_nm_colaborador = @nome_usuario,
    col_ds_senha = @senha_usuario;

-- 3. Obter ID do colaborador
SET @colaborador_id = (SELECT col_id_colaborador FROM colaborador WHERE col_nr_cpf = @cpf_usuario);

-- 4. Verificar se existem grupo e cargo válidos
SELECT 'GRUPOS E CARGOS DISPONIVEIS:' as info;
SELECT 'Grupos:' as tipo, gru_id_grupo as id, gru_nm_nome as nome FROM grupo LIMIT 3
UNION ALL
SELECT 'Cargos:' as tipo, car_id_cargo as id, car_ds_cargo as nome FROM cargo LIMIT 3;

-- 5. Associar colaborador à obra específica
INSERT INTO obra_colaborador (
    oco_id_obra,
    oco_id_colaborador,
    oco_id_grupo,
    oco_id_cargo,
    oco_st_contratante_contratada,
    oco_st_ativo
) VALUES (
    @obra_id,
    @colaborador_id,
    (SELECT MIN(gru_id_grupo) FROM grupo),  -- Primeiro grupo disponível
    (SELECT MIN(car_id_cargo) FROM cargo),  -- Primeiro cargo disponível
    'd',  -- 'd' = contratada, 't' = contratante
    's'
) ON DUPLICATE KEY UPDATE 
    oco_st_ativo = 's';

-- 6. Verificar resultado final
SELECT 'USUARIO CRIADO COM SUCESSO:' as info;
SELECT 
    c.col_nm_colaborador as NOME,
    c.col_nr_cpf as CPF,
    c.col_ds_senha as SENHA,
    o.obr_nm_obra as OBRA,
    oc.oco_st_contratante_contratada as TIPO,
    g.gru_nm_nome as GRUPO,
    car.car_ds_cargo as CARGO
FROM colaborador c
JOIN obra_colaborador oc ON c.col_id_colaborador = oc.oco_id_colaborador
JOIN obra o ON oc.oco_id_obra = o.obr_id_obra
JOIN grupo g ON oc.oco_id_grupo = g.gru_id_grupo
JOIN cargo car ON oc.oco_id_cargo = car.car_id_cargo
WHERE c.col_nr_cpf = @cpf_usuario AND o.obr_id_obra = @obra_id;