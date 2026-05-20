-- =====================================================
-- LOCAL DATABASE MIGRATION SCRIPT FOR RDO APP
-- =====================================================
-- This script creates a complete local database with:
-- 1. All essential tables (etapa, tarefa, medicao)
-- 2. Historical data for Obra 233 (your test case)
-- 3. Optimized for Group By debugging
-- =====================================================

USE master;
GO

-- Drop existing database if it exists (for clean migration)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RdoAppLocal')
BEGIN
    ALTER DATABASE RdoAppLocal SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RdoAppLocal;
END
GO

-- Create fresh database
CREATE DATABASE RdoAppLocal;
GO

USE RdoAppLocal;
GO

-- =====================================================
-- TABLE STRUCTURES
-- =====================================================

-- Create Obra table
CREATE TABLE Obras (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Descricao nvarchar(500) NOT NULL,
    DataInicio datetime2 NOT NULL DEFAULT GETDATE(),
    DataPrevisaoFim datetime2 NULL,
    DataFim datetime2 NULL,
    CidadeEstado nvarchar(200) NULL,
    StatusBasicaGratuita nvarchar(100) NULL DEFAULT 'BÁSICA',
    ContratanteContratada nvarchar(50) NULL DEFAULT 'contratada',
    Ativo bit NOT NULL DEFAULT 1,
    CreatedAt datetime2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt datetime2 NOT NULL DEFAULT GETDATE()
);

-- Create Etapa table
CREATE TABLE Etapas (
    Id int IDENTITY(1,1) PRIMARY KEY,
    ObraId int NOT NULL,
    Descricao nvarchar(500) NOT NULL,
    Ordem int NOT NULL DEFAULT 1,
    DataInicio datetime2 NULL,
    DataPrevisaoFim datetime2 NULL,
    DataFim datetime2 NULL,
    Ativo bit NOT NULL DEFAULT 1,
    CreatedAt datetime2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt datetime2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Etapas_Obras FOREIGN KEY (ObraId) REFERENCES Obras(Id)
);

-- Create StatusTarefa table
CREATE TABLE StatusTarefa (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Descricao nvarchar(100) NOT NULL,
    Cor nvarchar(20) NULL DEFAULT '#007bff',
    Ativo bit NOT NULL DEFAULT 1,
    CreatedAt datetime2 NOT NULL DEFAULT GETDATE()
);

-- Create Tarefa table (enhanced for Group By testing)
CREATE TABLE Tarefas (
    Id int IDENTITY(1,1) PRIMARY KEY,
    EtapaId int NOT NULL,
    Descricao nvarchar(500) NOT NULL,
    DataInicio datetime2 NULL,
    DataPrevisaoFim datetime2 NULL,
    DataFim datetime2 NULL,
    DataMedicao datetime2 NULL DEFAULT GETDATE(),
    QuantidadeConstruida float NULL DEFAULT 0,
    StatusId int NULL,
    Ordem int NOT NULL DEFAULT 1,
    Ativo bit NOT NULL DEFAULT 1,
    -- Additional fields for comprehensive testing
    UnidadeMedida nvarchar(50) NULL DEFAULT 'm²',
    QuantidadePlanejada float NULL DEFAULT 0,
    PercentualConcluido AS (
        CASE 
            WHEN QuantidadePlanejada > 0 
            THEN (QuantidadeConstruida / QuantidadePlanejada) * 100 
            ELSE 0 
        END
    ) PERSISTED,
    CreatedAt datetime2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt datetime2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Tarefas_Etapas FOREIGN KEY (EtapaId) REFERENCES Etapas(Id),
    CONSTRAINT FK_Tarefas_StatusTarefa FOREIGN KEY (StatusId) REFERENCES StatusTarefa(Id)
);

