-- Verificar formato do CPF no banco de dados
-- Testar se CPF está com ou sem formatação

-- 1. Ver alguns CPFs da tabela colaborador
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    LENGTH(col_nr_cpf) as tamanho_cpf,
    col_ds_senha
FROM colaborador 
WHERE col_nr_cpf IS NOT NULL 
LIMIT 10;

-- 2. Procurar especificamente pelo CPF de teste
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    LENGTH(col_nr_cpf) as tamanho_cpf,
    col_ds_senha,
    col_st_admin
FROM colaborador 
WHERE col_nr_cpf LIKE '%56706545520%' 
   OR col_nr_cpf LIKE '%567.065.455-20%'
   OR col_nr_cpf LIKE '%567%';

-- 3. Ver todos os CPFs que começam com 567
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    LENGTH(col_nr_cpf) as tamanho_cpf,
    col_ds_senha
FROM colaborador 
WHERE col_nr_cpf LIKE '567%';