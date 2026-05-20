-- 🔍 DATABASE STRUCTURE COMPARISON SCRIPT
-- This script compares the structure of tarefa and laudo tables between production and homolog databases

-- ========================================
-- PRODUCTION DATABASE: piscinas_rdoapp
-- ========================================

USE piscinas_rdoapp;

SELECT 'PRODUCTION DATABASE - piscinas_rdoapp' as database_name;

-- Check LAUDO table structure in production
SELECT 'LAUDO TABLE STRUCTURE - PRODUCTION' as table_info;
DESCRIBE laudo;

-- Check TAREFA table structure in production  
SELECT 'TAREFA TABLE STRUCTURE - PRODUCTION' as table_info;
DESCRIBE tarefa;

-- Count records in production
SELECT 'PRODUCTION RECORD COUNTS' as info;
SELECT 'laudo' as table_name, COUNT(*) as record_count FROM laudo
UNION ALL
SELECT 'tarefa' as table_name, COUNT(*) as record_count FROM tarefa;

-- Check for modern interface fields in laudo table
SELECT 'LAUDO MODERN FIELDS CHECK - PRODUCTION' as info;
SELECT 
    lau_tp_nivel_cloro,
    lau_tp_ph, 
    lau_tp_limpidez,
    lau_tp_superficie,
    lau_tp_fundo,
    lau_tp_nivel_cloro_2,
    lau_tp_nivel_bacterias,
    lau_tp_nivel_proliferacao
FROM laudo 
LIMIT 5;

-- ========================================
-- HOMOLOG DATABASE: piscinas_rdoapp_homologa
-- ========================================

USE piscinas_rdoapp_homologa;

SELECT 'HOMOLOG DATABASE - piscinas_rdoapp_homologa' as database_name;

-- Check LAUDO table structure in homolog
SELECT 'LAUDO TABLE STRUCTURE - HOMOLOG' as table_info;
DESCRIBE laudo;

-- Check TAREFA table structure in homolog
SELECT 'TAREFA TABLE STRUCTURE - HOMOLOG' as table_info;
DESCRIBE tarefa;

-- Count records in homolog
SELECT 'HOMOLOG RECORD COUNTS' as info;
SELECT 'laudo' as table_name, COUNT(*) as record_count FROM laudo
UNION ALL
SELECT 'tarefa' as table_name, COUNT(*) as record_count FROM tarefa;

-- Check for modern interface fields in laudo table
SELECT 'LAUDO MODERN FIELDS CHECK - HOMOLOG' as info;
SELECT 
    lau_tp_nivel_cloro,
    lau_tp_ph, 
    lau_tp_limpidez,
    lau_tp_superficie,
    lau_tp_fundo,
    lau_tp_nivel_cloro_2,
    lau_tp_nivel_bacterias,
    lau_tp_nivel_proliferacao
FROM laudo 
LIMIT 5;

-- ========================================
-- COMPARISON ANALYSIS
-- ========================================

-- Check if both databases have the same laudo structure
SELECT 'STRUCTURE COMPARISON ANALYSIS' as analysis;

-- This query should be run manually to compare results:
-- 1. Compare DESCRIBE laudo results between both databases
-- 2. Compare DESCRIBE tarefa results between both databases  
-- 3. Check if modern interface fields exist in both databases
-- 4. Verify record counts are reasonable

-- ========================================
-- EXPECTED RESULTS ANALYSIS
-- ========================================

/*
WHAT WE'RE LOOKING FOR:

1. LAUDO TABLE MODERN FIELDS:
   - lau_tp_nivel_cloro (bool) - "Os níveis de CLORO estão entre 1ppm e 3ppm?"
   - lau_tp_ph (bool) - "O PH está entre 7,2 e 7,6?"
   - lau_tp_limpidez (bool) - "A LIMPIDEZ DA ÁGUA permite perfeita visibilidade..."
   - lau_tp_superficie (bool) - "A superfície da água está livre de MATÉRIAS FLUTUANTES..."
   - lau_tp_fundo (bool) - "O fundo do tanque está LIVRE DE DETRITOS?"
   - lau_tp_nivel_cloro_2 (bool) - "O NÍVEL DE CLORO no tanque está mantido..."
   - lau_tp_nivel_bacterias (bool) - "A piscina contém BACTÉRIAS DO GRUPO COLIFORME..."
   - lau_tp_nivel_proliferacao (bool) - "Há proliferação de ALGAS, LEVEDURAS E AMEBAS..."

2. TAREFA TABLE FIELDS:
   - tar_dt_medicao_horimetro_inicial (float) - Horímetro Inicial
   - tar_dt_medicao_horimetro_final (float) - Horímetro Final  
   - tar_dt_medicao_horimetro_total (float) - Total Horas
   - tar_nr_qtd_construida (float) - Quantidade Construída

3. INTERFACE MAPPING:
   OLD INTERFACE (Nova Medição):
   - Uses tarefa table fields (horimetro, quantidade construída)
   - Simple form with basic fields
   
   NEW INTERFACE (Production):
   - Uses laudo table fields (inspection questions)
   - Modern grid with dropdowns and checkboxes
   - Photo upload functionality

4. DATABASE COMPATIBILITY:
   - If both databases have the same structure → UI difference only
   - If structures differ → Database migration needed
   - If laudo fields exist → Modern interface can be implemented
*/