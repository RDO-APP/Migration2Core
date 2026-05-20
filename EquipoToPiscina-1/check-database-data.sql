-- Quick database check for Etapa/Tarefa debugging

-- 1. Check if etapa table exists and has data
SELECT 'ETAPA TABLE' as TableName, COUNT(*) as RecordCount FROM etapa;

-- 2. Check if tarefa table exists and has data  
SELECT 'TAREFA TABLE' as TableName, COUNT(*) as RecordCount FROM tarefa;

-- 3. Check etapas by obra
SELECT 'ETAPAS POR OBRA' as Info, eta_id_obra as ObraId, COUNT(*) as QtdEtapas 
FROM etapa 
GROUP BY eta_id_obra 
ORDER BY eta_id_obra
LIMIT 10;

-- 4. Check tarefas by etapa
SELECT 'TAREFAS POR ETAPA' as Info, tar_id_etapa as EtapaId, COUNT(*) as QtdTarefas 
FROM tarefa 
GROUP BY tar_id_etapa 
ORDER BY tar_id_etapa
LIMIT 10;

-- 5. Sample etapas
SELECT 'SAMPLE ETAPAS' as Info, eta_id_etapa, eta_id_obra, eta_ds_etapa 
FROM etapa 
ORDER BY eta_id_etapa 
LIMIT 5;

-- 6. Sample tarefas
SELECT 'SAMPLE TAREFAS' as Info, tar_id_tarefa, tar_id_etapa, tar_ds_tarefa, tar_id_colaborador_insercao
FROM tarefa 
ORDER BY tar_id_tarefa 
LIMIT 5;