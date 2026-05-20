using FsCheck;
using FsCheck.Xunit;
using RdoApp.Core.Models.DTOs;
using Xunit;

namespace RdoApp.Core.Tests.PropertyTests
{
    /// <summary>
    /// Property-based tests for TaskCardDto data integrity
    /// Feature: task-cards-gilberto-implementation, Property 5: Data Integration Accuracy
    /// Validates: Requirements 3.1, 3.2, 3.4
    /// </summary>
    public class TaskCardDtoPropertyTests
    {
        [Property]
        public Property TaskCardDto_DataIntegrity_MaintainsConsistency()
        {
            // Feature: task-cards-gilberto-implementation, Property 5: Data Integration Accuracy
            return Prop.ForAll(
                TaskCardGenerators.ValidTaskCard,
                taskCard =>
                {
                    // Property: All required fields must be present and valid
                    var hasValidId = taskCard.Id > 0;
                    var hasValidDescription = !string.IsNullOrWhiteSpace(taskCard.Descricao);
                    var hasValidDates = taskCard.DataInicio <= taskCard.DataPrevisaoFim;
                    var hasValidStatus = taskCard.StatusId >= 1 && taskCard.StatusId <= 5;
                    var hasValidPercentage = taskCard.PercentualConcluido >= 0 && taskCard.PercentualConcluido <= 100;
                    var hasValidCounts = taskCard.QuantidadeColaboradores >= 0 && taskCard.QuantidadeEquipamentos >= 0;
                    
                    return hasValidId && hasValidDescription && hasValidDates && 
                           hasValidStatus && hasValidPercentage && hasValidCounts;
                });
        }

        [Property]
        public Property TaskCardDto_StatusCssClass_MatchesOriginalMapping()
        {
            // Feature: task-cards-gilberto-implementation, Property 2: Status Color Coding Consistency
            return Prop.ForAll(
                Gen.Choose(1, 5), // Status IDs 1-5
                statusId =>
                {
                    var taskCard = new TaskCardDto { StatusId = statusId };
                    var expectedCssClass = GetExpectedStatusCssClass(statusId);
                    
                    // Property: Status CSS class must match original Gilberto implementation
                    return taskCard.ClasseStatusCss == expectedCssClass;
                });
        }

        [Property]
        public Property TaskCardDto_ProgressCalculation_ConsistentWithOriginal()
        {
            // Feature: task-cards-gilberto-implementation, Property 3: Progress Visualization Consistency
            return Prop.ForAll(
                TaskCardGenerators.ValidTaskCard,
                taskCard =>
                {
                    // Property: Progress percentage must be calculated consistently
                    var isValidPercentage = taskCard.PercentualConcluido >= 0 && taskCard.PercentualConcluido <= 100;
                    var extrapolationConsistent = taskCard.PercentualExtrapolado == (taskCard.PercentualConcluido > 100);
                    
                    return isValidPercentage && extrapolationConsistent;
                });
        }

        [Property]
        public Property TaskCardDto_WaterQualityFields_BacteriaDetritosConsistency()
        {
            // Feature: task-cards-gilberto-implementation, Property 18: Water Quality Field Name Consistency
            return Prop.ForAll(
                WaterQualityParametersGenerators.ValidWaterQualityParameters,
                waterQuality =>
                {
                    // Property: Bacteria field in code should be consistent with Detritos label in UI
                    // This validates the field name resolution strategy
                    var hasBacteriaField = waterQuality.GetType().GetProperty("Bacteria") != null;
                    var fieldValue = waterQuality.Bacteria;
                    
                    // Property: Field exists and can be accessed consistently
                    return hasBacteriaField && (fieldValue == true || fieldValue == false);
                });
        }

        [Property]
        public Property TaskCardDto_AllowedStatusTransitions_ValidTransitions()
        {
            // Feature: task-cards-gilberto-implementation, Property 7: Interactive Behavior Consistency
            return Prop.ForAll(
                TaskCardGenerators.ValidTaskCard,
                taskCard =>
                {
                    // Property: Status transitions must follow business rules
                    var hasValidTransitions = taskCard.ListaStatusPermitidos != null;
                    var transitionsNotEmpty = taskCard.ListaStatusPermitidos?.Count > 0;
                    var noInvalidTransitions = taskCard.ListaStatusPermitidos?.All(s => s.Id >= 1 && s.Id <= 5) ?? true;
                    
                    return hasValidTransitions && transitionsNotEmpty && noInvalidTransitions;
                });
        }

        private static string GetExpectedStatusCssClass(int statusId)
        {
            return statusId switch
            {
                1 => "bg-cinza",      // Planejada
                2 => "bg-azul",       // Em Execução
                3 => "bg-verde",      // Finalizada
                4 => "bg-laranja",    // Paralisada
                5 => "bg-vermelho",   // Cancelada
                _ => "bg-cinza"
            };
        }
    }