-- Create Medicao table (enhanced for Group By analysis)
CREATE TABLE Medicoes (
    Id int IDENTITY(1,1) PRIMARY KEY,
    TarefaId int NOT NULL,
    DataMedicao datetime2 NOT NULL DEFAULT GETDATE(),
    QuantidadeMedida float NOT NULL DEFAULT 0,
    QuantidadeAcumulada float NULL DEFAULT 0,
    Observacoes nvarchar(1000) NULL,
    UsuarioId int NULL DEFAULT 1,
    TipoMedicao nvarchar(50) NULL DEFAULT 'PROGRESSO',
    Ativo bit NOT NULL DEFAULT 1,
    CreatedAt datetime2 NOT NULL DEFAULT GETDATE(),
    UpdatedAt datetime2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Medicoes_Tarefas FOREIGN KEY (TarefaId) REFERENCES Tarefas(Id)
);

-- Create Usuario table (minimal for testing)
CREATE TABLE Usuarios (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Nome nvarchar(200) NOT NULL,
    Email nvarchar(200) NOT NULL,
    Ativo bit NOT NULL DEFAULT 1,
    CreatedAt datetime2 NOT NULL DEFAULT GETDATE()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE (Group By optimization)
-- =====================================================
CREATE INDEX IX_Etapas_ObraId ON Etapas(ObraId);
CREATE INDEX IX_Etapas_Ativo ON Etapas(Ativo);
CREATE INDEX IX_Tarefas_EtapaId ON Tarefas(EtapaId);
CREATE INDEX IX_Tarefas_StatusId ON Tarefas(StatusId);
CREATE INDEX IX_Tarefas_Ativo ON Tarefas(Ativo);
CREATE INDEX IX_Medicoes_TarefaId ON Medicoes(TarefaId);
CREATE INDEX IX_Medicoes_DataMedicao ON Medicoes(DataMedicao);
CREATE INDEX IX_Medicoes_Ativo ON Medicoes(Ativo);

-- Composite indexes for Group By queries
CREATE INDEX IX_Tarefas_EtapaId_StatusId_Ativo ON Tarefas(EtapaId, StatusId, Ativo);
CREATE INDEX IX_Medicoes_TarefaId_DataMedicao ON Medicoes(TarefaId, DataMedicao);

-- =====================================================
-- REFERENCE DATA
-- =====================================================

-- Insert StatusTarefa data
INSERT INTO StatusTarefa (Descricao, Cor, Ativo) VALUES
('Planejada', '#6c757d', 1),
('Em Andamento', '#ffc107', 1),
('Concluída', '#28a745', 1),
('Pausada', '#fd7e14', 1),
('Cancelada', '#dc3545', 0),
('Aguardando', '#17a2b8', 1);

-- Insert test user
INSERT INTO Usuarios (Nome, Email) VALUES
('Usuário Teste', 'teste@rdoapp.com');

-- =====================================================
-- OBRA 233 TEST DATA (Enhanced for Group By testing)
-- =====================================================

-- Insert Obra 233
SET IDENTITY_INSERT Obras ON;
INSERT INTO Obras (Id, Descricao, DataInicio, DataPrevisaoFim, CidadeEstado, StatusBasicaGratuita, ContratanteContratada, Ativo) VALUES
(233, 'ESCOLA MUNICIPAL TESTE LOCAL - GROUP BY DEBUG', '2024-01-15', '2024-12-31', 'São Paulo/SP', 'BÁSICA', 'contratada', 1);
SET IDENTITY_INSERT Obras OFF;

-- Insert Etapas for Obra 233 (6 etapas with varied status)
INSERT INTO Etapas (ObraId, Descricao, Ordem, DataInicio, DataPrevisaoFim, Ativo) VALUES
(233, 'Preparação do Terreno', 1, '2024-01-15', '2024-02-15', 1),
(233, 'Fundação', 2, '2024-02-16', '2024-03-31', 1),
(233, 'Estrutura', 3, '2024-04-01', '2024-06-30', 1),
(233, 'Cobertura', 4, '2024-07-01', '2024-08-31', 1),
(233, 'Acabamento', 5, '2024-09-01', '2024-11-30', 1),
(233, 'Finalização', 6, '2024-12-01', '2024-12-31', 1);

-- Get Etapa IDs for reference
DECLARE @EtapaId1 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Preparação do Terreno');
DECLARE @EtapaId2 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Fundação');
DECLARE @EtapaId3 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Estrutura');
DECLARE @EtapaId4 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Cobertura');
DECLARE @EtapaId5 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Acabamento');
DECLARE @EtapaId6 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Finalização');

-- =====================================================
-- TAREFAS WITH COMPREHENSIVE STATUS DISTRIBUTION
-- =====================================================

-- Etapa 1 - Preparação (COMPLETED)
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, QuantidadePlanejada, StatusId, Ordem, UnidadeMedida) VALUES
(@EtapaId1, 'Limpeza do Terreno', '2024-01-15', '2024-01-20', '2024-01-20', 500.0, 500.0, 3, 1, 'm²'),
(@EtapaId1, 'Marcação da Obra', '2024-01-21', '2024-01-25', '2024-01-25', 100.0, 100.0, 3, 2, 'm'),
(@EtapaId1, 'Escavação', '2024-01-26', '2024-02-15', '2024-02-10', 85.0, 100.0, 3, 3, 'm³');

