-- ========================================
-- HOMOLOG DATABASE SETUP SCRIPT
-- ========================================
-- This script creates a homolog database with the EXACT same structure as production
-- Run this in DBeaver or MySQL client
-- ========================================

-- ========================================
-- STEP 1: CREATE HOMOLOG DATABASE
-- ========================================

CREATE DATABASE IF NOT EXISTS `piscinas_rdoapp_homolog` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ========================================
-- STEP 2: CLONE PRODUCTION STRUCTURE
-- ========================================
-- This copies the EXACT structure from production database
-- No data is copied, only table definitions

-- Method: Use mysqldump to clone structure
-- Run this command in your terminal/command prompt BEFORE running this script:
-- 
-- mysqldump -u rdoadmin -p --no-data --routines --triggers piscinas_rdoapp | mysql -u rdoadmin -p piscinas_rdoapp_homolog
--
-- OR use DBeaver's "Export Database" feature:
-- 1. Right-click piscinas_rdoapp database
-- 2. Export Database → Structure Only
-- 3. Change database name to piscinas_rdoapp_homolog
-- 4. Execute

-- ========================================
-- ALTERNATIVE: Manual Structure Creation
-- ========================================
-- If you cannot use mysqldump, this script creates the minimal required structure
-- based on the Entity Framework model

USE piscinas_rdoapp_homolog;

-- ========================================
-- 2. CREATE CORE TABLES FOR TESTING
-- ========================================

