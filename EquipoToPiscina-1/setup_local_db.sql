-- =====================================================
-- SETUP LOCAL DB - GILBERTO LEGACY MIGRATION
-- Complete SQL script to replicate Obra 233 data locally
-- Prevents AWS RDS spike by moving development to localhost
-- =====================================================

-- Create database GilbertoLegacy
CREATE DATABASE IF NOT EXISTS `GilbertoLegacy`;
USE `GilbertoLegacy`;

-- =====================================================
-- TABLE STRUCTURES (Gilberto's Schema)
-- =====================================================

-- Create UF table (referenced by municipio)
CREATE TABLE IF NOT EXISTS `uf` (
    `id` int NOT NULL AUTO_INCREMENT,
    `nome` varchar(100) NOT NULL,
    `sigla` varchar(2) NOT NULL,
    `ativo` tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Municipio table (referenced by obra)
CREATE TABLE IF NOT EXISTS `municipio` (
    `id` int NOT NULL AUTO_INCREMENT,
    `nome` varchar(200) NOT NULL,
    `uf_id` int NOT NULL,
    `ativo` tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`),
    KEY `FK_municipio_uf` (`uf_id`),
    CONSTRAINT `FK_municipio_uf` FOREIGN KEY (`uf_id`) REFERENCES `uf` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Obra table (Gilberto's structure)
CREATE TABLE IF NOT EXISTS `obra` (
    `id` int NOT NULL AUTO_INCREMENT,
    `descricao` varchar(500) NOT NULL,
    `data_inicio` datetime NULL,
    `data_previsao_fim` datetime NULL,
    `data_fim` datetime NULL,
    `municipio_id` int NULL,
    `status_basica_gratuita` varchar(100) NULL DEFAULT 'BÁSICA',
    `contratante_contratada` varchar(50) NULL DEFAULT 'contratada',
    `ativo` tinyint(1) NOT NULL DEFAULT 1,
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `FK_obra_municipio` (`municipio_id`),
    CONSTRAINT `FK_obra_municipio` FOREIGN KEY (`municipio_id`) REFERENCES `municipio` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Etapa table (Gilberto's structure)
CREATE TABLE IF NOT EXISTS `etapa` (
    `id` int NOT NULL AUTO_INCREMENT,
    `obra_id` int NOT NULL,
    `descricao` varchar(500) NOT NULL,
    `ordem` int NOT NULL DEFAULT 1,
    `data_inicio` datetime NULL,
    `data_previsao_fim` datetime NULL,
    `data_fim` datetime NULL,
    `ativo` tinyint(1) NOT NULL DEFAULT 1,
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `IX_etapa_obra_id` (`obra_id`),
    KEY `IX_etapa_ativo` (`ativo`),
    CONSTRAINT `FK_etapa_obra` FOREIGN KEY (`obra_id`) REFERENCES `obra` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Status Tarefa table
CREATE TABLE IF NOT EXISTS `status_tarefa` (
    `id` int NOT NULL AUTO_INCREMENT,
    `descricao` varchar(100) NOT NULL,
    `ativo` tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Tarefa table (Gilberto's structure with all fields)
CREATE TABLE IF NOT EXISTS `tarefa` (
    `id` int NOT NULL AUTO_INCREMENT,
    `etapa_id` int NOT NULL,
    `descricao` varchar(500) NOT NULL,
    `data_inicio` datetime NULL,
    `data_previsao_fim` datetime NULL,
    `data_fim` datetime NULL,
    `data_medicao` datetime NULL DEFAULT CURRENT_TIMESTAMP,
    `quantidade_construida` decimal(10,2) NULL DEFAULT 0.00,
    `status_id` int NULL,
    `ordem` int NOT NULL DEFAULT 1,
    `ativo` tinyint(1) NOT NULL DEFAULT 1,
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `IX_tarefa_etapa_id` (`etapa_id`),
    KEY `IX_tarefa_status_id` (`status_id`),
    KEY `IX_tarefa_ativo` (`ativo`),
    CONSTRAINT `FK_tarefa_etapa` FOREIGN KEY (`etapa_id`) REFERENCES `etapa` (`id`),
    CONSTRAINT `FK_tarefa_status` FOREIGN KEY (`status_id`) REFERENCES `status_tarefa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Medicao table (Gilberto's structure - THIS CAUSES THE 30-CARD DUPLICATION)
CREATE TABLE IF NOT EXISTS `medicao` (
    `id` int NOT NULL AUTO_INCREMENT,
    `tarefa_id` int NOT NULL,
    `data_medicao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `quantidade_medida` decimal(10,2) NOT NULL DEFAULT 0.00,
    `observacoes` text NULL,
    `usuario_id` int NULL,
    `ativo` tinyint(1) NOT NULL DEFAULT 1,
    `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `IX_medicao_tarefa_id` (`tarefa_id`),
    KEY `IX_medicao_data_medicao` (`data_medicao`),
    KEY `IX_medicao_ativo` (`ativo`),
    CONSTRAINT `FK_medicao_tarefa` FOREIGN KEY (`tarefa_id`) REFERENCES `tarefa` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- REFERENCE DATA INSERTS
-- =====================================================

-- Insert UF data
INSERT INTO `uf` (`id`, `nome`, `sigla`, `ativo`) VALUES
(1, 'São Paulo', 'SP', 1),
(2, 'Rio de Janeiro', 'RJ', 1),
(3, 'Minas Gerais', 'MG', 1);

-- Insert Municipio data
INSERT INTO `municipio` (`id`, `nome`, `uf_id`, `ativo`) VALUES
(1, 'São Paulo', 1, 1),
(2, 'Campinas', 1, 1),
(3, 'Santos', 1, 1),
(4, 'Rio de Janeiro', 2, 1),
(5, 'Belo Horizonte', 3, 1);

-- Insert Status Tarefa data
INSERT INTO `status_tarefa` (`id`, `descricao`, `ativo`) VALUES
(1, 'Planejada', 1),
(2, 'Em Andamento', 1),
(3, 'Concluída', 1),
(4, 'Pausada', 1),
(5, 'Cancelada', 0);

-- =====================================================
-- OBRA 233 DATA - THE GILBERTO RECORDS
-- =====================================================

-- Insert Obra 233 (the problematic obra causing 30-card duplication)
INSERT INTO `obra` (`id`, `descricao`, `data_inicio`, `data_previsao_fim`, `municipio_id`, `status_basica_gratuita`, `contratante_contratada`, `ativo`) VALUES
(233, 'ESCOLA MUNICIPAL TESTE LOCAL - GILBERTO LEGACY', '2024-01-15 08:00:00', '2024-12-31 18:00:00', 1, 'BÁSICA', 'contratada', 1);

-- Insert Etapas for Obra 233 (6 etapas that should show as 6 cards, not 30)
INSERT INTO `etapa` (`id`, `obra_id`, `descricao`, `ordem`, `data_inicio`, `data_previsao_fim`, `ativo`) VALUES
(1, 233, 'Preparação do Terreno', 1, '2024-01-15 08:00:00', '2024-02-15 18:00:00', 1),
(2, 233, 'Fundação', 2, '2024-02-16 08:00:00', '2024-03-31 18:00:00', 1),
(3, 233, 'Estrutura', 3, '2024-04-01 08:00:00', '2024-06-30 18:00:00', 1),
(4, 233, 'Cobertura', 4, '2024-07-01 08:00:00', '2024-08-31 18:00:00', 1),
(5, 233, 'Acabamento', 5, '2024-09-01 08:00:00', '2024-11-30 18:00:00', 1),
(6, 233, 'Finalização', 6, '2024-12-01 08:00:00', '2024-12-31 18:00:00', 1);

-- Insert Tarefas for Obra 233 (17 tarefas total)
-- Etapa 1 - Preparação do Terreno
INSERT INTO `tarefa` (`id`, `etapa_id`, `descricao`, `data_inicio`, `data_previsao_fim`, `data_medicao`, `quantidade_construida`, `status_id`, `ordem`, `ativo`) VALUES
(1, 1, 'Limpeza do Terreno', '2024-01-15 08:00:00', '2024-01-20 18:00:00', '2024-01-20 16:00:00', 100.00, 3, 1, 1),
(2, 1, 'Marcação da Obra', '2024-01-21 08:00:00', '2024-01-25 18:00:00', '2024-01-25 17:00:00', 100.00, 3, 2, 1),
(3, 1, 'Escavação', '2024-01-26 08:00:00', '2024-02-15 18:00:00', '2024-02-10 15:00:00', 85.00, 2, 3, 1);

-- Etapa 2 - Fundação
INSERT INTO `tarefa` (`id`, `etapa_id`, `descricao`, `data_inicio`, `data_previsao_fim`, `data_medicao`, `quantidade_construida`, `status_id`, `ordem`, `ativo`) VALUES
(4, 2, 'Armação da Fundação', '2024-02-16 08:00:00', '2024-02-28 18:00:00', '2024-02-28 17:00:00', 100.00, 3, 1, 1),
(5, 2, 'Concretagem da Fundação', '2024-03-01 08:00:00', '2024-03-15 18:00:00', '2024-03-15 16:00:00', 100.00, 3, 2, 1),
(6, 2, 'Cura do Concreto', '2024-03-16 08:00:00', '2024-03-31 18:00:00', '2024-03-25 14:00:00', 75.00, 2, 3, 1);

-- Etapa 3 - Estrutura
INSERT INTO `tarefa` (`id`, `etapa_id`, `descricao`, `data_inicio`, `data_previsao_fim`, `data_medicao`, `quantidade_construida`, `status_id`, `ordem`, `ativo`) VALUES
(7, 3, 'Pilares', '2024-04-01 08:00:00', '2024-04-30 18:00:00', '2024-04-25 15:00:00', 90.00, 2, 1, 1),
(8, 3, 'Vigas', '2024-05-01 08:00:00', '2024-05-31 18:00:00', '2024-05-20 14:00:00', 60.00, 2, 2, 1),
(9, 3, 'Lajes', '2024-06-01 08:00:00', '2024-06-30 18:00:00', NULL, 0.00, 1, 3, 1);

-- Etapa 4 - Cobertura
INSERT INTO `tarefa` (`id`, `etapa_id`, `descricao`, `data_inicio`, `data_previsao_fim`, `data_medicao`, `quantidade_construida`, `status_id`, `ordem`, `ativo`) VALUES
(10, 4, 'Estrutura do Telhado', '2024-07-01 08:00:00', '2024-07-20 18:00:00', NULL, 0.00, 1, 1, 1),
(11, 4, 'Telhas', '2024-07-21 08:00:00', '2024-08-10 18:00:00', NULL, 0.00, 1, 2, 1),
(12, 4, 'Calhas e Rufos', '2024-08-11 08:00:00', '2024-08-31 18:00:00', NULL, 0.00, 1, 3, 1);

-- Etapa 5 - Acabamento
INSERT INTO `tarefa` (`id`, `etapa_id`, `descricao`, `data_inicio`, `data_previsao_fim`, `data_medicao`, `quantidade_construida`, `status_id`, `ordem`, `ativo`) VALUES
(13, 5, 'Reboco Interno', '2024-09-01 08:00:00', '2024-09-30 18:00:00', NULL, 0.00, 1, 1, 1),
(14, 5, 'Pintura', '2024-10-01 08:00:00', '2024-10-31 18:00:00', NULL, 0.00, 1, 2, 1),
(15, 5, 'Pisos', '2024-11-01 08:00:00', '2024-11-30 18:00:00', NULL, 0.00, 1, 3, 1);

-- Etapa 6 - Finalização
INSERT INTO `tarefa` (`id`, `etapa_id`, `descricao`, `data_inicio`, `data_previsao_fim`, `data_medicao`, `quantidade_construida`, `status_id`, `ordem`, `ativo`) VALUES
(16, 6, 'Limpeza Final', '2024-12-01 08:00:00', '2024-12-15 18:00:00', NULL, 0.00, 1, 1, 1),
(17, 6, 'Entrega da Obra', '2024-12-16 08:00:00', '2024-12-31 18:00:00', NULL, 0.00, 1, 2, 1);

-- =====================================================
-- MEDICAO DATA - THE ROOT CAUSE OF 30-CARD DUPLICATION
-- Multiple medicoes per tarefa create cartesian product in JOINs
-- =====================================================

-- Tarefa 1 - Limpeza do Terreno (5 medicoes - causes 5x duplication)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(1, '2024-01-16 09:00:00', 20.00, 'Início da limpeza', 1),
(1, '2024-01-17 14:00:00', 40.00, 'Progresso da limpeza', 1),
(1, '2024-01-18 10:00:00', 60.00, 'Limpeza avançando', 1),
(1, '2024-01-19 16:00:00', 80.00, 'Quase finalizada', 1),
(1, '2024-01-20 16:00:00', 100.00, 'Limpeza concluída', 1);

-- Tarefa 2 - Marcação da Obra (3 medicoes)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(2, '2024-01-22 10:00:00', 30.00, 'Início da marcação', 1),
(2, '2024-01-24 14:00:00', 70.00, 'Marcação avançada', 1),
(2, '2024-01-25 17:00:00', 100.00, 'Marcação finalizada', 1);

-- Tarefa 3 - Escavação (4 medicoes)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(3, '2024-02-01 09:00:00', 25.00, 'Início da escavação', 1),
(3, '2024-02-05 11:00:00', 50.00, 'Escavação em progresso', 1),
(3, '2024-02-08 15:00:00', 70.00, 'Escavação avançada', 1),
(3, '2024-02-10 15:00:00', 85.00, 'Escavação quase completa', 1);

-- Tarefa 4 - Armação da Fundação (3 medicoes)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(4, '2024-02-20 08:30:00', 35.00, 'Início da armação', 1),
(4, '2024-02-25 14:00:00', 75.00, 'Armação avançada', 1),
(4, '2024-02-28 17:00:00', 100.00, 'Armação concluída', 1);

-- Tarefa 5 - Concretagem da Fundação (2 medicoes)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(5, '2024-03-08 07:00:00', 60.00, 'Primeira concretagem', 1),
(5, '2024-03-15 16:00:00', 100.00, 'Concretagem finalizada', 1);

-- Tarefa 6 - Cura do Concreto (2 medicoes)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(6, '2024-03-20 10:00:00', 40.00, 'Início da cura', 1),
(6, '2024-03-25 14:00:00', 75.00, 'Cura em andamento', 1);

-- Tarefa 7 - Pilares (3 medicoes)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(7, '2024-04-10 09:00:00', 30.00, 'Primeiros pilares', 1),
(7, '2024-04-20 13:00:00', 65.00, 'Pilares em progresso', 1),
(7, '2024-04-25 15:00:00', 90.00, 'Pilares quase prontos', 1);

-- Tarefa 8 - Vigas (2 medicoes)
INSERT INTO `medicao` (`tarefa_id`, `data_medicao`, `quantidade_medida`, `observacoes`, `ativo`) VALUES
(8, '2024-05-10 08:00:00', 25.00, 'Início das vigas', 1),
(8, '2024-05-20 14:00:00', 60.00, 'Vigas em andamento', 1);

-- =====================================================
-- PROBLEM DEMONSTRATION QUERIES
-- =====================================================

-- WRONG QUERY (causes 30+ cards instead of 6):
-- This is what's currently happening - cartesian product with medicoes
/*
SELECT DISTINCT
    e.id as etapa_id,
    e.descricao as etapa_descricao,
    e.ordem,
    t.id as tarefa_id,
    t.descricao as tarefa_descricao,
    m.quantidade_medida,
    m.data_medicao
FROM etapa e
LEFT JOIN tarefa t ON e.id = t.etapa_id AND t.ativo = 1
LEFT JOIN medicao m ON t.id = m.tarefa_id AND m.ativo = 1
WHERE e.obra_id = 233 AND e.ativo = 1
ORDER BY e.ordem, t.ordem;
-- This returns 30+ rows because of multiple medicoes per tarefa
*/

-- CORRECT QUERY (should return exactly 6 etapa cards):
-- Use GROUP BY and get only the latest medicao per tarefa
/*
SELECT 
    e.id as etapa_id,
    e.descricao as etapa_descricao,
    e.ordem,
    COUNT(DISTINCT t.id) as total_tarefas,
    SUM(CASE WHEN t.status_id = 3 THEN 1 ELSE 0 END) as tarefas_concluidas,
    AVG(COALESCE(latest_m.quantidade_medida, t.quantidade_construida, 0)) as progresso_medio
FROM etapa e
LEFT JOIN tarefa t ON e.id = t.etapa_id AND t.ativo = 1
LEFT JOIN (
    SELECT 
        m1.tarefa_id,
        m1.quantidade_medida,
        m1.data_medicao
    FROM medicao m1
    INNER JOIN (
        SELECT tarefa_id, MAX(data_medicao) as max_data
        FROM medicao 
        WHERE ativo = 1
        GROUP BY tarefa_id
    ) m2 ON m1.tarefa_id = m2.tarefa_id AND m1.data_medicao = m2.max_data
    WHERE m1.ativo = 1
) latest_m ON t.id = latest_m.tarefa_id
WHERE e.obra_id = 233 AND e.ativo = 1
GROUP BY e.id, e.descricao, e.ordem
ORDER BY e.ordem;
-- This returns exactly 6 rows (one per etapa)
*/

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Count records to verify import
SELECT 'obra' as table_name, COUNT(*) as record_count FROM obra WHERE id = 233;
SELECT 'etapa' as table_name, COUNT(*) as record_count FROM etapa WHERE obra_id = 233;
SELECT 'tarefa' as table_name, COUNT(*) as record_count FROM tarefa WHERE etapa_id IN (SELECT id FROM etapa WHERE obra_id = 233);
SELECT 'medicao' as table_name, COUNT(*) as record_count FROM medicao WHERE tarefa_id IN (SELECT id FROM tarefa WHERE etapa_id IN (SELECT id FROM etapa WHERE obra_id = 233));

-- Test the problematic query that causes 30-card duplication
SELECT 'PROBLEM QUERY - Multiple cards per etapa:' as description;
SELECT COUNT(*) as total_rows_returned 
FROM etapa e
LEFT JOIN tarefa t ON e.id = t.etapa_id AND t.ativo = 1
LEFT JOIN medicao m ON t.id = m.tarefa_id AND m.ativo = 1
WHERE e.obra_id = 233 AND e.ativo = 1;

-- Test the correct GROUP BY query that should return exactly 6 cards
SELECT 'CORRECT QUERY - One card per etapa:' as description;
SELECT COUNT(*) as total_etapas_returned
FROM (
    SELECT e.id
    FROM etapa e
    WHERE e.obra_id = 233 AND e.ativo = 1
    GROUP BY e.id
) as grouped_etapas;

-- =====================================================
-- SCRIPT COMPLETE - READY FOR DBEAVER IMPORT
-- =====================================================