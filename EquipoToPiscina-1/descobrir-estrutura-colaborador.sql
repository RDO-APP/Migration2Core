-- 🔍 DESCOBRIR ESTRUTURA REAL DA TABELA COLABORADOR
-- Execute no DBeaver para ver os nomes reais dos campos

-- 1. Ver estrutura da tabela colaborador
DESCRIBE colaborador;

-- 2. Ver todas as colunas da tabela colaborador
SHOW COLUMNS FROM colaborador;

-- 3. Listar alguns registros para ver os dados
SELECT * FROM colaborador LIMIT 5;

-- 4. Ver todas as tabelas do banco para confirmar nomes
SHOW TABLES LIKE '%colaborador%';