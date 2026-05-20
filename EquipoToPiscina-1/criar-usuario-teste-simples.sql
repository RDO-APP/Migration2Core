-- Criar usuário de teste com senha simples para facilitar login
INSERT INTO colaborador (
    col_nr_cpf,
    col_nm_colaborador,
    col_ds_senha,
    col_ds_email,
    col_st_admin
) VALUES (
    '11111111111',
    'Usuario Teste Kiro',
    '1234',
    'teste@rdoapp.com',
    1
);