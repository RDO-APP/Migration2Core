-- Verificar se usuário existe na tabela colaborador (singular)
SELECT 
    col_id,
    col_nome,
    col_cpf,
    col_senha,
    col_email,
    col_telefone,
    col_ativo,
    col_data_criacao
FROM colaborador 
WHERE col_cpf = '567.065.455-20';