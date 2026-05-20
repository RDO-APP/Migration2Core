-- Listar TODAS as tabelas do banco piscinas_rdoapp_homologa
-- Para comparação completa com código do Gilberto

-- 1. Listar todas as tabelas
SELECT TABLE_NAME, TABLE_TYPE, ENGINE, TABLE_COLLATION
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
ORDER BY TABLE_NAME;

-- 2. Contar total de tabelas
SELECT COUNT(*) as total_tabelas
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa';

-- 3. Listar apenas nomes das tabelas (para facilitar comparação)
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
ORDER BY TABLE_NAME;