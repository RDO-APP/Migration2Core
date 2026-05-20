-- Análise detalhada de estrutura de tabela específica
-- Para comparar com código do Gilberto campo por campo

-- USAR: Substitua 'NOME_TABELA' pela tabela que quer analisar

-- 1. Estrutura completa da tabela
SELECT 
    COLUMN_NAME as campo,
    DATA_TYPE as tipo,
    IS_NULLABLE as permite_null,
    COLUMN_DEFAULT as valor_padrao,
    CHARACTER_MAXIMUM_LENGTH as tamanho_max,
    NUMERIC_PRECISION as precisao_numerica,
    NUMERIC_SCALE as escala_numerica,
    COLUMN_KEY as tipo_chave,
    EXTRA as extra_info
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' 
  AND TABLE_NAME = 'colaborador'  -- SUBSTITUIR AQUI
ORDER BY ORDINAL_POSITION;

-- 2. Chaves primárias
SELECT 
    COLUMN_NAME as campo_pk,
    CONSTRAINT_NAME as nome_constraint
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' 
  AND TABLE_NAME = 'colaborador'  -- SUBSTITUIR AQUI
  AND CONSTRAINT_NAME = 'PRIMARY';

-- 3. Chaves estrangeiras
SELECT 
    COLUMN_NAME as campo_fk,
    CONSTRAINT_NAME as nome_constraint,
    REFERENCED_TABLE_NAME as tabela_referenciada,
    REFERENCED_COLUMN_NAME as campo_referenciado
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' 
  AND TABLE_NAME = 'colaborador'  -- SUBSTITUIR AQUI
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 4. Índices
SELECT 
    INDEX_NAME as nome_indice,
    COLUMN_NAME as campo,
    NON_UNIQUE as nao_unico,
    SEQ_IN_INDEX as sequencia
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'piscinas_rdoapp_homologa' 
  AND TABLE_NAME = 'colaborador'  -- SUBSTITUIR AQUI
ORDER BY INDEX_NAME, SEQ_IN_INDEX;