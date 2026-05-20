-- Criar usuário automaticamente para a obra que está sendo mais usada para teste
-- Este script detecta automaticamente qual obra você está usando e cria um usuário dedicado

-- 1. Detectar a obra com mais atividade de teste (laudos recentes)
SET @obra_teste = (
    SELECT o.obr_id_obra
    FROM obra o
    LEFT JOIN laudo l ON o.obr_id_obra = l.lau_id_obra
    LEFT JOIN etapa e ON o.obr_id_obra = e.eta_id_obra
    LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
    GROUP BY o.obr_id_obra
    ORDER BY COUNT(DISTINCT l.lau_id_laudo) DESC, COUNT(DISTINCT t.tar_id_tarefa) DESC
    LIMIT 1
);

-- 2. Mostrar qual obra foi detectada
SELECT 'OBRA DETECTADA PARA TESTE:' as info;
SELECT 
    obr_id_obra as ID_OBRA,
    obr_nm_obra as NOME_OBRA,
    obr_dt_inicio as DATA_INICIO,
    CASE 
        WHEN obr_dt_fim IS NULL OR obr_dt_fim > NOW() THEN 'ATIVA'
        ELSE 'FINALIZADA'
    END as STATUS
FROM obra 
WHERE obr_id_obra = @obra_teste;

-- 3. Configurar credenciais do novo usuário
SET @cpf_usuario = '99999999999';
SET @senha_usuario = '1234';
SET @nome_usuario = 'Teste Rapido Obra';

-- 4. Criar o colaborador (se não existir)
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

-- 5. Obter ID do colaborador
SET @colaborador_id = (SELECT col_id_colaborador FROM colaborador WHERE col_nr_cpf = @cpf_usuario);

-- 6. Associar colaborador à obra detectada
INSERT INTO obra_colaborador (
    oco_id_obra,
    oco_id_colaborador,
    oco_id_grupo,
    oco_id_cargo,
    oco_st_contratante_contratada,
    oco_st_ativo
) VALUES (
    @obra_teste,
    @colaborador_id,
    (SELECT MIN(gru_id_grupo) FROM grupo WHERE gru_st_ativo = 's'),
    (SELECT MIN(car_id_cargo) FROM cargo WHERE car_st_ativo = 's'),
    'd',  -- contratada
    's'
) ON DUPLICATE KEY UPDATE 
    oco_st_ativo = 's';

-- 7. Verificar resultado final
SELECT 'USUARIO CRIADO AUTOMATICAMENTE:' as info;
SELECT 
    c.col_nm_colaborador as NOME,
    c.col_nr_cpf as CPF,
    c.col_ds_senha as SENHA,
    o.obr_nm_obra as OBRA_DETECTADA,
    o.obr_id_obra as ID_OBRA,
    oc.oco_st_contratante_contratada as TIPO
FROM colaborador c
JOIN obra_colaborador oc ON c.col_id_colaborador = oc.oco_id_colaborador
JOIN obra o ON oc.oco_id_obra = o.obr_id_obra
WHERE c.col_nr_cpf = @cpf_usuario AND o.obr_id_obra = @obra_teste;

-- 8. Mostrar estatísticas da obra escolhida
SELECT 'ESTATISTICAS DA OBRA ESCOLHIDA:' as info;
SELECT 
    COUNT(DISTINCT l.lau_id_laudo) as TOTAL_LAUDOS,
    COUNT(DISTINCT e.eta_id_etapa) as TOTAL_ETAPAS,
    COUNT(DISTINCT t.tar_id_tarefa) as TOTAL_TAREFAS,
    MAX(l.lau_dt_geracao) as ULTIMO_LAUDO_CRIADO
FROM obra o
LEFT JOIN laudo l ON o.obr_id_obra = l.lau_id_obra
LEFT JOIN etapa e ON o.obr_id_obra = e.eta_id_obra
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
WHERE o.obr_id_obra = @obra_teste;