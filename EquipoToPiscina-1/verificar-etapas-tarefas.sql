-- Verificar se existem etapas e tarefas no banco de dados
-- Execute no DBeaver conectado ao banco piscinas_rdoapp_homologa

-- 1. Verificar etapas
SELECT 
    e.id as etapa_id,
    e.titulo as etapa_titulo,
    e.idObra as obra_id,
    e.dataInicio,
    e.dataPrevisaoFim
FROM etapa e
ORDER BY e.id;

-- 2. Verificar tarefas
SELECT 
    t.id as tarefa_id,
    t.descricao as tarefa_descricao,
    t.idEtapa as etapa_id,
    t.idObra as obra_id,
    t.dataInicio,
    t.dataPrevisaoFim,
    t.status
FROM tarefa t
ORDER BY t.id;

-- 3. Verificar obras
SELECT 
    o.id as obra_id,
    o.nome as obra_nome,
    o.ativo
FROM obra o
ORDER BY o.id;

-- 4. Verificar usuários e suas obras
SELECT 
    u.id as usuario_id,
    u.nome as usuario_nome,
    u.cpf,
    u.idObra as obra_id
FROM usuario u
WHERE u.cpf = '567.065.455-20';

-- 5. Verificar etapas com tarefas (JOIN)
SELECT 
    e.id as etapa_id,
    e.titulo as etapa_titulo,
    COUNT(t.id) as total_tarefas
FROM etapa e
LEFT JOIN tarefa t ON e.id = t.idEtapa
GROUP BY e.id, e.titulo
ORDER BY e.id;