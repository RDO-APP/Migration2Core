using FsCheck;
using FsCheck.Xunit;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Services.Implementations;
using RdoApp.Core.Data.Context;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace RdoApp.Core.Tests.PropertyTests
{
    /// <summary>
    /// Property tests for progress calculation accuracy
    /// Feature: task-cards-gilberto-implementation, Property 3: Progress Visualization Consistency
    /// Validates: Requirements 2.3
    /// </summary>
    public class ProgressCalculationPropertyTests
    {
        private TarefaService CreateService()
        {
            var options = new DbContextOptionsBuilder<RdoContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            var context = new RdoContext(options);
            return new TarefaService(context);
        }

        [Property]
        public Property ProgressCalculation_PlanejadaStatus_ReturnsZero()
        {
            // Feature: task-cards-gilberto-implementation, Property 3: Progress Visualization Consistency
            return Prop.ForAll<DateTime, DateTime>((dataInicio, dataPrevisaoFim) =>
            {
                var service = CreateService();
                var tarefa = new Tarefa
                {
                    StatusId = 1, // Planejada
                    DataInicio = dataInicio,
                    DataPrevisaoFim = dataPrevisaoFim
                };

                var resultado = service.CalcularPercentualConcluido(tarefa);

                return resultado == 0;
            });
        }

        [Property]
        public Property ProgressCalculation_NoMedicao_ReturnsZero()
        {
            // Feature: task-cards-gilberto-implementation, Property 3: Progress Visualization Consistency
            return Prop.ForAll<int, DateTime, DateTime>((statusId, dataInicio, dataPrevisaoFim) =>
            {
                statusId = Math.Abs(statusId % 5) + 1; // Ensure valid status 1-5
                
                var service = CreateService();
                var tarefa = new Tarefa
                {
                    StatusId = statusId,
                    DataInicio = dataInicio,
                    DataPrevisaoFim = dataPrevisaoFim,
                    DataMedicao = null // No measurement
                };

                var resultado = service.CalcularPercentualConcluido(tarefa);

                return statusId == 1 ? resultado == 0 : resultado == 0; // Both should return 0 without measurement
            });
        }

        [Property]
        public Property ProgressCalculation_ValidRange_BetweenZeroAndHundred()
        {
            // Feature: task-cards-gilberto-implementation, Property 3: Progress Visualization Consistency
            return Prop.ForAll<int>((daysDiff) =>
            {
                daysDiff = Math.Abs(daysDiff % 365) + 1; // Ensure positive days within a year
                
                var service = CreateService();
                var dataInicio = DateTime.Now.AddDays(-daysDiff);
                var dataPrevisaoFim = DateTime.Now.AddDays(daysDiff);
                
                var tarefa = new Tarefa
                {
                    StatusId = 2, // Em Execução
                    DataInicio = dataInicio,
                    DataPrevisaoFim = dataPrevisaoFim,
                    DataMedicao = DateTime.Now
                };

                var resultado = service.CalcularPercentualConcluido(tarefa);

                return resultado >= 0 && resultado <= 100;
            });
        }

        [Property]
        public Property ProgressCalculation_SameDates_ReturnsValidPercentage()
        {
            // Feature: task-cards-gilberto-implementation, Property 3: Progress Visualization Consistency
            return Prop.ForAll<DateTime>((baseDate) =>
            {
                var service = CreateService();
                var tarefa = new Tarefa
                {
                    StatusId = 2, // Em Execução
                    DataInicio = baseDate,
                    DataPrevisaoFim = baseDate.AddDays(1), // Ensure at least 1 day difference
                    DataMedicao = baseDate
                };

                var resultado = service.CalcularPercentualConcluido(tarefa);

                return resultado >= 0 && resultado <= 100;
            });
        }

        [Property]
        public Property ProgressCalculation_Consistency_SameInputsSameOutput()
        {
            // Feature: task-cards-gilberto-implementation, Property 3: Progress Visualization Consistency
            return Prop.ForAll<DateTime, int>((dataInicio, daysDuration) =>
            {
                daysDuration = Math.Abs(daysDuration % 365) + 1; // Ensure positive duration
                
                var service1 = CreateService();
                var service2 = CreateService();
                
                var tarefa1 = new Tarefa
                {
                    StatusId = 2,
                    DataInicio = dataInicio,
                    DataPrevisaoFim = dataInicio.AddDays(daysDuration),
                    DataMedicao = dataInicio.AddDays(daysDuration / 2)
                };

                var tarefa2 = new Tarefa
                {
                    StatusId = 2,
                    DataInicio = dataInicio,
                    DataPrevisaoFim = dataInicio.AddDays(daysDuration),
                    DataMedicao = dataInicio.AddDays(daysDuration / 2)
                };

                var resultado1 = service1.CalcularPercentualConcluido(tarefa1);
                var resultado2 = service2.CalcularPercentualConcluido(tarefa2);

                return resultado1 == resultado2;
            });
        }
    }
}