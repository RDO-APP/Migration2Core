-- =====================================================
-- RDO APP LOCAL DATABASE EXPORT
-- Complete SQL script for DBeaver import
-- Includes: CREATE TABLE structures + INSERT data for Obra 233
-- =====================================================

-- Create database (adjust database name as needed for your local setup)
-- Note: You may need to create the database first in DBeaver, then run the rest

-- =====================================================
-- TABLE STRUCTURES
-- =====================================================

-- Create Obras table
CREATE TABLE IF NOT EXISTS `Obras` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `Descricao` varchar(500) NOT NULL,
    `DataInicio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `DataPrevisaoFim` datetime NULL,
    `DataFim` datetime NULL,
    `CidadeEstado` varchar(200) NULL,
    `StatusBasicaGratuita` varchar(100) NULL DEFAULT 'BÁSICA',
    `ContratanteContratada` varchar(50) NULL DEFAULT 'contratada',
    `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Etapas table
CREATE TABLE IF NOT EXISTS `Etapas` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `ObraId` int NOT NULL,
    `Descricao` varchar(500) NOT NULL,
    `Ordem` int NOT NULL DEFAULT 1,
    `DataInicio` datetime NULL,
    `DataPrevisaoFim` datetime NULL,
    `DataFim` datetime NULL,
    `Ativo` tinyint(1) NOT NULL DEFAULT 1,
    `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`),
    KEY `IX_Etapas_ObraId` (`ObraId`),
    CONSTRAINT `FK_Etapas_Obras` FOREIGN KEY (`ObraId`) REFERENCES `Obras` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create StatusTarefa table
CREATE TABLE IF NOT EXISTS `StatusTarefa` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `Descricao` varchar(100) NOT NULL,
    `Ativo` tinyint(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Tarefas table
CREATE TABLE IF NOT EXISTS `Tarefas` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `EtapaId` int NOT NULL,
    `Descricao` varchar(500) NOT NULL,
    `DataInicio` datetime NULL,
    `DataPrevisaoFim` datetime NULL,
    `DataFim` datetime NULL,
    `DataMedicao` datetime NULL DEFAULT CURRENT_TIMESTAMP,
    `QuantidadeConstruida` decimal(10,2) NULL DEFAULT 0.00,
    `StatusId` int NULL,
    `Ordem` int NOT NULL DEFAULT 1,
    `Ativo` tinyint(1) NOT NULL DEFAULT 1,
    `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`),
    KEY `IX_Tarefas_EtapaId` (`EtapaId`),
    KEY `IX_Tarefas_StatusId` (`StatusId`),
    CONSTRAINT `FK_Tarefas_Etapas` FOREIGN KEY (`EtapaId`) REFERENCES `Etapas` (`Id`),
    CONSTRAINT `FK_Tarefas_StatusTarefa` FOREIGN KEY (`StatusId`) REFERENCES `StatusTarefa` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Create Medicoes table
CREATE TABLE IF NOT EXISTS `Medicoes` (
    `Id` int NOT NULL AUTO_INCREMENT,
    `TarefaId` int NOT NULL,
    `DataMedicao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `QuantidadeMedida` decimal(10,2) NOT NULL DEFAULT 0.00,
    `Observacoes` text NULL,
    `UsuarioId` int NULL,
    `Ativo` tinyint(1) NOT NULL DEFAULT 1,
    `CreatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `UpdatedAt` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`Id`),
    KEY `IX_Medicoes_TarefaId` (`TarefaId`),
    KEY `IX_Medicoes_DataMedicao` (`DataMedicao`),
    CONSTRAINT `FK_Medicoes_Tarefas` FOREIGN KEY (`TarefaId`) REFERENCES `Tarefas` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =====================================================
-- DATA INSERTS
-- =====================================================

-- Insert StatusTarefa data
INSERT INTO `StatusTarefa` (`Id`, `Descricao`, `Ativo`) VALUES
(1, 'Planejada', 1),
(2, 'Em Andamento', 1),
(3, 'Concluída', 1),
(4, 'Pausada', 1),
(5, 'Cancelada', 0);

-- Insert Obra 233 (test obra)
INSERT INTO `Obras` (`Id`, `Descricao`, `DataInicio`, `DataPrevisaoFim`, `CidadeEstado`, `StatusBasicaGratuita`, `ContratanteContratada`) VALUES
(233, 'ESCOLA MUNICIPAL TESTE LOCAL', '2024-01-15 08:00:00', '2024-12-31 18:00:00', 'São Paulo/SP', 'BÁSICA', 'contratada');

