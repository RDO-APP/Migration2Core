-- LOCAL DATABASE SETUP FOR RDO APP
-- This script creates the essential tables for local development
-- Focus on etapa, tarefa, medicao tables with Obra 233 data

USE master;
GO

-- Create database if it doesn't exist
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RdoAppLocal')
BEGIN
    CREATE DATABASE RdoAppLocal;
END
GO

USE RdoAppLocal;
GO

-- Create Obra table (minimal structure for Obra 233)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Obras' AND xtype='U')
BEGIN
    CREATE TABLE Obras (
        Id int IDENTITY(1,1) PRIMARY KEY,
        Descricao nvarchar(500) NOT NULL,
        DataInicio datetime2 NOT NULL DEFAULT GETDATE(),
        DataPrevisaoFim datetime2 NULL,
        DataFim datetime2 NULL,
        CidadeEstado nvarchar(200) NULL,
        StatusBasicaGratuita nvarchar(100) NULL DEFAULT 'BÁSICA',
        ContratanteContratada nvarchar(50) NULL DEFAULT 'contratada',
        CreatedAt datetime2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt datetime2 NOT NULL DEFAULT GETDATE()
    );
END
GO

-- Create Etapa table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Etapas' AND xtype='U')
BEGIN
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
        FOREIGN KEY (ObraId) REFERENCES Obras(Id)
    );
END
GO

-- Create StatusTarefa table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='StatusTarefa' AND xtype='U')
BEGIN
    CREATE TABLE StatusTarefa (
        Id int IDENTITY(1,1) PRIMARY KEY,
        Descricao nvarchar(100) NOT NULL,
        Ativo bit NOT NULL DEFAULT 1
    );
END
GO

-- Create Tarefa table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Tarefas' AND xtype='U')
BEGIN
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
        CreatedAt datetime2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt datetime2 NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (EtapaId) REFERENCES Etapas(Id),
        FOREIGN KEY (StatusId) REFERENCES StatusTarefa(Id)
    );
END
GO

-- Create Medicao table
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Medicoes' AND xtype='U')
BEGIN
    CREATE TABLE Medicoes (
        Id int IDENTITY(1,1) PRIMARY KEY,
        TarefaId int NOT NULL,
        DataMedicao datetime2 NOT NULL DEFAULT GETDATE(),
        QuantidadeMedida float NOT NULL DEFAULT 0,
        Observacoes nvarchar(1000) NULL,
        UsuarioId int NULL,
        Ativo bit NOT NULL DEFAULT 1,
        CreatedAt datetime2 NOT NULL DEFAULT GETDATE(),
        UpdatedAt datetime2 NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (TarefaId) REFERENCES Tarefas(Id)
    );
END
GO

-- Insert StatusTarefa data
INSERT INTO StatusTarefa (Descricao, Ativo) VALUES
('Planejada', 1),
('Em Andamento', 1),
('Concluída', 1),
('Pausada', 1),
('Cancelada', 0);
GO

-- Insert Obra 233 (test obra)
SET IDENTITY_INSERT Obras ON;
INSERT INTO Obras (Id, Descricao, DataInicio, DataPrevisaoFim, CidadeEstado, StatusBasicaGratuita, ContratanteContratada) VALUES
(233, 'ESCOLA MUNICIPAL TESTE LOCAL', '2024-01-15', '2024-12-31', 'São Paulo/SP', 'BÁSICA', 'contratada');
SET IDENTITY_INSERT Obras OFF;
GO

-- Insert Etapas for Obra 233
INSERT INTO Etapas (ObraId, Descricao, Ordem, DataInicio, DataPrevisaoFim) VALUES
(233, 'Preparação do Terreno', 1, '2024-01-15', '2024-02-15'),
(233, 'Fundação', 2, '2024-02-16', '2024-03-31'),
(233, 'Estrutura', 3, '2024-04-01', '2024-06-30'),
(233, 'Cobertura', 4, '2024-07-01', '2024-08-31'),
(233, 'Acabamento', 5, '2024-09-01', '2024-11-30'),
(233, 'Finalização', 6, '2024-12-01', '2024-12-31');
GO

-- Insert Tarefas for each Etapa
DECLARE @EtapaId1 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Preparação do Terreno');
DECLARE @EtapaId2 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Fundação');
DECLARE @EtapaId3 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Estrutura');
DECLARE @EtapaId4 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Cobertura');
DECLARE @EtapaId5 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Acabamento');
DECLARE @EtapaId6 int = (SELECT Id FROM Etapas WHERE ObraId = 233 AND Descricao = 'Finalização');

-- Tarefas Etapa 1 - Preparação
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, StatusId, Ordem) VALUES
(@EtapaId1, 'Limpeza do Terreno', '2024-01-15', '2024-01-20', '2024-01-20', 100.0, 3, 1),
(@EtapaId1, 'Marcação da Obra', '2024-01-21', '2024-01-25', '2024-01-25', 100.0, 3, 2),
(@EtapaId1, 'Escavação', '2024-01-26', '2024-02-15', '2024-02-10', 85.0, 2, 3);