-- Status RDO table
CREATE TABLE IF NOT EXISTS `status_rdo` (
  `str_id_status` int(11) NOT NULL AUTO_INCREMENT,
  `str_ds_status` varchar(50) NOT NULL,
  PRIMARY KEY (`str_id_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO status_rdo VALUES 
(1, 'Pendente'), 
(2, 'Assinado Contratada'), 
(3, 'Assinado Contratante');

-- Obra table
CREATE TABLE IF NOT EXISTS `obra` (
  `obr_id_obra` int(11) NOT NULL AUTO_INCREMENT,
  `obr_ds_obra` varchar(200) NOT NULL DEFAULT 'Obra Teste',
  `obr_dt_inicio` date NOT NULL DEFAULT (CURDATE()),
  `obr_dt_previsao_fim` date DEFAULT NULL,
  `obr_dt_fim` date DEFAULT NULL,
  `obr_id_municipio` int(11) DEFAULT 1,
  `obr_ds_logradouro` varchar(200) DEFAULT 'Rua Teste, 123',
  `obr_ds_bairro` varchar(100) DEFAULT 'Bairro Teste',
  `obr_ds_numero` varchar(20) DEFAULT '123',
  `obr_ds_cep` varchar(10) DEFAULT '12345678',
  `obr_ds_foto` varchar(500) DEFAULT '/Assets/images/logo.jpg',
  PRIMARY KEY (`obr_id_obra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO obra VALUES 
(1, 'Piscina Teste Homologação', CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, 1, 'Rua das Piscinas, 100', 'Centro', '100', '01234567', '/Assets/images/logo.jpg');

-- Colaborador table
CREATE TABLE IF NOT EXISTS `colaborador` (
  `col_id_colaborador` int(11) NOT NULL AUTO_INCREMENT,
  `col_nm_colaborador` varchar(100) NOT NULL DEFAULT 'Colaborador Teste',
  `col_nr_cpf` varchar(14) DEFAULT '00000000000',
  `col_ds_email` varchar(100) DEFAULT 'teste@homolog.com',
  `col_ds_assinatura` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`col_id_colaborador`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO colaborador VALUES 
(1, 'Técnico de Teste Homolog', '00000000001', 'tecnico@homolog.com', NULL);

-- Municipio table (basic)
CREATE TABLE IF NOT EXISTS `municipio` (
  `mun_id_municipio` int(11) NOT NULL AUTO_INCREMENT,
  `mun_ds_municipio` varchar(100) NOT NULL DEFAULT 'Cidade Teste',
  `mun_id_uf` int(11) DEFAULT 1,
  PRIMARY KEY (`mun_id_municipio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO municipio VALUES (1, 'São Paulo', 1);

-- UF table (basic)
CREATE TABLE IF NOT EXISTS `uf` (
  `ufe_id_uf` int(11) NOT NULL AUTO_INCREMENT,
  `ufe_ds_sigla` varchar(2) NOT NULL DEFAULT 'SP',
  `ufe_ds_nome` varchar(50) NOT NULL DEFAULT 'São Paulo',
  PRIMARY KEY (`ufe_id_uf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO uf VALUES (1, 'SP', 'São Paulo');

-- Empresa table (basic)
CREATE TABLE IF NOT EXISTS `empresa` (
  `emp_id_empresa` int(11) NOT NULL AUTO_INCREMENT,
  `emp_nm_razao_social` varchar(200) NOT NULL DEFAULT 'Empresa Teste Ltda',
  `emp_nr_cnpj` varchar(18) DEFAULT '00000000000100',
  `emp_id_licenca` int(11) DEFAULT 1,
  PRIMARY KEY (`emp_id_empresa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO empresa VALUES (1, 'Empresa Teste Homolog Ltda', '00000000000100', 1);

-- Licenca table (basic)
CREATE TABLE IF NOT EXISTS `licenca` (
  `lic_id_licenca` int(11) NOT NULL AUTO_INCREMENT,
  `lic_ds_licenca` varchar(100) NOT NULL DEFAULT 'Licença Teste',
  `lic_st_permite_logo_rdo` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`lic_id_licenca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO licenca VALUES (1, 'Licença Homolog', 1);

-- ========================================
-- 3. CREATE LAUDO TABLE (MAIN FOCUS)
-- ========================================

CREATE TABLE IF NOT EXISTS `laudo` (
  `lau_id_laudo` int(11) NOT NULL AUTO_INCREMENT,
  `lau_id_status` int(11) NOT NULL DEFAULT 1,
  `lau_id_obra` int(11) NOT NULL DEFAULT 1,
  `lau_dt_laudo` date NOT NULL,
  `lau_ds_comentario_assinatura` varchar(2000) DEFAULT NULL,
  `lau_id_colaborador` int(11) DEFAULT 1,
  `lau_dt_geracao` datetime DEFAULT CURRENT_TIMESTAMP,
  `lau_tp_comentario_assinatura` varchar(1) DEFAULT NULL,
  `lau_ds_comentario_geracao` text,
  `lau_tp_comentario_geracao` varchar(1) DEFAULT NULL,
  `lau_tp_nivel_cloro` tinyint(1) DEFAULT 1,
  `lau_tp_ph` tinyint(1) DEFAULT 1,
  `lau_tp_limpidez` tinyint(1) DEFAULT 1,
  `lau_tp_superficie` tinyint(1) DEFAULT 1,
  `lau_tp_fundo` tinyint(1) DEFAULT 1,
  `lau_tp_nivel_cloro_2` tinyint(1) DEFAULT 0,
  `lau_tp_nivel_bacterias` tinyint(1) DEFAULT 0,
  `lau_tp_nivel_proliferacao` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`lau_id_laudo`),
  KEY `FK_laudo_status_rdo` (`lau_id_status`),
  KEY `FK_laudo_obra` (`lau_id_obra`),
  KEY `FK_laudo_colaborador` (`lau_id_colaborador`),
  CONSTRAINT `FK_laudo_colaborador` FOREIGN KEY (`lau_id_colaborador`) REFERENCES `colaborador` (`col_id_colaborador`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `FK_laudo_obra` FOREIGN KEY (`lau_id_obra`) REFERENCES `obra` (`obr_id_obra`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_laudo_status_rdo` FOREIGN KEY (`lau_id_status`) REFERENCES `status_rdo` (`str_id_status`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ========================================
-- 4. INSERT TEST DATA
-- ========================================

INSERT IGNORE INTO laudo (
    lau_id_laudo, lau_id_status, lau_id_obra, lau_dt_laudo, 
    lau_ds_comentario_geracao, lau_tp_nivel_cloro, lau_tp_ph, 
    lau_tp_limpidez, lau_tp_superficie, lau_tp_fundo
) VALUES 
(1, 1, 1, CURDATE(), 'Teste Homolog - Laudo 1 - Todos os parâmetros OK', 1, 1, 1, 1, 1),
(2, 1, 1, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'Teste Homolog - Laudo 2 - pH baixo', 1, 0, 1, 1, 1),
(3, 2, 1, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'Teste Homolog - Laudo 3 - Assinado', 1, 1, 0, 1, 1),
(4, 1, 1, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'Teste Homolog - Laudo 4 - Cloro baixo', 0, 1, 1, 0, 1);

-- ========================================
-- 5. VERIFICATION QUERIES
-- ========================================

-- Verify laudo table and data
SELECT 'Laudo table verification:' as info;
SELECT COUNT(*) as total_laudos FROM laudo;

-- Show sample data
SELECT 
    lau_id_laudo,
    lau_dt_laudo,
    lau_tp_nivel_cloro as cloro,
    lau_tp_ph as ph,
    lau_tp_limpidez as limpidez,
    lau_ds_comentario_geracao as comentario
FROM laudo 
ORDER BY lau_dt_laudo DESC;

-- Verify relationships
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
ORDER BY l.lau_dt_laudo DESC;

-- ========================================
-- 6. SUCCESS MESSAGE
-- ========================================

SELECT '
========================================
HOMOLOG DATABASE SETUP COMPLETE!
========================================

✅ Database: piscinas_rdoapp_homolog created
✅ Tables: laudo, obra, colaborador, status_rdo, etc.
✅ Test data: 4 sample laudo records inserted
✅ Foreign keys: All relationships configured

Next steps:
1. Open RDO-Homolog-Test solution in Visual Studio
2. Build the solution
3. Run and test Laudo functionality

Expected results:
- No "entity not part of model" errors
- No "Teste.rdlc not found" errors
- Laudo pages load successfully
- PDF generation works

Test URLs (when running locally):
- http://localhost:[port]/laudos/index
- http://localhost:[port]/laudos/cadastro
========================================
' as setup_complete;