-- Etapa 2 - Fundação (COMPLETED)
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, QuantidadePlanejada, StatusId, Ordem, UnidadeMedida) VALUES
(@EtapaId2, 'Armação da Fundação', '2024-02-16', '2024-02-28', '2024-02-28', 200.0, 200.0, 3, 1, 'm²'),
(@EtapaId2, 'Concretagem da Fundação', '2024-03-01', '2024-03-15', '2024-03-15', 150.0, 150.0, 3, 2, 'm³'),
(@EtapaId2, 'Cura do Concreto', '2024-03-16', '2024-03-31', '2024-03-25', 150.0, 150.0, 3, 3, 'm³');

-- Etapa 3 - Estrutura (IN PROGRESS - Mixed Status)
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, QuantidadePlanejada, StatusId, Ordem, UnidadeMedida) VALUES
(@EtapaId3, 'Pilares', '2024-04-01', '2024-04-30', '2024-04-25', 90.0, 100.0, 2, 1, 'unid'),
(@EtapaId3, 'Vigas', '2024-05-01', '2024-05-31', '2024-05-20', 60.0, 100.0, 2, 2, 'unid'),
(@EtapaId3, 'Lajes', '2024-06-01', '2024-06-30', NULL, 0.0, 100.0, 1, 3, 'm²'),
(@EtapaId3, 'Escadas', '2024-06-15', '2024-06-30', NULL, 0.0, 50.0, 1, 4, 'unid');

-- Etapa 4 - Cobertura (PLANNED)
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, QuantidadePlanejada, StatusId, Ordem, UnidadeMedida) VALUES
(@EtapaId4, 'Estrutura do Telhado', '2024-07-01', '2024-07-20', NULL, 0.0, 300.0, 1, 1, 'm²'),
(@EtapaId4, 'Telhas', '2024-07-21', '2024-08-10', NULL, 0.0, 400.0, 1, 2, 'm²'),
(@EtapaId4, 'Calhas e Rufos', '2024-08-11', '2024-08-31', NULL, 0.0, 100.0, 1, 3, 'm');

-- Etapa 5 - Acabamento (PLANNED)
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, QuantidadePlanejada, StatusId, Ordem, UnidadeMedida) VALUES
(@EtapaId5, 'Reboco Interno', '2024-09-01', '2024-09-30', NULL, 0.0, 800.0, 1, 1, 'm²'),
(@EtapaId5, 'Pintura', '2024-10-01', '2024-10-31', NULL, 0.0, 1000.0, 1, 2, 'm²'),
(@EtapaId5, 'Pisos', '2024-11-01', '2024-11-30', NULL, 0.0, 500.0, 1, 3, 'm²'),
(@EtapaId5, 'Portas e Janelas', '2024-11-15', '2024-11-30', NULL, 0.0, 25.0, 1, 4, 'unid');

