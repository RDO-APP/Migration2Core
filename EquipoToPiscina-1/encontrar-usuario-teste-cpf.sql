-- Encontrar usuário teste com CPF que tem apenas uma obra
-- Evita usar Ricardo que tem 103 obras

-- 1. Primeiro, vamos ver todos os usuários e quantas obras cada um tem
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    c.col_fl_ativo,
    COUNT(o.obr_id_obra) as total_obras
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, c.col_fl_ativo
ORDER BY total_obras ASC, c.col_ds_nome;

-- 2. Usuários com exatamente 1 obra (candidatos para teste)
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    o.obr_id_obra,
    o.obr_ds_descricao as obra_nome,
    COUNT(o.obr_id_obra) as total_obras
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, o.obr_id_obra, o.obr_ds_descricao
HAVING COUNT(o.obr_id_obra) = 1
ORDER BY c.col_ds_nome;

-- 3. Buscar por CPFs que não sejam do Ricardo (assumindo que Ricardo tem muitas obras)
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    c.col_fl_ativo,
    COUNT(o.obr_id_obra) as total_obras
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
  AND c.col_ds_nome NOT LIKE '%Ricardo%'
  AND c.col_ds_nome NOT LIKE '%RICARDO%'
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, c.col_fl_ativo
HAVING COUNT(o.obr_id_obra) <= 5  -- Usuários com poucas obras
ORDER BY total_obras ASC, c.col_ds_nome;

-- 4. Buscar usuários com CPF formatado (possíveis usuários de teste)
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    c.col_fl_ativo,
    COUNT(o.obr_id_obra) as total_obras,
    -- Verificar se o CPF parece ser de teste (números repetidos, sequenciais, etc.)
    CASE 
        WHEN c.col_ds_cpf LIKE '111.111.111-%' THEN 'CPF_TESTE_111'
        WHEN c.col_ds_cpf LIKE '123.456.789-%' THEN 'CPF_TESTE_123'
        WHEN c.col_ds_cpf LIKE '000.000.000-%' THEN 'CPF_TESTE_000'
        WHEN c.col_ds_cpf LIKE '999.999.999-%' THEN 'CPF_TESTE_999'
        WHEN LENGTH(REPLACE(REPLACE(REPLACE(c.col_ds_cpf, '.', ''), '-', ''), '/', '')) = 11 THEN 'CPF_VALIDO'
        ELSE 'CPF_FORMATO_DIFERENTE'
    END as tipo_cpf
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, c.col_fl_ativo
HAVING COUNT(o.obr_id_obra) <= 3  -- Foco em usuários com poucas obras
ORDER BY tipo_cpf, total_obras ASC, c.col_ds_nome;

-- 5. Buscar especificamente por usuários criados recentemente (possível usuário de teste)
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    c.col_fl_ativo,
    c.col_dt_insercao,
    COUNT(o.obr_id_obra) as total_obras
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
  AND c.col_dt_insercao >= '2024-01-01'  -- Usuários criados em 2024
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, c.col_fl_ativo, c.col_dt_insercao
HAVING COUNT(o.obr_id_obra) <= 2
ORDER BY c.col_dt_insercao DESC, total_obras ASC;

-- 6. Verificar se existe algum usuário com nome "teste", "test", etc.
SELECT 
    c.col_id_colaborador,
    c.col_ds_nome,
    c.col_ds_cpf,
    c.col_ds_email,
    c.col_fl_ativo,
    COUNT(o.obr_id_obra) as total_obras
FROM colaborador c
LEFT JOIN obra o ON c.col_id_colaborador = o.col_id_colaborador
WHERE c.col_fl_ativo = 'S'
  AND (c.col_ds_nome LIKE '%teste%' 
       OR c.col_ds_nome LIKE '%test%'
       OR c.col_ds_nome LIKE '%TESTE%'
       OR c.col_ds_nome LIKE '%TEST%'
       OR c.col_ds_email LIKE '%teste%'
       OR c.col_ds_email LIKE '%test%')
GROUP BY c.col_id_colaborador, c.col_ds_nome, c.col_ds_cpf, c.col_ds_email, c.col_fl_ativo
ORDER BY total_obras ASC, c.col_ds_nome;