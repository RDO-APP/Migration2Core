-- Verificar se o usuário teste existe no banco
SELECT 
    Id,
    Nome,
    Cpf,
    Email,
    Ativo,
    Senha,
    PasswordHash,
    DataCriacao
FROM colaboradores 
WHERE Cpf = '56706545520' 
   OR Cpf = '567.065.455-20'
   OR Cpf LIKE '%567%'
   OR Cpf LIKE '%065%'
   OR Cpf LIKE '%455%';

-- Contar total de colaboradores
SELECT COUNT(*) as TotalColaboradores FROM colaboradores;

-- Verificar alguns colaboradores para ver o formato do CPF
SELECT Id, Nome, Cpf, Ativo FROM colaboradores LIMIT 5;

-- Verificar estrutura da tabela colaboradores
DESCRIBE colaboradores;