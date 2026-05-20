-- ATIVAR USUARIO TESTE NO BANCO HOMOLOG
USE piscinas_rdoapp_homologa;

-- Verificar o usuário atual
SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF,
    col_st_admin as Ativo_Atual
FROM colaborador 
WHERE col_nr_cpf = '56706545520';

-- Ativar o usuário (definir col_st_admin como TRUE)
UPDATE colaborador 
SET col_st_admin = TRUE 
WHERE col_nr_cpf = '56706545520';

-- Verificar se a atualização funcionou
SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF,
    col_st_admin as Ativo_Depois
FROM colaborador 
WHERE col_nr_cpf = '56706545520';