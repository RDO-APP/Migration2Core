-- ESSENTIAL TABLES FOR OBRA 233 - MySQL Syntax Only
-- Run this entire block in DBeaver to create etapa, tarefa, medicao tables

USE GilbertoLegacy;

-- Create etapa table
CREATE TABLE etapa (
    id int NOT NULL AUTO_INCREMENT,
    obra_id int NOT NULL,
    descricao varchar(500) NOT NULL,
    ordem int NOT NULL DEFAULT 1,
    ativo tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
);

-- Create tarefa table
CREATE TABLE tarefa (
    id int NOT NULL AUTO_INCREMENT,
    etapa_id int NOT NULL,
    descricao varchar(500) NOT NULL,
    quantidade_construida decimal(10,2) DEFAULT 0.00,
    ordem int NOT NULL DEFAULT 1,
    ativo tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
);

-- Create medicao table
CREATE TABLE medicao (
    id int NOT NULL AUTO_INCREMENT,
    tarefa_id int NOT NULL,
    data_medicao datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quantidade_medida decimal(10,2) NOT NULL DEFAULT 0.00,
    ativo tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
);

-- Insert etapas for Obra 233 (6 etapas)
INSERT INTO etapa (obra_id, descricao, ordem, ativo) VALUES
(233, 'Preparação do Terreno', 1, 1),
(233, 'Fundação', 2, 1),
(233, 'Estrutura', 3, 1),
(233, 'Cobertura', 4, 1),
(233, 'Acabamento', 5, 1),
(233, 'Finalização', 6, 1);

-- Insert tarefas for each etapa (17 tarefas total)
INSERT INTO tarefa (etapa_id, descricao, quantidade_construida, ordem, ativo) VALUES
-- Etapa 1 (Preparação)
(1, 'Limpeza do Terreno', 100.00, 1, 1),
(1, 'Marcação da Obra', 100.00, 2, 1),
(1, 'Escavação', 85.00, 3, 1),
-- Etapa 2 (Fundação)
(2, 'Armação da Fundação', 100.00, 1, 1),
(2, 'Concretagem da Fundação', 100.00, 2, 1),
(2, 'Cura do Concreto', 75.00, 3, 1),
-- Etapa 3 (Estrutura)
(3, 'Pilares', 90.00, 1, 1),
(3, 'Vigas', 60.00, 2, 1),
(3, 'Lajes', 0.00, 3, 1),
-- Etapa 4 (Cobertura)
(4, 'Estrutura do Telhado', 0.00, 1, 1),
(4, 'Telhas', 0.00, 2, 1),
(4, 'Calhas e Rufos', 0.00, 3, 1),
-- Etapa 5 (Acabamento)
(5, 'Reboco Interno', 0.00, 1, 1),
(5, 'Pintura', 0.00, 2, 1),
(5, 'Pisos', 0.00, 3, 1),
-- Etapa 6 (Finalização)
(6, 'Limpeza Final', 0.00, 1, 1),
(6, 'Entrega da Obra', 0.00, 2, 1);

-- Insert medicoes (MULTIPLE per tarefa - THIS CAUSES 30-CARD DUPLICATION)
INSERT INTO medicao (tarefa_id, data_medicao, quantidade_medida, ativo) VALUES
-- Tarefa 1 - Limpeza (5 medicoes)
(1, '2024-01-16 09:00:00', 20.00, 1),
(1, '2024-01-17 14:00:00', 40.00, 1),
(1, '2024-01-18 10:00:00', 60.00, 1),
(1, '2024-01-19 16:00:00', 80.00, 1),
(1, '2024-01-20 16:00:00', 100.00, 1),
-- Tarefa 2 - Marcação (3 medicoes)
(2, '2024-01-22 10:00:00', 30.00, 1),
(2, '2024-01-24 14:00:00', 70.00, 1),
(2, '2024-01-25 17:00:00', 100.00, 1),
-- Tarefa 3 - Escavação (4 medicoes)
(3, '2024-02-01 09:00:00', 25.00, 1),
(3, '2024-02-05 11:00:00', 50.00, 1),
(3, '2024-02-08 15:00:00', 70.00, 1),
(3, '2024-02-10 15:00:00', 85.00, 1),
-- Tarefa 4 - Armação (3 medicoes)
(4, '2024-02-20 08:30:00', 35.00, 1),
(4, '2024-02-25 14:00:00', 75.00, 1),
(4, '2024-02-28 17:00:00', 100.00, 1),
-- Tarefa 5 - Concretagem (2 medicoes)
(5, '2024-03-08 07:00:00', 60.00, 1),
(5, '2024-03-15 16:00:00', 100.00, 1),
-- Tarefa 6 - Cura (2 medicoes)
(6, '2024-03-20 10:00:00', 40.00, 1),
(6, '2024-03-25 14:00:00', 75.00, 1),
-- Tarefa 7 - Pilares (3 medicoes)
(7, '2024-04-10 09:00:00', 30.00, 1),
(7, '2024-04-20 13:00:00', 65.00, 1),
(7, '2024-04-25 15:00:00', 90.00, 1),
-- Tarefa 8 - Vigas (2 medicoes)
(8, '2024-05-10 08:00:00', 25.00, 1),
(8, '2024-05-20 14:00:00', 60.00, 1);

-- VERIFICATION: Check if data was created correctly
SELECT 'VERIFICATION RESULTS:' as status;
SELECT 'Etapas created:' as description, COUNT(*) as count FROM etapa WHERE obra_id = 233;
SELECT 'Tarefas created:' as description, COUNT(*) as count FROM tarefa WHERE etapa_id IN (SELECT id FROM etapa WHERE obra_id = 233);
SELECT 'Medicoes created:' as description, COUNT(*) as count FROM medicao WHERE tarefa_id IN (SELECT id FROM tarefa WHERE etapa_id IN (SELECT id FROM etapa WHERE obra_id = 233));

-- TEST THE 30-CARD DUPLICATION PROBLEM
SELECT 'PROBLEM QUERY (returns 30+ rows):' as test_description;
SELECT COUNT(*) as duplicate_cards_count
FROM etapa e
LEFT JOIN tarefa t ON e.id = t.etapa_id AND t.ativo = 1
LEFT JOIN medicao m ON t.id = m.tarefa_id AND m.ativo = 1
WHERE e.obra_id = 233 AND e.ativo = 1;

-- TEST THE CORRECT SOLUTION (should return 6 rows)
SELECT 'SOLUTION QUERY (should return 6):' as test_description;
SELECT COUNT(DISTINCT e.id) as correct_cards_count
FROM etapa e
WHERE e.obra_id = 233 AND e.ativo = 1;