-- Insert Etapas for Obra 233
INSERT INTO `Etapas` (`Id`, `ObraId`, `Descricao`, `Ordem`, `DataInicio`, `DataPrevisaoFim`, `Ativo`) VALUES
(1, 233, 'Preparação do Terreno', 1, '2024-01-15 08:00:00', '2024-02-15 18:00:00', 1),
(2, 233, 'Fundação', 2, '2024-02-16 08:00:00', '2024-03-31 18:00:00', 1),
(3, 233, 'Estrutura', 3, '2024-04-01 08:00:00', '2024-06-30 18:00:00', 1),
(4, 233, 'Cobertura', 4, '2024-07-01 08:00:00', '2024-08-31 18:00:00', 1),
(5, 233, 'Acabamento', 5, '2024-09-01 08:00:00', '2024-11-30 18:00:00', 1),
(6, 233, 'Finalização', 6, '2024-12-01 08:00:00', '2024-12-31 18:00:00', 1);

-- Insert Tarefas for Etapa 1 - Preparação do Terreno
INSERT INTO `Tarefas` (`Id`, `EtapaId`, `Descricao`, `DataInicio`, `DataPrevisaoFim`, `DataMedicao`, `QuantidadeConstruida`, `StatusId`, `Ordem`, `Ativo`) VALUES
(1, 1, 'Limpeza do Terreno', '2024-01-15 08:00:00', '2024-01-20 18:00:00', '2024-01-20 16:00:00', 100.00, 3, 1, 1),
(2, 1, 'Marcação da Obra', '2024-01-21 08:00:00', '2024-01-25 18:00:00', '2024-01-25 17:00:00', 100.00, 3, 2, 1),
(3, 1, 'Escavação', '2024-01-26 08:00:00', '2024-02-15 18:00:00', '2024-02-10 15:00:00', 85.00, 2, 3, 1);

-- Insert Tarefas for Etapa 2 - Fundação
INSERT INTO `Tarefas` (`Id`, `EtapaId`, `Descricao`, `DataInicio`, `DataPrevisaoFim`, `DataMedicao`, `QuantidadeConstruida`, `StatusId`, `Ordem`, `Ativo`) VALUES
(4, 2, 'Armação da Fundação', '2024-02-16 08:00:00', '2024-02-28 18:00:00', '2024-02-28 17:00:00', 100.00, 3, 1, 1),
(5, 2, 'Concretagem da Fundação', '2024-03-01 08:00:00', '2024-03-15 18:00:00', '2024-03-15 16:00:00', 100.00, 3, 2, 1),
(6, 2, 'Cura do Concreto', '2024-03-16 08:00:00', '2024-03-31 18:00:00', '2024-03-25 14:00:00', 75.00, 2, 3, 1);

-- Insert Tarefas for Etapa 3 - Estrutura
INSERT INTO `Tarefas` (`Id`, `EtapaId`, `Descricao`, `DataInicio`, `DataPrevisaoFim`, `DataMedicao`, `QuantidadeConstruida`, `StatusId`, `Ordem`, `Ativo`) VALUES
(7, 3, 'Pilares', '2024-04-01 08:00:00', '2024-04-30 18:00:00', '2024-04-25 15:00:00', 90.00, 2, 1, 1),
(8, 3, 'Vigas', '2024-05-01 08:00:00', '2024-05-31 18:00:00', '2024-05-20 14:00:00', 60.00, 2, 2, 1),
(9, 3, 'Lajes', '2024-06-01 08:00:00', '2024-06-30 18:00:00', NULL, 0.00, 1, 3, 1);

-- Insert Tarefas for Etapa 4 - Cobertura
INSERT INTO `Tarefas` (`Id`, `EtapaId`, `Descricao`, `DataInicio`, `DataPrevisaoFim`, `DataMedicao`, `QuantidadeConstruida`, `StatusId`, `Ordem`, `Ativo`) VALUES
(10, 4, 'Estrutura do Telhado', '2024-07-01 08:00:00', '2024-07-20 18:00:00', NULL, 0.00, 1, 1, 1),
(11, 4, 'Telhas', '2024-07-21 08:00:00', '2024-08-10 18:00:00', NULL, 0.00, 1, 2, 1),
(12, 4, 'Calhas e Rufos', '2024-08-11 08:00:00', '2024-08-31 18:00:00', NULL, 0.00, 1, 3, 1);

-- Insert Tarefas for Etapa 5 - Acabamento
INSERT INTO `Tarefas` (`Id`, `EtapaId`, `Descricao`, `DataInicio`, `DataPrevisaoFim`, `DataMedicao`, `QuantidadeConstruida`, `StatusId`, `Ordem`, `Ativo`) VALUES
(13, 5, 'Reboco Interno', '2024-09-01 08:00:00', '2024-09-30 18:00:00', NULL, 0.00, 1, 1, 1),
(14, 5, 'Pintura', '2024-10-01 08:00:00', '2024-10-31 18:00:00', NULL, 0.00, 1, 2, 1),
(15, 5, 'Pisos', '2024-11-01 08:00:00', '2024-11-30 18:00:00', NULL, 0.00, 1, 3, 1);

