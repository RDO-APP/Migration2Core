-- 🔍 DESCOBRIR TABELAS DO BANCO
-- Execute no DBeaver para ver todas as tabelas disponíveis

-- 1. Listar todas as tabelas do banco
SHOW TABLES;

-- 2. Procurar tabelas que podem conter usuários/colaboradores
SHOW TABLES LIKE '%colab%';
SHOW TABLES LIKE '%user%';
SHOW TABLES LIKE '%usuario%';

-- 3. Procurar tabelas relacionadas a pessoas
SHOW TABLES LIKE '%pessoa%';
SHOW TABLES LIKE '%funcionario%';

-- 4. Ver estrutura das tabelas principais (se existirem)
-- DESCRIBE nome_da_tabela_encontrada;