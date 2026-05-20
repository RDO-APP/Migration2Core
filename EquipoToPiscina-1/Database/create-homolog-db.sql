-- Create Homologation Database for RDO App
-- Execute this script on your MySQL server to set up the homolog environment

-- ========================================
-- 1. CREATE HOMOLOG DATABASE
-- ========================================

CREATE DATABASE IF NOT EXISTS `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ========================================
-- 2. CREATE HOMOLOG USER (Optional)
-- ========================================

-- Option A: Create dedicated homolog user
CREATE USER IF NOT EXISTS 'rdoadmin_homolog'@'%' IDENTIFIED BY 'rdoapp2024homolog';
GRANT ALL PRIVILEGES ON piscinas_rdoapp_homolog.* TO 'rdoadmin_homolog'@'%';

-- Option B: Grant existing user access to homolog database
GRANT ALL PRIVILEGES ON piscinas_rdoapp_homolog.* TO 'rdoadmin'@'%';

FLUSH PRIVILEGES;

-- ========================================
-- 3. COPY STRUCTURE FROM PRODUCTION
-- ========================================

-- This will copy the structure (tables, indexes, constraints) from production
-- Run this command from command line, not in MySQL:
-- mysqldump -u rdoadmin -p --no-data piscinas_rdoapp | mysql -u rdoadmin -p piscinas_rdoapp_homolog

-- ========================================
-- 4. VERIFY LAUDO TABLE EXISTS
-- ========================================

USE piscinas_rdoapp_homolog;

-- Check if laudo table exists
SELECT 
    TABLE_NAME,
    TABLE_ROWS,
    CREATE_TIME,
    UPDATE_TIME
FROM information_schema.tables 
WHERE table_schema = 'piscinas_rdoapp_homolog' 
AND table_name = 'laudo';

-- Show laudo table structure
DESCRIBE laudo;

-- ========================================
-- 5. CREATE LAUDO TABLE IF MISSING
-- ========================================

-- If the laudo table doesn't exist, create it:
CREATE TABLE IF NOT EXISTS `laudo` (
  `lau_id_laudo` int(11) NOT NULL AUTO_INCREMENT,
  `lau_id_status` int(11) NOT NULL,
  `lau_id_obra` int(11) NOT NULL,
  `lau_dt_laudo` date NOT NULL,
  `lau_ds_comentario_assinatura` varchar(2000) DEFAULT NULL,
  `lau_id_colaborador` int(11) DEFAULT NULL,
  `lau_dt_geracao` datetime DEFAULT NULL,
  `lau_tp_comentario_assinatura` varchar(1) DEFAULT NULL,
  `lau_ds_comentario_geracao` text,
  `lau_tp_comentario_geracao` varchar(1) DEFAULT NULL,
  `lau_tp_nivel_cloro` tinyint(1) DEFAULT NULL,
  `lau_tp_ph` tinyint(1) DEFAULT NULL,
  `lau_tp_limpidez` tinyint(1) DEFAULT NULL,
  `lau_tp_superficie` tinyint(1) DEFAULT NULL,
  `lau_tp_fundo` tinyint(1) DEFAULT NULL,
  `lau_tp_nivel_cloro_2` tinyint(1) DEFAULT NULL,
  `lau_tp_nivel_bacterias` tinyint(1) DEFAULT NULL,
  `lau_tp_nivel_proliferacao` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`lau_id_laudo`),
  KEY `FK_laudo_status_rdo` (`lau_id_status`),
  KEY `FK_laudo_obra` (`lau_id_obra`),
  KEY `FK_laudo_colaborador` (`lau_id_colaborador`),
  CONSTRAINT `FK_laudo_colaborador` FOREIGN KEY (`lau_id_colaborador`) REFERENCES `colaborador` (`col_id_colaborador`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `FK_laudo_obra` FOREIGN KEY (`lau_id_obra`) REFERENCES `obra` (`obr_id_obra`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_laudo_status_rdo` FOREIGN KEY (`lau_id_status`) REFERENCES `status_rdo` (`str_id_status`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- 6. INSERT SAMPLE DATA FOR TESTING
-- ========================================

-- Insert sample laudo records for testing (only if table is empty)
INSERT IGNORE INTO laudo (
    lau_id_laudo, lau_id_status, lau_id_obra, lau_dt_laudo, 
    lau_ds_comentario_assinatura, lau_id_colaborador, lau_dt_geracao,
    lau_tp_nivel_cloro, lau_tp_ph, lau_tp_limpidez, lau_tp_superficie, 
    lau_tp_fundo, lau_tp_nivel_cloro_2, lau_tp_nivel_bacterias, lau_tp_nivel_proliferacao
) VALUES 
(1, 1, 1, '2024-01-15', 'Laudo de teste para homologação', 1, NOW(), 1, 1, 1, 1, 1, 0, 0, 0),
(2, 1, 1, '2024-01-16', 'Segundo laudo de teste', 1, NOW(), 0, 1, 1, 0, 1, 1, 0, 0),
(3, 2, 1, '2024-01-17', 'Laudo assinado para teste de PDF', 1, NOW(), 1, 0, 1, 1, 0, 1, 1, 0);

-- ========================================
-- 7. SANITIZE SENSITIVE DATA
-- ========================================

-- Remove/anonymize sensitive data for homolog environment
UPDATE colaborador SET 
    col_nr_cpf = CONCAT('000', LPAD(col_id_colaborador, 8, '0')),
    col_ds_email = CONCAT('test', col_id_colaborador, '@homolog.rdoapp.com.br'),
    col_ds_telefone_principal = '11999999999',
    col_ds_telefone_secundario = '11888888888'
WHERE col_id_colaborador > 0;

-- Anonymize empresa data
UPDATE empresa SET 
    emp_nr_cnpj = CONCAT('00000000000', LPAD(emp_id_empresa, 3, '0')),
    emp_ds_email = CONCAT('empresa', emp_id_empresa, '@homolog.rdoapp.com.br'),
    emp_ds_telefone = '1133334444'
WHERE emp_id_empresa > 0;

-- ========================================
-- 8. VERIFICATION QUERIES
-- ========================================

-- Verify laudo table and data
SELECT 'Laudo table verification:' as info;
SELECT COUNT(*) as total_laudos FROM laudo;
SELECT lau_id_laudo, lau_dt_laudo, lau_tp_nivel_cloro, lau_tp_ph FROM laudo LIMIT 5;

-- Verify foreign key relationships
SELECT 'Foreign key verification:' as info;
SELECT 
    l.lau_id_laudo,
    l.lau_dt_laudo,
    o.obr_ds_obra,
    s.str_ds_status,
    c.col_nm_colaborador
FROM laudo l
LEFT JOIN obra o ON l.lau_id_obra = o.obr_id_obra
LEFT JOIN status_rdo s ON l.lau_id_status = s.str_id_status
LEFT JOIN colaborador c ON l.lau_id_colaborador = c.col_id_colaborador
LIMIT 5;

-- Check table sizes
SELECT 'Table sizes:' as info;
SELECT 
    table_name,
    table_rows,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'piscinas_rdoapp_homolog'
AND table_name IN ('laudo', 'obra', 'colaborador', 'status_rdo', 'rdo')
ORDER BY table_rows DESC;

-- ========================================
-- 9. FINAL SETUP NOTES
-- ========================================

SELECT '
========================================
HOMOLOG DATABASE SETUP COMPLETE
========================================

Next steps:
1. Update Web.config connection string to use piscinas_rdoapp_homolog
2. Build and deploy the application
3. Test laudo functionality
4. Verify PDF generation works

Connection string should be:
server=equipamentos.cslrikufb7hm.us-east-2.rds.amazonaws.com;
User Id=rdoadmin;
password=rdoapp2018aws;
database=piscinas_rdoapp_homolog

Test URLs:
- http://localhost/laudos/index
- http://localhost/laudos/cadastro

Expected result: No "entity not part of model" errors
========================================
' as setup_complete;