-- Tarefas Etapa 2 - Fundação
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, StatusId, Ordem) VALUES
(@EtapaId2, 'Armação da Fundação', '2024-02-16', '2024-02-28', '2024-02-28', 100.0, 3, 1),
(@EtapaId2, 'Concretagem da Fundação', '2024-03-01', '2024-03-15', '2024-03-15', 100.0, 3, 2),
(@EtapaId2, 'Cura do Concreto', '2024-03-16', '2024-03-31', '2024-03-25', 75.0, 2, 3);

-- Tarefas Etapa 3 - Estrutura
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, StatusId, Ordem) VALUES
(@EtapaId3, 'Pilares', '2024-04-01', '2024-04-30', '2024-04-25', 90.0, 2, 1),
(@EtapaId3, 'Vigas', '2024-05-01', '2024-05-31', '2024-05-20', 60.0, 2, 2),
(@EtapaId3, 'Lajes', '2024-06-01', '2024-06-30', NULL, 0.0, 1, 3);

-- Tarefas Etapa 4 - Cobertura
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, StatusId, Ordem) VALUES
(@EtapaId4, 'Estrutura do Telhado', '2024-07-01', '2024-07-20', NULL, 0.0, 1, 1),
(@EtapaId4, 'Telhas', '2024-07-21', '2024-08-10', NULL, 0.0, 1, 2),
(@EtapaId4, 'Calhas e Rufos', '2024-08-11', '2024-08-31', NULL, 0.0, 1, 3);

-- Tarefas Etapa 5 - Acabamento
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, StatusId, Ordem) VALUES
(@EtapaId5, 'Reboco Interno', '2024-09-01', '2024-09-30', NULL, 0.0, 1, 1),
(@EtapaId5, 'Pintura', '2024-10-01', '2024-10-31', NULL, 0.0, 1, 2),
(@EtapaId5, 'Pisos', '2024-11-01', '2024-11-30', NULL, 0.0, 1, 3);

-- Tarefas Etapa 6 - Finalização
INSERT INTO Tarefas (EtapaId, Descricao, DataInicio, DataPrevisaoFim, DataMedicao, QuantidadeConstruida, StatusId, Ordem) VALUES
(@EtapaId6, 'Limpeza Final', '2024-12-01', '2024-12-15', NULL, 0.0, 1, 1),
(@EtapaId6, 'Entrega da Obra', '2024-12-16', '2024-12-31', NULL, 0.0, 1, 2);

-- Insert historical Medicoes for completed tasks
DECLARE @TarefaId int;

-- Medicoes for completed tasks in Etapa 1
SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId1 AND Descricao = 'Limpeza do Terreno';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-01-18', 50.0, 'Primeira medição - 50% concluído'),
(@TarefaId, '2024-01-20', 100.0, 'Tarefa concluída');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId1 AND Descricao = 'Marcação da Obra';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-01-23', 75.0, 'Marcação quase completa'),
(@TarefaId, '2024-01-25', 100.0, 'Marcação finalizada');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId1 AND Descricao = 'Escavação';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-02-01', 30.0, 'Início da escavação'),
(@TarefaId, '2024-02-05', 60.0, 'Progresso da escavação'),
(@TarefaId, '2024-02-10', 85.0, 'Escavação quase completa');

-- Medicoes for completed tasks in Etapa 2
SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId2 AND Descricao = 'Armação da Fundação';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-02-20', 40.0, 'Início da armação'),
(@TarefaId, '2024-02-25', 80.0, 'Armação avançada'),
(@TarefaId, '2024-02-28', 100.0, 'Armação concluída');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId2 AND Descricao = 'Concretagem da Fundação';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-03-05', 50.0, 'Primeira concretagem'),
(@TarefaId, '2024-03-10', 80.0, 'Segunda concretagem'),
(@TarefaId, '2024-03-15', 100.0, 'Concretagem finalizada');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId2 AND Descricao = 'Cura do Concreto';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-03-20', 25.0, 'Início da cura'),
(@TarefaId, '2024-03-25', 75.0, 'Cura em andamento');

-- Medicoes for tasks in progress in Etapa 3
SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId3 AND Descricao = 'Pilares';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-04-10', 30.0, 'Primeiros pilares'),
(@TarefaId, '2024-04-20', 70.0, 'Maioria dos pilares'),
(@TarefaId, '2024-04-25', 90.0, 'Pilares quase prontos');

SELECT @TarefaId = Id FROM Tarefas WHERE EtapaId = @EtapaId3 AND Descricao = 'Vigas';
INSERT INTO Medicoes (TarefaId, DataMedicao, QuantidadeMedida, Observacoes) VALUES
(@TarefaId, '2024-05-10', 20.0, 'Início das vigas'),
(@TarefaId, '2024-05-20', 60.0, 'Vigas em andamento');

GO

-- Create indexes for better performance
CREATE INDEX IX_Etapas_ObraId ON Etapas(ObraId);
CREATE INDEX IX_Tarefas_EtapaId ON Tarefas(EtapaId);
CREATE INDEX IX_Medicoes_TarefaId ON Medicoes(TarefaId);
CREATE INDEX IX_Medicoes_DataMedicao ON Medicoes(DataMedicao);
GO

PRINT 'Local database structure created successfully!';
PRINT 'Database: RdoAppLocal';
PRINT 'Tables created: Obras, Etapas, Tarefas, StatusTarefa, Medicoes';
PRINT 'Test data inserted for Obra 233 with historical records';
GO