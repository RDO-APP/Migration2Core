-- VERIFICAR DADOS REAIS NO BANCO HOMOLOG
USE piscinas_rdoapp_homologa;

-- 1. Verificar se a tabela colaborador existe
SHOW TABLES LIKE 'colaborador';

-- 2. Verificar estrutura da tabela colaborador
DESCRIBE colaborador;

-- 3. Buscar todos os colaboradores (para ver se tem dados)
SELECT COUNT(*) as TotalColaboradores FROM colaborador;

-- 4. Buscar especificamente por CPFs que contenham os números do teste
SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF_Original,
    REPLACE(REPLACE(REPLACE(col_nr_cpf, '.', ''), '-', ''), ' ', '') as CPF_Limpo,
    col_ds_senha as Senha,
    col_st_admin as Ativo,
    LENGTH(col_nr_cpf) as TamanhoCPF,
    LENGTH(col_ds_senha) as TamanhoSenha
FROM colaborador 
WHERE col_nr_cpf LIKE '%567%' 
   OR col_nr_cpf LIKE '%065%' 
   OR col_nr_cpf LIKE '%455%'
   OR col_nr_cpf = '56706545520'
   OR col_nr_cpf = '567.065.455-20'
ORDER BY col_id_colaborador;

-- 5. Buscar os primeiros 5 colaboradores para ver o formato dos dados
SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF,
    col_ds_senha as Senha,
    col_st_admin as Ativo
FROM colaborador 
ORDER BY col_id_colaborador 
LIMIT 5;

-- 6. Verificar se existe algum colaborador ativo
SELECT 
    col_id_colaborador as ID,
    col_nm_colaborador as Nome,
    col_nr_cpf as CPF,
    col_ds_senha as Senha,
    col_st_admin as Ativo
FROM colaborador 
WHERE col_st_admin = 1 OR col_st_admin = true
ORDER BY col_id_colaborador 
LIMIT 10;