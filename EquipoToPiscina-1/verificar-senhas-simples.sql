-- Verificar se existem senhas simples no banco
SELECT 
    col_id_colaborador,
    col_nm_colaborador,
    col_nr_cpf,
    col_ds_senha,
    LENGTH(col_ds_senha) as tamanho_senha
FROM colaborador 
WHERE col_ds_senha IN ('1234', '123456', 'admin', 'senha', '12345')
   OR LENGTH(col_ds_senha) <= 6
ORDER BY LENGTH(col_ds_senha);