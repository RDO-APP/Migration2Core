-- ========================================
-- DATABASE STRUCTURE VERIFICATION SCRIPT
-- ========================================
-- Run this in DBeaver to verify both databases have identical structure
-- ========================================

-- ========================================
-- 1. COMPARE TABLE LISTS
-- ========================================

SELECT 'PRODUCTION TABLES:' as info;
SELECT TABLE_NAME, TABLE_TYPE, ENGINE, TABLE_COLLATION
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp'
ORDER BY TABLE_NAME;

SELECT 'HOMOLOG TABLES:' as info;
SELECT TABLE_NAME, TABLE_TYPE, ENGINE, TABLE_COLLATION
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog'
ORDER BY TABLE_NAME;

-- ========================================
-- 2. COMPARE TABLE COUNTS
-- ========================================

SELECT 'TABLE COUNT COMPARISON:' as info;
SELECT 
    'Production' as database_type,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp'
UNION ALL
SELECT 
    'Homolog' as database_type,
    COUNT(*) as table_count
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog';

-- ========================================
-- 3. COMPARE LAUDO TABLE STRUCTURE (CRITICAL)
-- ========================================

SELECT 'PRODUCTION LAUDO STRUCTURE:' as info;
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'piscinas_rdoapp' 
AND TABLE_NAME = 'laudo'
ORDER BY ORDINAL_POSITION;

SELECT 'HOMOLOG LAUDO STRUCTURE:' as info;
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog' 
AND TABLE_NAME = 'laudo'
ORDER BY ORDINAL_POSITION;

-- ========================================
-- 4. COMPARE FOREIGN KEY CONSTRAINTS
-- ========================================

SELECT 'PRODUCTION FOREIGN KEYS:' as info;
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'piscinas_rdoapp'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

SELECT 'HOMOLOG FOREIGN KEYS:' as info;
SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE REFERENCED_TABLE_SCHEMA = 'piscinas_rdoapp_homolog'
AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;

-- ========================================
-- 5. COMPARE INDEXES
-- ========================================

SELECT 'PRODUCTION INDEXES:' as info;
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'piscinas_rdoapp'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

SELECT 'HOMOLOG INDEXES:' as info;
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    COLUMN_NAME,
    NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;

-- ========================================
-- 6. VERIFY CRITICAL TABLES EXIST
-- ========================================

SELECT 'CRITICAL TABLES VERIFICATION:' as info;

-- Check if critical tables exist in both databases
SELECT 
    'laudo' as table_name,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp' AND TABLE_NAME = 'laudo') THEN 'EXISTS' ELSE 'MISSING' END as production_status,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog' AND TABLE_NAME = 'laudo') THEN 'EXISTS' ELSE 'MISSING' END as homolog_status
UNION ALL
SELECT 
    'obra' as table_name,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp' AND TABLE_NAME = 'obra') THEN 'EXISTS' ELSE 'MISSING' END as production_status,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog' AND TABLE_NAME = 'obra') THEN 'EXISTS' ELSE 'MISSING' END as homolog_status
UNION ALL
SELECT 
    'colaborador' as table_name,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp' AND TABLE_NAME = 'colaborador') THEN 'EXISTS' ELSE 'MISSING' END as production_status,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog' AND TABLE_NAME = 'colaborador') THEN 'EXISTS' ELSE 'MISSING' END as homolog_status
UNION ALL
SELECT 
    'status_rdo' as table_name,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp' AND TABLE_NAME = 'status_rdo') THEN 'EXISTS' ELSE 'MISSING' END as production_status,
    CASE WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog' AND TABLE_NAME = 'status_rdo') THEN 'EXISTS' ELSE 'MISSING' END as homolog_status;

-- ========================================
-- 7. DATA VERIFICATION (PRODUCTION DATA COPY)
-- ========================================

SELECT 'PRODUCTION DATA VERIFICATION:' as info;

-- Check record counts (both should have similar counts since homolog is a copy)
SELECT 'Production laudo count:' as info, COUNT(*) as record_count FROM piscinas_rdoapp.laudo
UNION ALL
SELECT 'Homolog laudo count:' as info, COUNT(*) as record_count FROM piscinas_rdoapp_homolog.laudo;

-- Compare recent records to ensure data was copied
SELECT 'Recent production laudos:' as info;
SELECT lau_id_laudo, lau_dt_laudo, LEFT(lau_ds_comentario_geracao, 50) as comentario_preview
FROM piscinas_rdoapp.laudo 
ORDER BY lau_dt_laudo DESC 
LIMIT 5;

SELECT 'Recent homolog laudos:' as info;
SELECT lau_id_laudo, lau_dt_laudo, LEFT(lau_ds_comentario_geracao, 50) as comentario_preview
FROM piscinas_rdoapp_homolog.laudo 
ORDER BY lau_dt_laudo DESC 
LIMIT 5;

-- ========================================
-- 8. STRUCTURE MATCH SUMMARY
-- ========================================

SELECT 'STRUCTURE VERIFICATION SUMMARY:' as info;

SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp') = 
             (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog')
        THEN '✅ TABLE COUNT MATCHES'
        ELSE '❌ TABLE COUNT MISMATCH'
    END as table_count_status
UNION ALL
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homolog' AND TABLE_NAME = 'laudo')
        THEN '✅ LAUDO TABLE EXISTS'
        ELSE '❌ LAUDO TABLE MISSING'
    END as laudo_table_status
UNION ALL
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM piscinas_rdoapp.laudo) = (SELECT COUNT(*) FROM piscinas_rdoapp_homolog.laudo)
        THEN '✅ LAUDO DATA COPIED SUCCESSFULLY'
        ELSE '❌ LAUDO DATA COUNT MISMATCH'
    END as data_copy_status;

-- ========================================
-- EXPECTED RESULTS (WITH PRODUCTION DATA COPY):
-- ========================================
-- ✅ Same number of tables in both databases
-- ✅ All tables exist in both databases  
-- ✅ Table structures identical in both databases
-- ✅ Foreign key relationships preserved
-- ✅ Production data successfully copied to homolog
-- ✅ Same record counts in both databases
-- ✅ Recent records match between databases
-- ========================================