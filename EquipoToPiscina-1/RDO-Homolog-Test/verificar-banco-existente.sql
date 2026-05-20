'-- ========================================
-- VERIFICAÇÃO DO BANCO HOMOLOG EXISTENTE
-- ========================================
-- Execute este script no DBeaver para verificar o banco piscinas_rdoapp_homologa
-- ========================================

-- ========================================
-- 1. VERIFICAR SE O BANCO EXISTE E TEM DADOS
-- ========================================

SELECT 'VERIFICANDO BANCO HOMOLOG EXISTENTE:' as info;

-- Verificar se o banco existe
SELECT SCHEMA_NAME as banco_existente
FROM INFORMATION_SCHEMA.SCHEMATA 
WHERE SCHEMA_NAME IN ('piscinas_rdoapp_homologa', 'piscinas_rdoapp_homolog');

-- ========================================
-- 2. COMPARAR ESTRUTURA DOS BANCOS
-- ========================================

SELECT 'COMPARAÇÃO DE TABELAS:' as info;

-- Tabelas no banco de produção
SELECT 'PRODUÇÃO - Tabelas:' as tipo, COUNT(*) as total_tabelas
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp';

-- Tabelas no banco homolog existente
SELECT 'HOMOLOG - Tabelas:' as tipo, COUNT(*) as total_tabelas
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa';

-- ========================================
-- 3. VERIFICAR TABELA LAUDO (CRÍTICA)
-- ========================================

SELECT 'VERIFICAÇÃO DA TABELA LAUDO:' as info;

-- Verificar se tabela laudo existe no homolog
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' AND TABLE_NAME = 'laudo')
        THEN '✅ TABELA LAUDO EXISTE NO HOMOLOG'
        ELSE '❌ TABELA LAUDO NÃO EXISTE NO HOMOLOG'
    END as status_tabela_laudo;

-- Comparar estrutura da tabela laudo
SELECT 'ESTRUTURA LAUDO - PRODUÇÃO:' as info;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'piscinas_rdoapp' AND TABLE_NAME = 'laudo'
ORDER BY ORDINAL_POSITION;

SELECT 'ESTRUTURA LAUDO - HOMOLOG:' as info;
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' AND TABLE_NAME = 'laudo'
ORDER BY ORDINAL_POSITION;

-- ========================================
-- 4. VERIFICAR DADOS
-- ========================================

SELECT 'VERIFICAÇÃO DE DADOS:' as info;

-- Contar registros laudo
SELECT 'Produção - Laudos:' as banco, COUNT(*) as total_laudos FROM piscinas_rdoapp.laudo;
SELECT 'Homolog - Laudos:' as banco, COUNT(*) as total_laudos FROM piscinas_rdoapp_homologa.laudo;

-- Mostrar alguns registros do homolog
SELECT 'DADOS HOMOLOG - Últimos laudos:' as info;
SELECT lau_id_laudo, lau_dt_laudo, LEFT(lau_ds_comentario_geracao, 50) as comentario
FROM piscinas_rdoapp_homologa.laudo 
ORDER BY lau_dt_laudo DESC 
LIMIT 5;

-- ========================================
-- 5. VERIFICAR OUTRAS TABELAS IMPORTANTES
-- ========================================

SELECT 'OUTRAS TABELAS IMPORTANTES:' as info;

-- Verificar tabelas essenciais
SELECT 
    'obra' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' AND TABLE_NAME = 'obra') THEN 'EXISTS' ELSE 'MISSING' END as status,
    COALESCE((SELECT COUNT(*) FROM piscinas_rdoapp_homologa.obra), 0) as registros
UNION ALL
SELECT 
    'colaborador' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' AND TABLE_NAME = 'colaborador') THEN 'EXISTS' ELSE 'MISSING' END as status,
    COALESCE((SELECT COUNT(*) FROM piscinas_rdoapp_homologa.colaborador), 0) as registros
UNION ALL
SELECT 
    'status_rdo' as tabela,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' AND TABLE_NAME = 'status_rdo') THEN 'EXISTS' ELSE 'MISSING' END as status,
    COALESCE((SELECT COUNT(*) FROM piscinas_rdoapp_homologa.status_rdo), 0) as registros;

-- ========================================
-- 6. DIAGNÓSTICO FINAL
-- ========================================

SELECT 'DIAGNÓSTICO FINAL:' as info;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' AND TABLE_NAME = 'laudo')
        AND (SELECT COUNT(*) FROM piscinas_rdoapp_homologa.laudo) > 0
        THEN '✅ BANCO HOMOLOG PRONTO PARA TESTE'
        ELSE '⚠️ BANCO HOMOLOG PRECISA DE AJUSTES'
    END as status_geral;

-- ========================================
-- PRÓXIMOS PASSOS BASEADOS NO RESULTADO
-- ========================================

SELECT 'PRÓXIMOS PASSOS:' as info;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' AND TABLE_NAME = 'laudo')
        AND (SELECT COUNT(*) FROM piscinas_rdoapp_homologa.laudo) > 0
        THEN 'Banco OK - Pode testar a aplicação no Visual Studio'
        ELSE 'Banco incompleto - Execute script de sincronização'
    END as acao_recomendada;'