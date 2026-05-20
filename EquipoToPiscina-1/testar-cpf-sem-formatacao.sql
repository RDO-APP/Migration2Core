-- Descobrir formato do CPF no banco
SELECT col_nr_cpf, LENGTH(col_nr_cpf) as tamanho_cpf 
FROM colaborador 
LIMIT 10;

-- Testar se CPF existe sem formatação
SELECT col_nr_cpf, col_nm_colaborador, col_ds_senha 
FROM colaborador 
WHERE col_nr_cpf = '56706545520';

-- Testar se CPF existe com formatação
SELECT col_nr_cpf, col_nm_colaborador, col_ds_senha 
FROM colaborador 
WHERE col_nr_cpf = '567.065.455-20';