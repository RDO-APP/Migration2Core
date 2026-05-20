-- 📋 GET FIRST 20 TABLE NAMES FROM PRODUCTION DATABASE
-- Execute this query in your MySQL client connected to: piscinas_rdoapp

-- Get first 20 table names alphabetically
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp' 
ORDER BY TABLE_NAME 
LIMIT 20;

-- Alternative: Get all table names (48 total)
-- SELECT TABLE_NAME 
-- FROM INFORMATION_SCHEMA.TABLES 
-- WHERE TABLE_SCHEMA = 'piscinas_rdoapp' 
-- ORDER BY TABLE_NAME;