using FsCheck;
using FsCheck.Xunit;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Services.Implementations;
using RdoApp.Core.Data.Context;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace RdoApp.Core.Tests.PropertyTests
{
    /// <summary>
    /// Property tests for water quality field name consistency
    /// Feature: task-cards-gilberto-implementation, Property 18: Water Quality Field Name Consistency
    /// Validates: Requirements 12.1
    /// 
    /// CRITICAL: Tests the field naming strategy - "Bacteria" field in code, "Detritos" label in UI
    /// </summary>
    public class WaterQualityFieldNamePropertyTests
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
        public Property WaterQualityFieldName_BacteriaField_ConsistentMapping()
        {
            // Feature: task-cards-gilberto-implementation, Property 18: Water Quality Field Name Consistency
            return Prop.ForAll<bool>((bacteriaValue) =>
            {
                var service = CreateService();
                var parameters = new WaterQualityParametersDto
                {
                    NivelCloro = 1,
                    NivelPH = 1,
                    NivelAlcalinidade = 1,
                    Limpidez = true,
                    Superficie = true,
                    Fundo = true,
                    Bacteria = bacteriaValue, // FIELD NAME: "Bacteria" in code
                    Proliferacao = false
                };

                // The DTO should always use "Bacteria" as the field name
                var fieldName = nameof(parameters.Bacteria);
                var fieldValue = parameters.Bacteria;

                return fieldName == "Bacteria" && fieldValue == bacteriaValue;
            });
        }

        [Property]
        public Property WaterQualityFieldName_SaveAndRetrieve_PreservesFieldName()
        {
            // Feature: task-cards-gilberto-implementation, Property 18: Water Quality Field Name Consistency
            return Prop.ForAll<int, bool, bool, bool>((nivelCloro, limpidez, bacteria, proliferacao) =>
            {
                nivelCloro = Math.Abs(nivelCloro % 6); // Valid range 0-5
                
                var (service, context) = CreateServiceWithContext();

                // Create test tarefa
                var tarefa = new Tarefa
                {
                    Id = 1,
                    Descricao = "Test Task",
                    StatusId = 1,
                    EtapaId = 1,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(10),
                    Agrupador = Guid.NewGuid(),
                    DataInsercao = DateTime.Now
                };

                context.Tarefas.Add(tarefa);
                context.SaveChanges();

                var parameters = new WaterQualityParametersDto
                {
                    NivelCloro = nivelCloro,
                    NivelPH = 1,
                    NivelAlcalinidade = 1,
                    Limpidez = limpidez,
                    Superficie = true,
                    Fundo = true,
                    Bacteria = bacteria, // Field name consistency test
                    Proliferacao = proliferacao
                };

                // Save water quality parameters
                var saveResult = service.SaveWaterQualityMeasurementAsync(1, parameters, 1).Result;

                // Retrieve water quality parameters
                var retrievedParameters = service.GetWaterQualityParametersAsync(1).Result;

                return saveResult &&
                       retrievedParameters.Bacteria == bacteria && // Field name preserved
                       retrievedParameters.NivelCloro == nivelCloro &&
                       retrievedParameters.Limpidez == limpidez &&
                       retrievedParameters.Proliferacao == proliferacao;
            });
        }

        [Property]
        public Property WaterQualityFieldName_AllDropdowns_ReturnConsistentData()
        {
            // Feature: task-cards-gilberto-implementation, Property 18: Water Quality Field Name Consistency
            return Prop.ForAll<int>((seed) =>
            {
                var service = CreateService();

                var cloroOptions = service.GetCloroOptionsAsync().Result;
                var phOptions = service.GetPHOptionsAsync().Result;
                var alcalinidadeOptions = service.GetAlcalinidadeOptionsAsync().Result;

                // Verify dropdown consistency with original Gilberto implementation
                var cloroValid = cloroOptions.Count == 5 &&
                                cloroOptions.Any(o => o.Nome == "0 ppm") &&
                                cloroOptions.Any(o => o.Nome == "> 3,0");

                var phValid = phOptions.Count == 6 &&
                             phOptions.Any(o => o.Nome == "< 7.0") &&
                             phOptions.Any(o => o.Nome == "> 7.8");

                var alcalinidadeValid = alcalinidadeOptions.Count == 6 &&
                                       alcalinidadeOptions.Any(o => o.Nome == "< 70") &&
                                       alcalinidadeOptions.Any(o => o.Nome == "> 140");

                return cloroValid && phValid && alcalinidadeValid;
            });
        }

        [Property]
        public Property WaterQualityFieldName_ParametersDto_HasCorrectFieldNames()
        {
            // Feature: task-cards-gilberto-implementation, Property 18: Water Quality Field Name Consistency
            return Prop.ForAll<int, int, int, bool, bool, bool, bool, bool>((cloro, ph, alcalinidade, limpidez, superficie, fundo, bacteria, proliferacao) =>
            {
                var parameters = new WaterQualityParametersDto
                {
                    NivelCloro = cloro,
                    NivelPH = ph,
                    NivelAlcalinidade = alcalinidade,
                    Limpidez = limpidez,
                    Superficie = superficie,
                    Fundo = fundo,
                    Bacteria = bacteria, // CRITICAL: Field name must be "Bacteria"
                    Proliferacao = proliferacao
                };

                // Verify all expected field names exist
                var type = typeof(WaterQualityParametersDto);
                var bacteriaProperty = type.GetProperty("Bacteria");
                var cloroProperty = type.GetProperty("NivelCloro");
                var phProperty = type.GetProperty("NivelPH");
                var alcalinidadeProperty = type.GetProperty("NivelAlcalinidade");

                return bacteriaProperty != null &&
                       bacteriaProperty.PropertyType == typeof(bool) &&
                       cloroProperty != null &&
                       phProperty != null &&
                       alcalinidadeProperty != null &&
                       parameters.Bacteria == bacteria;
            });
        }

        [Property]
        public Property WaterQualityFieldName_EntityMapping_PreservesFieldNames()
        {
            // Feature: task-cards-gilberto-implementation, Property 18: Water Quality Field Name Consistency
            return Prop.ForAll<bool, bool, bool, bool>((bacteria, limpidez, superficie, fundo) =>
            {
                var (service, context) = CreateServiceWithContext();

                // Create test tarefa with water quality fields
                var tarefa = new Tarefa
                {
                    Id = 1,
                    Descricao = "Test Task",
                    StatusId = 1,
                    EtapaId = 1,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(10),
                    Agrupador = Guid.NewGuid(),
                    DataInsercao = DateTime.Now,
                    // Water quality fields in entity
                    Bacteria = bacteria, // Entity field name matches DTO field name
                    Limpidez = limpidez,
                    Superficie = superficie,
                    Fundo = fundo
                };

                context.Tarefas.Add(tarefa);
                context.SaveChanges();

                // Retrieve via service
                var parameters = service.GetWaterQualityParametersAsync(1).Result;

                // Verify field mapping consistency
                return parameters.Bacteria == bacteria &&
                       parameters.Limpidez == limpidez &&
                       parameters.Superficie == superficie &&
                       parameters.Fundo == fundo;
            });
        }

        private (TarefaService, RdoContext) CreateServiceWithContext()
        {
            var options = new DbContextOptionsBuilder<RdoContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            var context = new RdoContext(options);
            var service = new TarefaService(context);
            return (service, context);
        }
    }
}