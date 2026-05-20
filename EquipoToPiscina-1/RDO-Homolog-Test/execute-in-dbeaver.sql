-- EXECUTE ESTE SCRIPT NO DBEAVER PARA INVESTIGAR O FORMATO DOS DADOS

-- 1. VERIFICAR ESTRUTURA DA TABELA LAUDO
SELECT 
    COLUMN_NAME as Campo,
    DATA_TYPE as Tipo,
    COLUMN_TYPE as TipoCompleto,
    IS_NULLABLE as Nulo,
    COLUMN_DEFAULT as Padrao
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'laudo' 
AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
AND COLUMN_NAME LIKE '%cloro%' OR COLUMN_NAME LIKE '%ph%' OR COLUMN_NAME LIKE '%alcalin%'
ORDER BY ORDINAL_POSITION;

-- 2. VERIFICAR SE EXISTEM LAUDOS SALVOS
SELECT COUNT(*) as TotalLaudos FROM laudo;

-- 3. VER DADOS EXISTENTES (se houver)
SELECT 
    lau_id_laudo as ID,
    lau_dt_laudo as Data,
    lau_tp_nivel_cloro as Cloro,
    lau_tp_ph as PH,
    lau_tp_limpidez as Limpidez
FROM laudo 
ORDER BY lau_dt_laudo DESC 
LIMIT 5;

-- 4. VERIFICAR ESTRUTURA DA TABELA TAREFA (abordagem Gilberto)
SELECT 
    COLUMN_NAME as Campo,
    DATA_TYPE as Tipo,
    COLUMN_TYPE as TipoCompleto
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'tarefa' 
AND TABLE_SCHEMA = 'piscinas_rdoapp_homologa'
AND (COLUMN_NAME LIKE '%nivel_cloro%' 
     OR COLUMN_NAME LIKE '%ph%' 
     OR COLUMN_NAME LIKE '%alcalin%'
     OR COLUMN_NAME LIKE '%limpidez%')
ORDER BY ORDINAL_POSITION;

-- 5. VERIFICAR SE TAREFA TEM DADOS DE LAUDO
SELECT 
    tar_id_tarefa as ID,
    tar_dt_medicao as Data,
    tar_nr_nivel_cloro as Cloro,
    tar_nr_ph as PH,
    tar_nr_alcalinidade as Alcalinidade
FROM tarefa 
WHERE tar_nr_nivel_cloro IS NOT NULL 
   OR tar_nr_ph IS NOT NULL 
   OR tar_nr_alcalinidade IS NOT NULL
ORDER BY tar_dt_medicao DESC 
LIMIT 5;