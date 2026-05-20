-- Investigação: Por que a página Etapas/Tarefas está vazia
-- Verificar se há dados no banco

-- 1. Verificar se existem etapas no banco
SELECT COUNT(*) as TotalEtapas FROM etapa;

-- 2. Verificar etapas por obra
SELECT eta_id_obra as ObraId, COUNT(*) as QtdEtapas 
FROM etapa 
GROUP BY eta_id_obra 
ORDER BY eta_id_obra;

-- 3. Verificar se existem tarefas no banco
SELECT COUNT(*) as TotalTarefas FROM tarefa;

-- 4. Verificar tarefas por etapa
SELECT tar_id_etapa as EtapaId, COUNT(*) as QtdTarefas 
FROM tarefa 
GROUP BY tar_id_etapa 
ORDER BY tar_id_etapa;

-- 5. Verificar dados de uma obra específica (obra 1)
SELECT e.eta_id_etapa, e.eta_ds_etapa, COUNT(t.tar_id_tarefa) as QtdTarefas
FROM etapa e
LEFT JOIN tarefa t ON e.eta_id_etapa = t.tar_id_etapa
WHERE e.eta_id_obra = 1
GROUP BY e.eta_id_etapa, e.eta_ds_etapa
ORDER BY e.eta_id_etapa;

-- 6. Verificar estrutura da tabela etapa
DESCRIBE etapa;

-- 7. Verificar estrutura da tabela tarefa
DESCRIBE tarefa;

-- 8. Verificar algumas etapas de exemplo
SELECT * FROM etapa LIMIT 5;

-- 9. Verificar algumas tarefas de exemplo
SELECT * FROM tarefa LIMIT 5;