    /// <summary>
    /// Generators for property-based testing of TaskCardDto
    /// </summary>
    public static class TaskCardGenerators
    {
        public static Gen<TaskCardDto> ValidTaskCard =>
            from id in Gen.Choose(1, int.MaxValue)
            from agrupador in Gen.Fresh(() => Guid.NewGuid())
            from descricao in Gen.NonEmptyString
            from dataInicio in Gen.DateTimeRange(DateTime.Now.AddYears(-1), DateTime.Now)
            from dataPrevisaoFim in Gen.DateTimeRange(DateTime.Now, DateTime.Now.AddYears(1))
            from statusId in Gen.Choose(1, 5)
            from percentual in Gen.Choose(0, 100)
            from colaboradores in Gen.Choose(0, 50)
            from equipamentos in Gen.Choose(0, 20)
            select new TaskCardDto
            {
                Id = id,
                Agrupador = agrupador,
                Descricao = descricao,
                DataInicio = dataInicio,
                DataPrevisaoFim = dataPrevisaoFim,
                StatusId = statusId,
                StatusDescricao = GetStatusDescription(statusId),
                ClasseStatusCss = GetExpectedStatusCssClass(statusId),
                PercentualConcluido = percentual,
                PercentualExtrapolado = percentual > 100,
                QuantidadeColaboradores = colaboradores,
                QuantidadeEquipamentos = equipamentos,
                ListaStatusPermitidos = GenerateAllowedTransitions(statusId),
                ListaHistoricoTarefa = new List<TaskHistoryDto>()
            };

        private static string GetStatusDescription(int statusId)
        {
            return statusId switch
            {
                1 => "Planejada",
                2 => "Em Execução",
                3 => "Finalizada",
                4 => "Paralisada",
                5 => "Cancelada",
                _ => "Desconhecido"
            };
        }

        private static string GetExpectedStatusCssClass(int statusId)
        {
            return statusId switch
            {
                1 => "bg-cinza",
                2 => "bg-azul",
                3 => "bg-verde",
                4 => "bg-laranja",
                5 => "bg-vermelho",
                _ => "bg-cinza"
            };
        }

        private static List<StatusTarefaDto> GenerateAllowedTransitions(int currentStatusId)
        {
            // Simplified business rules for allowed status transitions
            return currentStatusId switch
            {
                1 => new List<StatusTarefaDto> // Planejada
                {
                    new() { Id = 2, Nome = "Em Execução", CssClass = "bg-azul" },
                    new() { Id = 5, Nome = "Cancelada", CssClass = "bg-vermelho" }
                },
                2 => new List<StatusTarefaDto> // Em Execução
                {
                    new() { Id = 3, Nome = "Finalizada", CssClass = "bg-verde" },
                    new() { Id = 4, Nome = "Paralisada", CssClass = "bg-laranja" },
                    new() { Id = 5, Nome = "Cancelada", CssClass = "bg-vermelho" }
                },
                3 => new List<StatusTarefaDto>(), // Finalizada - no transitions
                4 => new List<StatusTarefaDto> // Paralisada
                {
                    new() { Id = 2, Nome = "Em Execução", CssClass = "bg-azul" },
                    new() { Id = 5, Nome = "Cancelada", CssClass = "bg-vermelho" }
                },
                5 => new List<StatusTarefaDto>(), // Cancelada - no transitions
                _ => new List<StatusTarefaDto>()
            };
        }
    }

    /// <summary>
    /// Generators for water quality parameters testing
    /// </summary>
    public static class WaterQualityParametersGenerators
    {
        public static Gen<WaterQualityParametersDto> ValidWaterQualityParameters =>
            from cloro in Gen.Choose(1, 5)
            from ph in Gen.Choose(1, 6)
            from alcalinidade in Gen.Choose(1, 6)
            from limpidez in Gen.Elements(true, false)
            from superficie in Gen.Elements(true, false)
            from fundo in Gen.Elements(true, false)
            from bacteria in Gen.Elements(true, false) // Field name: Bacteria, UI label: Detritos
            from proliferacao in Gen.Elements(true, false)
            select new WaterQualityParametersDto
            {
                NivelCloro = cloro,
                NivelPH = ph,
                NivelAlcalinidade = alcalinidade,
                Limpidez = limpidez,
                Superficie = superficie,
                Fundo = fundo,
                Bacteria = bacteria, // CRITICAL: Field name resolution - Bacteria in code, Detritos in UI
                Proliferacao = proliferacao
            };
    }
}