-- Insert Tarefas for Etapa 6 - Finalização
INSERT INTO `Tarefas` (`Id`, `EtapaId`, `Descricao`, `DataInicio`, `DataPrevisaoFim`, `DataMedicao`, `QuantidadeConstruida`, `StatusId`, `Ordem`, `Ativo`) VALUES
(16, 6, 'Limpeza Final', '2024-12-01 08:00:00', '2024-12-15 18:00:00', NULL, 0.00, 1, 1, 1),
(17, 6, 'Entrega da Obra', '2024-12-16 08:00:00', '2024-12-31 18:00:00', NULL, 0.00, 1, 2, 1);

-- Insert historical Medicoes for completed and in-progress tasks
-- Medicoes for Tarefa 1 - Limpeza do Terreno (Completed)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(1, '2024-01-18 10:00:00', 50.00, 'Primeira medição - 50% concluído', 1),
(1, '2024-01-20 16:00:00', 100.00, 'Tarefa concluída', 1);

-- Medicoes for Tarefa 2 - Marcação da Obra (Completed)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(2, '2024-01-23 14:00:00', 75.00, 'Marcação quase completa', 1),
(2, '2024-01-25 17:00:00', 100.00, 'Marcação finalizada', 1);

-- Medicoes for Tarefa 3 - Escavação (In Progress)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(3, '2024-02-01 09:00:00', 30.00, 'Início da escavação', 1),
(3, '2024-02-05 11:00:00', 60.00, 'Progresso da escavação', 1),
(3, '2024-02-10 15:00:00', 85.00, 'Escavação quase completa', 1);

-- Medicoes for Tarefa 4 - Armação da Fundação (Completed)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(4, '2024-02-20 08:30:00', 40.00, 'Início da armação', 1),
(4, '2024-02-25 14:00:00', 80.00, 'Armação avançada', 1),
(4, '2024-02-28 17:00:00', 100.00, 'Armação concluída', 1);

-- Medicoes for Tarefa 5 - Concretagem da Fundação (Completed)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(5, '2024-03-05 07:00:00', 50.00, 'Primeira concretagem', 1),
(5, '2024-03-10 08:00:00', 80.00, 'Segunda concretagem', 1),
(5, '2024-03-15 16:00:00', 100.00, 'Concretagem finalizada', 1);

-- Medicoes for Tarefa 6 - Cura do Concreto (In Progress)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(6, '2024-03-20 10:00:00', 25.00, 'Início da cura', 1),
(6, '2024-03-25 14:00:00', 75.00, 'Cura em andamento', 1);

-- Medicoes for Tarefa 7 - Pilares (In Progress)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(7, '2024-04-10 09:00:00', 30.00, 'Primeiros pilares', 1),
(7, '2024-04-20 13:00:00', 70.00, 'Maioria dos pilares', 1),
(7, '2024-04-25 15:00:00', 90.00, 'Pilares quase prontos', 1);

-- Medicoes for Tarefa 8 - Vigas (In Progress)
INSERT INTO `Medicoes` (`TarefaId`, `DataMedicao`, `QuantidadeMedida`, `Observacoes`, `Ativo`) VALUES
(8, '2024-05-10 08:00:00', 20.00, 'Início das vigas', 1),
(8, '2024-05-20 14:00:00', 60.00, 'Vigas em andamento', 1);

-- =====================================================
-- VERIFICATION QUERIES (Optional - for testing)
-- =====================================================

-- Uncomment these to verify your data after import:

-- SELECT 'Obras Count' as TableName, COUNT(*) as RecordCount FROM Obras;
-- SELECT 'Etapas Count' as TableName, COUNT(*) as RecordCount FROM Etapas;
-- SELECT 'Tarefas Count' as TableName, COUNT(*) as RecordCount FROM Tarefas;
-- SELECT 'Medicoes Count' as TableName, COUNT(*) as RecordCount FROM Medicoes;
-- SELECT 'StatusTarefa Count' as TableName, COUNT(*) as RecordCount FROM StatusTarefa;

-- Test the Group By logic that was causing issues:
-- SELECT 
--     e.Id as EtapaId,
--     e.Descricao as EtapaDescricao,
--     COUNT(t.Id) as TotalTarefas,
--     SUM(CASE WHEN t.StatusId = 3 THEN 1 ELSE 0 END) as TarefasConcluidas,
--     AVG(t.QuantidadeConstruida) as MediaProgresso
-- FROM Etapas e
-- LEFT JOIN Tarefas t ON e.Id = t.EtapaId
-- WHERE e.ObraId = 233 AND e.Ativo = 1
-- GROUP BY e.Id, e.Descricao, e.Ordem
-- ORDER BY e.Ordem;

-- =====================================================
-- SCRIPT COMPLETE
-- =====================================================