-- Etapa 6 - Finalização (PLANNED)
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, QuantidadePlanejada, StatusId, Ordem, UnidadeMedida) VALUES
(@EtapaId6, 'Limpeza Final', '2024-12-01', '2024-12-15', NULL, 0.0, 100.0, 1, 1, '%'),
(@EtapaId6, 'Entrega da Obra', '2024-12-16', '2024-12-31', NULL, 0.0, 100.0, 1, 2, '%');

-- =====================================================
-- HISTORICAL MEDICOES (Rich data for Group By testing)
-- =====================================================

DECLARE @TarefaId int;

-- Medicoes for Etapa 1 (Completed tasks with multiple measurements)
SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId1 AND Descricao = 'Limpeza do Terreno';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-01-16', 100.0, 100.0, 'Início da limpeza - área norte', 'PROGRESSO'),
(@TarefaId, '2024-01-17', 150.0, 250.0, 'Continuação - área central', 'PROGRESSO'),
(@TarefaId, '2024-01-18', 125.0, 375.0, 'Área sul iniciada', 'PROGRESSO'),
(@TarefaId, '2024-01-19', 75.0, 450.0, 'Quase finalizada', 'PROGRESSO'),
(@TarefaId, '2024-01-20', 50.0, 500.0, 'Limpeza concluída', 'FINAL');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId1 AND Descricao = 'Marcação da Obra';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-01-22', 40.0, 40.0, 'Marcação perímetro', 'PROGRESSO'),
(@TarefaId, '2024-01-23', 35.0, 75.0, 'Marcação interna', 'PROGRESSO'),
(@TarefaId, '2024-01-25', 25.0, 100.0, 'Marcação finalizada', 'FINAL');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId1 AND Descricao = 'Escavação';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-01-28', 15.0, 15.0, 'Início escavação', 'PROGRESSO'),
(@TarefaId, '2024-02-01', 20.0, 35.0, 'Progresso escavação', 'PROGRESSO'),
(@TarefaId, '2024-02-05', 25.0, 60.0, 'Escavação avançada', 'PROGRESSO'),
(@TarefaId, '2024-02-10', 25.0, 85.0, 'Escavação quase completa', 'PROGRESSO');

-- Medicoes for Etapa 2 (Completed with detailed progress)
SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId2 AND Descricao = 'Armação da Fundação';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-02-18', 50.0, 50.0, 'Armação setor A', 'PROGRESSO'),
(@TarefaId, '2024-02-22', 75.0, 125.0, 'Armação setor B', 'PROGRESSO'),
(@TarefaId, '2024-02-26', 50.0, 175.0, 'Armação setor C', 'PROGRESSO'),
(@TarefaId, '2024-02-28', 25.0, 200.0, 'Armação concluída', 'FINAL');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId2 AND Descricao = 'Concretagem da Fundação';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-03-03', 50.0, 50.0, 'Primeira concretagem', 'PROGRESSO'),
(@TarefaId, '2024-03-08', 60.0, 110.0, 'Segunda concretagem', 'PROGRESSO'),
(@TarefaId, '2024-03-15', 40.0, 150.0, 'Concretagem finalizada', 'FINAL');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId2 AND Descricao = 'Cura do Concreto';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-03-18', 30.0, 30.0, 'Início cura - setor A', 'PROGRESSO'),
(@TarefaId, '2024-03-22', 60.0, 90.0, 'Cura setor B e C', 'PROGRESSO'),
(@TarefaId, '2024-03-25', 60.0, 150.0, 'Cura completa', 'FINAL');

