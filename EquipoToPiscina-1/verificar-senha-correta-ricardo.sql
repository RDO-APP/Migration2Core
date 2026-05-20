-- Verificar senha exata do usuário Ricardo Freire
SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF,
    col_ds_senha as Senha,
    col_st_admin as Ativo
FROM colaborador 
WHERE col_nr_cpf = '56706545520';