-- 🔍 VERIFICAR USUÁRIO DE TESTE NO BANCO - NOMES CORRETOS
-- Execute no DBeaver para verificar se o usuário existe

-- 1. Verificar se usuário com CPF existe (nomes corretos dos campos)
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha,
    col_ds_email,
    col_ds_telefone_principal,
    col_st_admin
FROM colaborador 
WHERE col_nr_cpf = '567.065.455-20';

-- 2. Se não existir, vamos criar o usuário de teste
INSERT INTO colaborador (
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha,
    col_ds_email,
    col_ds_telefone_principal,
    col_st_admin
) VALUES (
    'Marcel Castro de Santana',
    '567.065.455-20',
    '1234',
    'marcel@rdoapp.com',
    '(11) 99999-9999',
    1
) ON DUPLICATE KEY UPDATE
    col_ds_senha = '1234',
    col_st_admin = 1;

-- 3. Verificar se foi criado/atualizado
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha,
    col_st_admin
FROM colaborador 
WHERE col_nr_cpf = '567.065.455-20';