-- Medicoes for Etapa 3 (In Progress - Current work)
SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId3 AND Descricao = 'Pilares';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-04-05', 20.0, 20.0, 'Primeiros pilares', 'PROGRESSO'),
(@TarefaId, '2024-04-12', 30.0, 50.0, 'Pilares centrais', 'PROGRESSO'),
(@TarefaId, '2024-04-20', 25.0, 75.0, 'Pilares laterais', 'PROGRESSO'),
(@TarefaId, '2024-04-25', 15.0, 90.0, 'Pilares quase prontos', 'PROGRESSO');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId3 AND Descricao = 'Vigas';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, QuantidadeAcumulada, Observacoes, TipoMedicao) VALUES
(@TarefaId, '2024-05-05', 15.0, 15.0, 'Vigas principais', 'PROGRESSO'),
(@TarefaId, '2024-05-12', 25.0, 40.0, 'Vigas secundárias', 'PROGRESSO'),
(@TarefaId, '2024-05-20', 20.0, 60.0, 'Vigas em andamento', 'PROGRESSO');

-- =====================================================
-- ADDITIONAL TEST DATA FOR GROUP BY SCENARIOS
-- =====================================================

-- Add more obras for comprehensive Group By testing
INSERT INTO Obras (Descricao, DataInicio, DataPrevisaoFim, CidadeEstado, StatusBasicaGratuita, ContratanteContratada, Ativo) VALUES
('POSTO DE SAÚDE TESTE', '2024-02-01', '2024-10-31', 'Rio de Janeiro/RJ', 'BÁSICA', 'contratante', 1),
('CRECHE MUNICIPAL TESTE', '2024-03-01', '2024-11-30', 'Belo Horizonte/MG', 'GRATUITA', 'contratada', 1);

-- Add etapas for additional obras (for Group By across multiple obras)
DECLARE @ObraId2 int = (SELECT Id FROM Obras WHERE Descricao = 'POSTO DE SAÚDE TESTE');
DECLARE @ObraId3 int = (SELECT Id FROM Obras WHERE Descricao = 'CRECHE MUNICIPAL TESTE');

INSERT INTO Etapas (ObraId, Descricao, Ordem, Ativo) VALUES
(@ObraId2, 'Preparação', 1, 1),
(@ObraId2, 'Fundação', 2, 1),
(@ObraId3, 'Preparação', 1, 1),
(@ObraId3, 'Estrutura', 2, 1);

-- =====================================================
-- VERIFICATION QUERIES FOR GROUP BY TESTING
-- =====================================================

PRINT '=== LOCAL DATABASE MIGRATION COMPLETED ===';
PRINT 'Database: RdoAppLocal';
PRINT 'Tables: Obras, Etapas, Tarefas, StatusTarefa, Medicoes, Usuarios';
PRINT '';
PRINT '=== DATA SUMMARY ===';

SELECT 'Obras' as Tabela, COUNT(*) as Total FROM Obras
UNION ALL
SELECT 'Etapas', COUNT(*) FROM Etapas
UNION ALL
SELECT 'Tarefas', COUNT(*) FROM Tarefas
UNION ALL
SELECT 'Medicoes', COUNT(*) FROM Medicoes
UNION ALL
SELECT 'StatusTarefa', COUNT(*) FROM StatusTarefa
UNION ALL
SELECT 'Usuarios', COUNT(*) FROM Usuarios;

PRINT '';
PRINT '=== GROUP BY TEST QUERIES ===';
PRINT 'Use these queries to test your Group By logic:';
PRINT '';
PRINT '-- 1. Tarefas por Status:';
PRINT 'SELECT s.Descricao, COUNT(*) as Total FROM Tarefas t INNER JOIN StatusTarefa s ON t.StatusId = s.Id GROUP BY s.Descricao;';
PRINT '';
PRINT '-- 2. Medicoes por Tarefa (Obra 233):';
PRINT 'SELECT t.Descricao, COUNT(m.Id) as TotalMedicoes FROM Tarefas t LEFT JOIN Medicoes m ON t.Id = m.TarefaId WHERE t.EtapaId IN (SELECT Id FROM Etapas WHERE ObraId = 233) GROUP BY t.Descricao;';
PRINT '';
PRINT '-- 3. Progresso por Etapa:';
PRINT 'SELECT e.Descricao, AVG(t.PercentualConcluido) as MediaProgresso FROM Etapas e INNER JOIN Tarefas t ON e.Id = t.EtapaId WHERE e.ObraId = 233 GROUP BY e.Descricao;';

GO