-- Verificar se existem etapas para a obra atual
-- Substitua o ID da obra pelo que você está testando

-- 1. Verificar todas as obras disponíveis
SELECT TOP 10 
    Id, 
    Descricao,
    DataInicio,
    DataPrevisaoFim
FROM Obra 
ORDER BY Id;

-- 2. Verificar etapas para uma obra específica (substitua o ID)
DECLARE @ObraId INT = 1; -- ALTERE ESTE VALOR PARA A OBRA QUE VOCÊ ESTÁ TESTANDO

SELECT 
    e.Id as EtapaId,
    e.Descricao as EtapaDescricao,
    e.ObraId,
    COUNT(t.Id) as TotalTarefas
FROM Etapa e
LEFT JOIN Tarefa t ON t.EtapaId = e.Id
WHERE e.ObraId = @ObraId
GROUP BY e.Id, e.Descricao, e.ObraId
ORDER BY e.Id;

-- 3. Verificar se existe alguma etapa no banco
SELECT COUNT(*) as TotalEtapas FROM Etapa;

-- 4. Verificar estrutura da tabela Etapa
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Etapa'
ORDER BY ORDINAL_POSITION;