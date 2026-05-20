-- 📋 GET FIRST 20 TABLE NAMES FROM HOMOLOG DATABASE  
-- Execute this query in your MySQL client connected to: piscinas_rdoapp_homologa

-- Get first 20 table names alphabetically
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' 
ORDER BY TABLE_NAME 
LIMIT 20;

-- Alternative: Get all table names (49 total)
-- SELECT TABLE_NAME 
-- FROM INFORMATION_SCHEMA.TABLES 
-- WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' 
-- ORDER BY TABLE_NAME;