-- ========================================
-- ADD TEST DATA TO HOMOLOG DATABASE
-- ========================================
-- Run this AFTER you have cloned the production database structure
-- This adds minimal test data for testing the Laudo functionality
-- ========================================

USE piscinas_rdoapp_homolog;

-- ========================================
-- 1. INSERT SUPPORTING DATA
-- ========================================

-- Status RDO (if not exists)
INSERT IGNORE INTO status_rdo (str_id_status, str_ds_status) VALUES 
(1, 'Pendente'), 
(2, 'Assinado Contratada'), 
(3, 'Assinado Contratante');

-- Obra (if not exists)
INSERT IGNORE INTO obra (obr_id_obra, obr_ds_obra, obr_dt_inicio) VALUES 
(1, 'Piscina Teste Homolog', CURDATE());

-- Colaborador (if not exists)  
INSERT IGNORE INTO colaborador (col_id_colaborador, col_nm_colaborador) VALUES 
(1, 'Técnico Teste Homolog');

-- ========================================
-- 2. INSERT TEST LAUDO RECORDS
-- ========================================

-- Clear any existing test data first
DELETE FROM laudo WHERE lau_ds_comentario_geracao LIKE 'Teste Homolog%';

-- Insert fresh test data
INSERT INTO laudo (
    lau_id_status, 
    lau_id_obra, 
    lau_dt_laudo, 
    lau_ds_comentario_geracao,
    lau_tp_nivel_cloro,
    lau_tp_ph,
    lau_tp_limpidez,
    lau_tp_superficie,
    lau_tp_fundo,
    lau_dt_geracao
) VALUES 
(1, 1, CURDATE(), 'Teste Homolog - Laudo 1 - Todos os parâmetros OK', 1, 1, 1, 1, 1, NOW()),
(1, 1, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'Teste Homolog - Laudo 2 - pH baixo', 1, 0, 1, 1, 1, NOW()),
(2, 1, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'Teste Homolog - Laudo 3 - Assinado', 1, 1, 0, 1, 1, NOW()),
(1, 1, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'Teste Homolog - Laudo 4 - Cloro baixo', 0, 1, 1, 0, 1, NOW());

-- ========================================
-- 3. VERIFICATION
-- ========================================

SELECT 'TEST DATA INSERTED SUCCESSFULLY!' as result;

-- Show inserted test data
SELECT 
    lau_id_laudo,
    lau_dt_laudo,
    lau_tp_nivel_cloro as cloro,
    lau_tp_ph as ph,
    lau_tp_limpidez as limpidez,
    lau_ds_comentario_geracao as comentario
FROM laudo 
WHERE lau_ds_comentario_geracao LIKE 'Teste Homolog%'
ORDER BY lau_dt_laudo DESC;

-- Show total count
SELECT COUNT(*) as total_test_laudos 
FROM laudo 
WHERE lau_ds_comentario_geracao LIKE 'Teste Homolog%';

-- ========================================
-- EXPECTED RESULTS:
-- ========================================
-- ✅ 4 test laudo records inserted
-- ✅ Supporting data (status_rdo, obra, colaborador) available
-- ✅ Test data clearly marked with "Teste Homolog" prefix
-- ✅ Ready for application testing
-- ========================================