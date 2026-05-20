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
    /// Property tests for Etapa (Stage) management consistency
    /// Feature: task-cards-gilberto-implementation, Property 17: Etapa (Stage) Management Consistency
    /// Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5
    /// </summary>
    public class EtapaManagementPropertyTests
    {
        private (EtapaService, RdoContext) CreateService()
        {
            var options = new DbContextOptionsBuilder<RdoContext>()
                .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
                .Options;
            var context = new RdoContext(options);
            var tarefaService = new TarefaService(context);
            var etapaService = new EtapaService(context, tarefaService);
            return (etapaService, context);
        }

        [Property]
        public Property EtapaManagement_CreateEtapa_ReturnsValidDto()
        {
            // Feature: task-cards-gilberto-implementation, Property 17: Etapa (Stage) Management Consistency
            return Prop.ForAll<string, string, int, int>((titulo, descricao, obraId, userId) =>
            {
                // Ensure valid inputs
                titulo = string.IsNullOrWhiteSpace(titulo) ? "Test Etapa" : titulo.Substring(0, Math.Min(titulo.Length, 200));
                descricao = descricao ?? "";
                obraId = Math.Abs(obraId) + 1;
                userId = Math.Abs(userId) + 1;

                var (service, context) = CreateService();
                var createDto = new CreateEtapaDto
                {
                    Titulo = titulo,
                    Descricao = descricao,
                    ObraId = obraId,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(30)
                };

                var resultado = service.CreateEtapaAsync(createDto, userId).Result;

                return resultado != null &&
                       resultado.Titulo == titulo &&
                       resultado.Descricao == descricao &&
                       resultado.ObraId == obraId &&
                       resultado.Id > 0;
            });
        }

        [Property]
        public Property EtapaManagement_GetEtapasForDropdown_ReturnsOrderedList()
        {
            // Feature: task-cards-gilberto-implementation, Property 17: Etapa (Stage) Management Consistency
            return Prop.ForAll<int>((obraId) =>
            {
                obraId = Math.Abs(obraId) + 1;

                var (service, context) = CreateService();
                
                // Add test data
                var etapas = new[]
                {
                    new Etapa { Id = 1, Titulo = "Z Etapa", ObraId = obraId, DataInicio = DateTime.Now, DataPrevisaoFim = DateTime.Now.AddDays(30), DataInsercao = DateTime.Now },
                    new Etapa { Id = 2, Titulo = "A Etapa", ObraId = obraId, DataInicio = DateTime.Now, DataPrevisaoFim = DateTime.Now.AddDays(30), DataInsercao = DateTime.Now },
                    new Etapa { Id = 3, Titulo = "M Etapa", ObraId = obraId, DataInicio = DateTime.Now, DataPrevisaoFim = DateTime.Now.AddDays(30), DataInsercao = DateTime.Now }
                };

                context.Etapas.AddRange(etapas);
                context.SaveChanges();

                var resultado = service.GetEtapasForDropdownAsync(obraId).Result;

                // Check if results are ordered by Titulo
                var isOrdered = true;
                for (int i = 1; i < resultado.Count; i++)
                {
                    if (string.Compare(resultado[i - 1].Titulo, resultado[i].Titulo, StringComparison.Ordinal) > 0)
                    {
                        isOrdered = false;
                        break;
                    }
                }

                return resultado.Count == 3 && isOrdered;
            });
        }

        [Property]
        public Property EtapaManagement_LoadTaskCardsForEtapa_ReturnsCorrectTasks()
        {
            // Feature: task-cards-gilberto-implementation, Property 17: Etapa (Stage) Management Consistency
            return Prop.ForAll<string, int>((etapaTitulo, obraId) =>
            {
                etapaTitulo = string.IsNullOrWhiteSpace(etapaTitulo) ? "Test Etapa" : etapaTitulo.Substring(0, Math.Min(etapaTitulo.Length, 200));
                obraId = Math.Abs(obraId) + 1;

                var (service, context) = CreateService();

                // Add test etapa
                var etapa = new Etapa
                {
                    Id = 1,
                    Titulo = etapaTitulo,
                    ObraId = obraId,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(30),
                    DataInsercao = DateTime.Now
                };

                context.Etapas.Add(etapa);

                // Add test tasks
                var tarefas = new[]
                {
                    new Tarefa { Id = 1, EtapaId = 1, Descricao = "Task 1", StatusId = 1, DataInicio = DateTime.Now, DataPrevisaoFim = DateTime.Now.AddDays(10), Agrupador = Guid.NewGuid(), DataInsercao = DateTime.Now },
                    new Tarefa { Id = 2, EtapaId = 1, Descricao = "Task 2", StatusId = 2, DataInicio = DateTime.Now, DataPrevisaoFim = DateTime.Now.AddDays(10), Agrupador = Guid.NewGuid(), DataInsercao = DateTime.Now }
                };

                context.Tarefas.AddRange(tarefas);
                context.SaveChanges();

                var resultado = service.LoadTaskCardsForEtapaAsync(etapaTitulo, obraId).Result;

                return resultado.Count == 2 &&
                       resultado.All(t => !string.IsNullOrEmpty(t.Descricao)) &&
                       resultado.All(t => t.Id > 0);
            });
        }

        [Property]
        public Property EtapaManagement_UpdateEtapa_PreservesId()
        {
            // Feature: task-cards-gilberto-implementation, Property 17: Etapa (Stage) Management Consistency
            return Prop.ForAll<string, string, int>((novoTitulo, novaDescricao, userId) =>
            {
                novoTitulo = string.IsNullOrWhiteSpace(novoTitulo) ? "Updated Etapa" : novoTitulo.Substring(0, Math.Min(novoTitulo.Length, 200));
                novaDescricao = novaDescricao ?? "";
                userId = Math.Abs(userId) + 1;

                var (service, context) = CreateService();

                // Add test etapa
                var etapa = new Etapa
                {
                    Id = 1,
                    Titulo = "Original Title",
                    Descricao = "Original Description",
                    ObraId = 1,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(30),
                    StatusId = 1,
                    DataInsercao = DateTime.Now
                };

                context.Etapas.Add(etapa);
                context.SaveChanges();

                var updateDto = new UpdateEtapaDto
                {
                    Titulo = novoTitulo,
                    Descricao = novaDescricao,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(30),
                    StatusId = 1
                };

                var resultado = service.UpdateEtapaAsync(1, updateDto, userId).Result;

                // Verify update was successful
                var updatedEtapa = context.Etapas.Find(1);

                return resultado &&
                       updatedEtapa != null &&
                       updatedEtapa.Id == 1 &&
                       updatedEtapa.Titulo == novoTitulo &&
                       updatedEtapa.Descricao == novaDescricao;
            });
        }

        [Property]
        public Property EtapaManagement_DeleteEtapa_WithoutTasks_Succeeds()
        {
            // Feature: task-cards-gilberto-implementation, Property 17: Etapa (Stage) Management Consistency
            return Prop.ForAll<int>((userId) =>
            {
                userId = Math.Abs(userId) + 1;

                var (service, context) = CreateService();

                // Add test etapa without tasks
                var etapa = new Etapa
                {
                    Id = 1,
                    Titulo = "Test Etapa",
                    ObraId = 1,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(30),
                    DataInsercao = DateTime.Now
                };

                context.Etapas.Add(etapa);
                context.SaveChanges();

                var resultado = service.DeleteEtapaAsync(1, userId).Result;

                // Verify deletion
                var deletedEtapa = context.Etapas.Find(1);

                return resultado && deletedEtapa == null;
            });
        }

        [Property]
        public Property EtapaManagement_DeleteEtapa_WithTasks_Fails()
        {
            // Feature: task-cards-gilberto-implementation, Property 17: Etapa (Stage) Management Consistency
            return Prop.ForAll<int>((userId) =>
            {
                userId = Math.Abs(userId) + 1;

                var (service, context) = CreateService();

                // Add test etapa with tasks
                var etapa = new Etapa
                {
                    Id = 1,
                    Titulo = "Test Etapa",
                    ObraId = 1,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(30),
                    DataInsercao = DateTime.Now
                };

                var tarefa = new Tarefa
                {
                    Id = 1,
                    EtapaId = 1,
                    Descricao = "Test Task",
                    StatusId = 1,
                    DataInicio = DateTime.Now,
                    DataPrevisaoFim = DateTime.Now.AddDays(10),
                    Agrupador = Guid.NewGuid(),
                    DataInsercao = DateTime.Now
                };

                context.Etapas.Add(etapa);
                context.Tarefas.Add(tarefa);
                context.SaveChanges();

                var resultado = service.DeleteEtapaAsync(1, userId).Result;

                // Verify deletion failed and etapa still exists
                var existingEtapa = context.Etapas.Find(1);

                return !resultado && existingEtapa != null;
            });
        }
    }
}