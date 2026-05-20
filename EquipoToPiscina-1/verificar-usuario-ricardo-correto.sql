-- VERIFICAR DADOS CORRETOS DO USUÁRIO RICARDO
-- CPF: 567.065.455-20

-- 1. Verificar se usuário existe e qual é o nome correto
SELECT 
    Id,
    Nome,
    Cpf,
    PasswordHash,
    Ativo,
    DataCriacao
FROM Colaboradores 
WHERE Cpf = '567.065.455-20' 
   OR Cpf = '56706545520'
ORDER BY Id;

-- 2. Verificar todas as variações de CPF similares
SELECT 
    Id,
    Nome,
    Cpf,
    PasswordHash,
    Ativo
FROM Colaboradores 
WHERE Cpf LIKE '%567%' 
   OR Cpf LIKE '%455%'
   OR Cpf LIKE '%065%'
ORDER BY Cpf;

-- 3. Verificar quantos usuários existem no total
SELECT COUNT(*) as TotalUsuarios FROM Colaboradores;

-- 4. Verificar os primeiros 10 usuários para referência
SELECT TOP 10
    Id,
    Nome,
    Cpf,
    Ativo
FROM Colaboradores
ORDER BY Id;