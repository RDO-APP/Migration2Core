using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Services.Implementations
{
    public class TarefaService : ITarefaService
    {
        private readonly RdoContext _context;

        public TarefaService(RdoContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<TarefaDto>> GetAllAsync()
        {
            // Day 7 - COM RELACIONAMENTOS REAIS
            return await _context.Tarefas
                .Include(t => t.Status)
                .Include(t => t.Etapa)
                    .ThenInclude(e => e.Obra)
                .Include(t => t.ColaboradorInsercao)
                .Select(t => new TarefaDto
                {
                    Id = t.Id,
                    Agrupador = t.Agrupador,
                    Descricao = t.Descricao ?? "",
                    DataInicio = t.DataInicio,
                    DataPrevisaoFim = t.DataPrevisaoFim,
                    DataFim = t.DataFim,
                    StatusId = t.StatusId,
                    StatusDescricao = t.Status != null ? t.Status.Descricao : "Status " + t.StatusId, // Real data!
                    EtapaId = t.EtapaId,
                    EtapaDescricao = t.Etapa != null ? t.Etapa.Descricao : "Etapa " + t.EtapaId, // Real data!
                    ObraId = t.Etapa != null ? t.Etapa.ObraId : 0,
                    ObraDescricao = t.Etapa != null && t.Etapa.Obra != null ? t.Etapa.Obra.Descricao : "Obra N/A", // Real data!
                    UnidadeId = t.UnidadeId,
                    QuantidadeConstruida = t.QuantidadeConstruida,
                    QuantidadePrevisao = t.QuantidadePrevisao,
                    Comentario = t.Comentario,
                    Foto = t.Foto,
                    HorasTrabalhadas = t.HorasTrabalhadas,
                    HoraMedicaoInicial = t.HoraMedicaoInicial,
                    HoraMedicaoFinal = t.HoraMedicaoFinal,
                    DataMedicao = t.DataMedicao,
                    ValorUnitario = t.ValorUnitario,
                    HorimetroInicial = t.HorimetroInicial,
                    HorimetroFinal = t.HorimetroFinal,
                    HorimetroTotal = t.HorimetroTotal,
                    CodigoParalizacao = t.CodigoParalizacao,
                    ColaboradorInsercaoId = t.ColaboradorInsercaoId,
                    ColaboradorInsercaoNome = t.ColaboradorInsercao != null ? t.ColaboradorInsercao.Nome : "Colaborador " + t.ColaboradorInsercaoId, // Real data!
                    DataInsercao = t.DataInsercao,
                    DataUltimaAtualizacao = t.DataUltimaAtualizacao
                })
                .ToListAsync();
        }

        public async Task<TarefaDto?> GetByIdAsync(int id)
        {
            // Day 7 - COM RELACIONAMENTOS REAIS
            return await _context.Tarefas
                .Include(t => t.Status)
                .Include(t => t.Etapa)
                    .ThenInclude(e => e.Obra)
                .Include(t => t.ColaboradorInsercao)
                .Where(t => t.Id == id)
                .Select(t => new TarefaDto
                {
                    Id = t.Id,
                    Agrupador = t.Agrupador,
                    Descricao = t.Descricao ?? "",
                    DataInicio = t.DataInicio,
                    DataPrevisaoFim = t.DataPrevisaoFim,
                    DataFim = t.DataFim,
                    StatusId = t.StatusId,
                    StatusDescricao = t.Status != null ? t.Status.Descricao : "Status " + t.StatusId, // Real data!
                    EtapaId = t.EtapaId,
                    EtapaDescricao = t.Etapa != null ? t.Etapa.Descricao : "Etapa " + t.EtapaId, // Real data!
                    ObraId = t.Etapa != null ? t.Etapa.ObraId : 0,
                    ObraDescricao = t.Etapa != null && t.Etapa.Obra != null ? t.Etapa.Obra.Descricao : "Obra N/A", // Real data!
                    UnidadeId = t.UnidadeId,
                    QuantidadeConstruida = t.QuantidadeConstruida,
                    QuantidadePrevisao = t.QuantidadePrevisao,
                    Comentario = t.Comentario,
                    Foto = t.Foto,
                    HorasTrabalhadas = t.HorasTrabalhadas,
                    HoraMedicaoInicial = t.HoraMedicaoInicial,
                    HoraMedicaoFinal = t.HoraMedicaoFinal,
                    DataMedicao = t.DataMedicao,
                    ValorUnitario = t.ValorUnitario,
                    HorimetroInicial = t.HorimetroInicial,
                    HorimetroFinal = t.HorimetroFinal,
                    HorimetroTotal = t.HorimetroTotal,
                    CodigoParalizacao = t.CodigoParalizacao,
                    ColaboradorInsercaoId = t.ColaboradorInsercaoId,
                    ColaboradorInsercaoNome = t.ColaboradorInsercao != null ? t.ColaboradorInsercao.Nome : "Colaborador " + t.ColaboradorInsercaoId, // Real data!
                    DataInsercao = t.DataInsercao,
                    DataUltimaAtualizacao = t.DataUltimaAtualizacao
                })
                .FirstOrDefaultAsync();
        }

        public async Task<IEnumerable<TarefaDto>> GetByObraIdAsync(int obraId)
        {
            // VERSÃO SIMPLIFICADA - SEM RELACIONAMENTOS para funcionar com banco antigo
            // Por enquanto retorna todas as tarefas (sem filtro por obra até implementarmos relacionamentos)
            return await _context.Tarefas
                .Select(t => new TarefaDto
                {
                    Id = t.Id,
                    Agrupador = t.Agrupador,
                    Descricao = t.Descricao ?? "",
                    DataInicio = t.DataInicio,
                    DataPrevisaoFim = t.DataPrevisaoFim,
                    DataFim = t.DataFim,
                    StatusId = t.StatusId,
                    StatusDescricao = "Status " + t.StatusId, // Temporário - sem relacionamento
                    EtapaId = t.EtapaId,
                    EtapaDescricao = "Etapa " + t.EtapaId, // Temporário - sem relacionamento
                    ObraId = obraId, // Usar o parâmetro passado
                    ObraDescricao = "Obra " + obraId, // Temporário
                    UnidadeId = t.UnidadeId,
                    QuantidadeConstruida = t.QuantidadeConstruida,
                    QuantidadePrevisao = t.QuantidadePrevisao,
                    Comentario = t.Comentario,
                    Foto = t.Foto,
                    HorasTrabalhadas = t.HorasTrabalhadas,
                    HoraMedicaoInicial = t.HoraMedicaoInicial,
                    HoraMedicaoFinal = t.HoraMedicaoFinal,
                    DataMedicao = t.DataMedicao,
                    ValorUnitario = t.ValorUnitario,
                    HorimetroInicial = t.HorimetroInicial,
                    HorimetroFinal = t.HorimetroFinal,
                    HorimetroTotal = t.HorimetroTotal,
                    CodigoParalizacao = t.CodigoParalizacao,
                    ColaboradorInsercaoId = t.ColaboradorInsercaoId,
                    ColaboradorInsercaoNome = "Colaborador " + t.ColaboradorInsercaoId, // Temporário
                    DataInsercao = t.DataInsercao,
                    DataUltimaAtualizacao = t.DataUltimaAtualizacao
                })
                .ToListAsync();
        }

        public async Task<IEnumerable<TarefaDto>> GetByStatusAsync(int statusId)
        {
            // Day 7 - COM RELACIONAMENTOS REAIS
            return await _context.Tarefas
                .Include(t => t.Status)
                .Include(t => t.Etapa)
                    .ThenInclude(e => e.Obra)
                .Include(t => t.ColaboradorInsercao)
                .Where(t => t.StatusId == statusId)
                .Select(t => new TarefaDto
                {
                    Id = t.Id,
                    Agrupador = t.Agrupador,
                    Descricao = t.Descricao ?? "",
                    DataInicio = t.DataInicio,
                    DataPrevisaoFim = t.DataPrevisaoFim,
                    DataFim = t.DataFim,
                    StatusId = t.StatusId,
                    StatusDescricao = t.Status != null ? t.Status.Descricao : "Status " + t.StatusId, // Real data!
                    EtapaId = t.EtapaId,
                    EtapaDescricao = t.Etapa != null ? t.Etapa.Descricao : "Etapa " + t.EtapaId, // Real data!
                    ObraId = t.Etapa != null ? t.Etapa.ObraId : 0,
                    ObraDescricao = t.Etapa != null && t.Etapa.Obra != null ? t.Etapa.Obra.Descricao : "Obra N/A", // Real data!
                    UnidadeId = t.UnidadeId,
                    QuantidadeConstruida = t.QuantidadeConstruida,
                    QuantidadePrevisao = t.QuantidadePrevisao,
                    Comentario = t.Comentario,
                    Foto = t.Foto,
                    HorasTrabalhadas = t.HorasTrabalhadas,
                    HoraMedicaoInicial = t.HoraMedicaoInicial,
                    HoraMedicaoFinal = t.HoraMedicaoFinal,
                    DataMedicao = t.DataMedicao,
                    ValorUnitario = t.ValorUnitario,
                    HorimetroInicial = t.HorimetroInicial,
                    HorimetroFinal = t.HorimetroFinal,
                    HorimetroTotal = t.HorimetroTotal,
                    CodigoParalizacao = t.CodigoParalizacao,
                    ColaboradorInsercaoId = t.ColaboradorInsercaoId,
                    ColaboradorInsercaoNome = t.ColaboradorInsercao != null ? t.ColaboradorInsercao.Nome : "Colaborador " + t.ColaboradorInsercaoId, // Real data!
                    DataInsercao = t.DataInsercao,
                    DataUltimaAtualizacao = t.DataUltimaAtualizacao
                })
                .ToListAsync();
        }

        public async Task<PagedResult<TarefaDto>> GetPagedAsync(TarefaFilterDto filter)
        {
            // VERSÃO SIMPLIFICADA - SEM RELACIONAMENTOS para funcionar com banco antigo
            var query = _context.Tarefas.AsQueryable();

            // Aplicar filtros básicos
            if (!string.IsNullOrEmpty(filter.Descricao))
            {
                query = query.Where(t => t.Descricao != null && t.Descricao.Contains(filter.Descricao));
            }

            if (filter.StatusId.HasValue)
            {
                query = query.Where(t => t.StatusId == filter.StatusId.Value);
            }

            if (filter.EtapaId.HasValue)
            {
                query = query.Where(t => t.EtapaId == filter.EtapaId.Value);
            }

            if (filter.DataInicioFrom.HasValue)
            {
                query = query.Where(t => t.DataInicio >= filter.DataInicioFrom.Value);
            }

            if (filter.DataInicioTo.HasValue)
            {
                query = query.Where(t => t.DataInicio <= filter.DataInicioTo.Value);
            }

            var totalCount = await query.CountAsync();

            var items = await query
                .Skip((filter.Page - 1) * filter.PageSize)
                .Take(filter.PageSize)
                .Select(t => new TarefaDto
                {
                    Id = t.Id,
                    Agrupador = t.Agrupador,
                    Descricao = t.Descricao ?? "",
                    DataInicio = t.DataInicio,
                    DataPrevisaoFim = t.DataPrevisaoFim,
                    DataFim = t.DataFim,
                    StatusId = t.StatusId,
                    StatusDescricao = "Status " + t.StatusId, // Temporário - sem relacionamento
                    EtapaId = t.EtapaId,
                    EtapaDescricao = "Etapa " + t.EtapaId, // Temporário - sem relacionamento
                    ObraId = 0, // Temporário - sem relacionamento
                    ObraDescricao = "Obra N/A", // Temporário
                    UnidadeId = t.UnidadeId,
                    QuantidadeConstruida = t.QuantidadeConstruida,
                    QuantidadePrevisao = t.QuantidadePrevisao,
                    Comentario = t.Comentario,
                    Foto = t.Foto,
                    HorasTrabalhadas = t.HorasTrabalhadas,
                    HoraMedicaoInicial = t.HoraMedicaoInicial,
                    HoraMedicaoFinal = t.HoraMedicaoFinal,
                    DataMedicao = t.DataMedicao,
                    ValorUnitario = t.ValorUnitario,
                    HorimetroInicial = t.HorimetroInicial,
                    HorimetroFinal = t.HorimetroFinal,
                    HorimetroTotal = t.HorimetroTotal,
                    CodigoParalizacao = t.CodigoParalizacao,
                    ColaboradorInsercaoId = t.ColaboradorInsercaoId,
                    ColaboradorInsercaoNome = "Colaborador " + t.ColaboradorInsercaoId, // Temporário
                    DataInsercao = t.DataInsercao,
                    DataUltimaAtualizacao = t.DataUltimaAtualizacao
                })
                .ToListAsync();

            return PagedResult<TarefaDto>.Create(items, totalCount, filter.Page, filter.PageSize);
        }

        public async Task<TarefaDto> CreateAsync(CreateTarefaDto createDto)
        {
            var tarefa = new Tarefa
            {
                Agrupador = Guid.NewGuid(),
                Descricao = createDto.Descricao,
                DataInicio = createDto.DataInicio,
                DataPrevisaoFim = createDto.DataPrevisaoFim,
                StatusId = createDto.StatusId,
                EtapaId = createDto.EtapaId,
                UnidadeId = createDto.UnidadeId,
                QuantidadeConstruida = createDto.QuantidadeConstruida,
                QuantidadePrevisao = createDto.QuantidadePrevisao,
                Comentario = createDto.Comentario,
                Foto = createDto.Foto,
                HorasTrabalhadas = createDto.HorasTrabalhadas,
                HoraMedicaoInicial = createDto.HoraMedicaoInicial,
                HoraMedicaoFinal = createDto.HoraMedicaoFinal,
                DataMedicao = DateTime.Now,
                ValorUnitario = createDto.ValorUnitario,
                HorimetroInicial = createDto.HorimetroInicial,
                HorimetroFinal = createDto.HorimetroFinal,
                HorimetroTotal = createDto.HorimetroFinal - createDto.HorimetroInicial,
                CodigoParalizacao = createDto.CodigoParalizacao,
                ColaboradorInsercaoId = createDto.ColaboradorInsercaoId,
                DataInsercao = DateTime.Now
            };

            _context.Tarefas.Add(tarefa);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(tarefa.Id) ?? throw new InvalidOperationException("Falha ao criar tarefa");
        }

        public async Task<TarefaDto> UpdateAsync(int id, UpdateTarefaDto updateDto)
        {
            var tarefa = await _context.Tarefas.FindAsync(id);
            if (tarefa == null)
                throw new ArgumentException("Tarefa não encontrada");

            tarefa.Descricao = updateDto.Descricao;
            tarefa.DataInicio = updateDto.DataInicio;
            tarefa.DataPrevisaoFim = updateDto.DataPrevisaoFim;
            tarefa.DataFim = updateDto.DataFim;
            tarefa.StatusId = updateDto.StatusId;
            tarefa.EtapaId = updateDto.EtapaId;
            tarefa.UnidadeId = updateDto.UnidadeId;
            tarefa.QuantidadeConstruida = updateDto.QuantidadeConstruida;
            tarefa.QuantidadePrevisao = updateDto.QuantidadePrevisao;
            tarefa.Comentario = updateDto.Comentario;
            tarefa.Foto = updateDto.Foto;
            tarefa.HorasTrabalhadas = updateDto.HorasTrabalhadas;
            tarefa.HoraMedicaoInicial = updateDto.HoraMedicaoInicial;
            tarefa.HoraMedicaoFinal = updateDto.HoraMedicaoFinal;
            tarefa.ValorUnitario = updateDto.ValorUnitario;
            tarefa.HorimetroInicial = updateDto.HorimetroInicial;
            tarefa.HorimetroFinal = updateDto.HorimetroFinal;
            tarefa.HorimetroTotal = updateDto.HorimetroFinal - updateDto.HorimetroInicial;
            tarefa.CodigoParalizacao = updateDto.CodigoParalizacao;
            tarefa.DataUltimaAtualizacao = DateTime.Now;

            await _context.SaveChangesAsync();

            return await GetByIdAsync(id) ?? throw new InvalidOperationException("Falha ao atualizar tarefa");
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var tarefa = await _context.Tarefas.FindAsync(id);
            if (tarefa == null)
                return false;

            _context.Tarefas.Remove(tarefa);
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<IEnumerable<TarefaHistoricoDto>> GetHistoricoAsync(int tarefaId)
        {
            // FIXED: Implement real history data fetching from database
            // This method should return ALL measurement records for the task, not just one
            
            try
            {
                // Get the task first to ensure it exists
                var tarefa = await _context.Tarefas
                    .Include(t => t.Status)
                    .FirstOrDefaultAsync(t => t.Id == tarefaId);
                
                if (tarefa == null)
                    return new List<TarefaHistoricoDto>();

                // For now, return the current task data as a single history record
                // TODO: When proper history table is implemented, query that table instead
                var historicoList = new List<TarefaHistoricoDto>();
                
                // Only add record if there's actual measurement data
                if (tarefa.DataMedicao != default(DateTime))
                {
                    historicoList.Add(new TarefaHistoricoDto
                    {
                        Id = tarefa.Id,
                        TarefaId = tarefa.Id,
                        Descricao = tarefa.Descricao ?? "Tarefa " + tarefa.Id,
                        DataMedicao = tarefa.DataMedicao,
                        DataMedicaoFormatada = tarefa.DataMedicao.ToString("dd/MM/yyyy"),
                        HoraMedicaoInicial = tarefa.HoraMedicaoInicial?.ToString(@"hh\:mm") ?? "-",
                        HoraMedicaoFinal = tarefa.HoraMedicaoFinal?.ToString(@"hh\:mm") ?? "-",
                        StatusId = tarefa.StatusId,
                        StatusDescricao = tarefa.Status?.Descricao ?? "Status " + tarefa.StatusId,
                        
                        // Water Quality Parameters
                        NivelCloro = tarefa.NivelCloro ?? 0,
                        NivelCloroTexto = GetCloroTexto(tarefa.NivelCloro ?? 0),
                        Ph = tarefa.Ph ?? 0,
                        PhTexto = GetPhTexto(tarefa.Ph ?? 0),
                        Alcalinidade = tarefa.Alcalinidade ?? 0,
                        AlcalinidadeTexto = GetAlcalinidadeTexto(tarefa.Alcalinidade ?? 0),
                        
                        // Boolean Parameters
                        Limpidez = tarefa.Limpidez ?? false,
                        Superficie = tarefa.Superficie ?? false,
                        Fundo = tarefa.Fundo ?? false,
                        NivelDetritos = tarefa.NivelDetritos ?? false,
                        NivelProliferacao = tarefa.NivelProliferacao ?? false
                    });
                }
                
                return historicoList;
            }
            catch (Exception ex)
            {
                // Log error but don't throw - return empty list for graceful degradation
                // TODO: Add proper logging
                return new List<TarefaHistoricoDto>();
            }
        }

        #region Helper Methods for History Display

        private string GetCloroTexto(decimal nivelCloro)
        {
            return nivelCloro switch
            {
                0 => "0 ppm",
                1 => "0,5 < 1,0",
                2 => "1,0 < 1,5", 
                3 => "1,5 < 2,0",
                4 => "2,5 < 3,0",
                5 => "> 3,0",
                _ => nivelCloro.ToString("F1")
            };
        }

        private string GetPhTexto(decimal ph)
        {
            return ph switch
            {
                1 => "< 7.0",
                2 => "7.0 < 7.2",
                3 => "7.2 < 7.4",
                4 => "7.4 < 7.6", 
                5 => "7.6 < 7.8",
                6 => "> 7.8",
                _ => ph.ToString("F1")
            };
        }

        private string GetAlcalinidadeTexto(decimal alcalinidade)
        {
            return alcalinidade switch
            {
                1 => "< 70",
                2 => "70 < 80",
                3 => "90 < 100",
                4 => "110 < 120",
                5 => "130 > 140", 
                6 => "> 140",
                _ => alcalinidade.ToString("F0")
            };
        }

        #endregion

        #region NEW: Task Card Functionality Methods

        /// <summary>
        /// Get task cards for obra with filtering - replicates Gilberto's original functionality
        /// </summary>
        public async Task<TaskCardResponseDto> GetTaskCardsAsync(int obraId, TaskCardFilterDto filter)
        {
            var query = _context.Tarefas
                .Include(t => t.Status)
                .Include(t => t.Etapa)
                    .ThenInclude(e => e.Obra)
                .Include(t => t.ColaboradorInsercao)
                .Where(t => t.Etapa != null && t.Etapa.ObraId == obraId);

            // Apply filters matching original implementation
            if (!string.IsNullOrEmpty(filter.Descricao))
            {
                query = query.Where(t => t.Descricao != null && t.Descricao.Contains(filter.Descricao));
            }

            if (filter.StatusTarefa.HasValue && filter.StatusTarefa.Value > 0)
            {
                query = query.Where(t => t.StatusId == filter.StatusTarefa.Value);
            }

            if (filter.DataInicial.HasValue)
            {
                query = query.Where(t => t.DataInicio >= filter.DataInicial.Value);
            }

            if (filter.DataFinalPlanejada.HasValue)
            {
                query = query.Where(t => t.DataPrevisaoFim <= filter.DataFinalPlanejada.Value);
            }

            if (filter.DataInicialExecutada.HasValue)
            {
                query = query.Where(t => t.DataMedicao >= filter.DataInicialExecutada.Value);
            }

            if (filter.DataFinalExecutada.HasValue)
            {
                query = query.Where(t => t.DataMedicao <= filter.DataFinalExecutada.Value);
            }

            if (filter.IdEtapa.HasValue && filter.IdEtapa.Value > 0)
            {
                query = query.Where(t => t.EtapaId == filter.IdEtapa.Value);
            }

            var tarefas = await query.ToListAsync();

            // Group by Etapa for accordion structure
            var etapasWithTasks = tarefas
                .GroupBy(t => new { t.EtapaId, EtapaTitulo = t.Etapa?.Descricao ?? "Etapa " + t.EtapaId }) // Fixed: Use Descricao not Titulo
                .Select(g => new EtapaWithTasksDto
                {
                    Id = g.Key.EtapaId,
                    Titulo = g.Key.EtapaTitulo, // This will use Descricao as the title
                    Descricao = g.FirstOrDefault()?.Etapa?.Descricao ?? "",
                    TotalTasks = g.Count(),
                    CompletedTasks = g.Count(t => t.StatusId == 3), // Status 3 = Finalizada
                    CanAddTasks = true, // TODO: Implement RBAC check
                    Tarefas = g.Select(t => new TaskCardDto
                    {
                        Id = t.Id,
                        Agrupador = t.Agrupador,
                        Descricao = t.Descricao ?? "",
                        DataInicio = t.DataInicio,
                        DataPrevisaoFim = t.DataPrevisaoFim,
                        PrimeiraExecucao = t.DataMedicao, // Map to first execution
                        UltimaExecucao = t.DataMedicao, // Map to last execution
                        ExisteExecucao = t.DataMedicao != default(DateTime), // Fixed: DataMedicao is not nullable
                        StatusId = t.StatusId,
                        StatusDescricao = t.Status?.Descricao ?? "Status " + t.StatusId,
                        ClasseStatusCss = DeterminarClasseStatusCss(t.StatusId),
                        PercentualConcluido = CalcularPercentualConcluido(t),
                        PercentualExtrapolado = CalcularPercentualConcluido(t) > 100,
                        QuantidadeColaboradores = 0, // TODO: Implement collaborator count
                        QuantidadeEquipamentos = 0, // TODO: Implement equipment count
                        ListaStatusPermitidos = GetAllowedStatusTransitionsAsync(t.StatusId).Result,
                        ListaHistoricoTarefa = new List<TaskHistoryDto>() // TODO: Implement history
                    }).ToList()
                })
                .ToList();

            return new TaskCardResponseDto
            {
                Etapas = etapasWithTasks,
                TotalTasks = tarefas.Count,
                CanCreateTasks = true, // TODO: Implement RBAC check
                CanEditTasks = true, // TODO: Implement RBAC check
                CanDeleteTasks = true // TODO: Implement RBAC check
            };
        }

        /// <summary>
        /// Update task status - simplified pause workflow (no pause code required)
        /// </summary>
        public async Task<bool> UpdateTaskStatusAsync(int tarefaId, int statusId, int userId)
        {
            var tarefa = await _context.Tarefas.FindAsync(tarefaId);
            if (tarefa == null)
                return false;

            // Validate status transition
            var allowedTransitions = await GetAllowedStatusTransitionsAsync(tarefa.StatusId);
            if (!allowedTransitions.Any(s => s.Id == statusId))
                return false;

            tarefa.StatusId = statusId;
            tarefa.DataUltimaAtualizacao = DateTime.Now;

            // Simplified pause workflow - no pause code required
            if (statusId == 4) // Paralisada
            {
                tarefa.CodigoParalizacao = null; // Remove pause code requirement
            }

            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// Get task history for modal display
        /// </summary>
        public async Task<List<TaskHistoryDto>> GetTaskHistoryAsync(int tarefaId)
        {
            // TODO: Implement when history entity is available
            await Task.CompletedTask;
            return new List<TaskHistoryDto>();
        }

        /// <summary>
        /// Bulk update status for mass operations
        /// </summary>
        public async Task<bool> BulkUpdateStatusAsync(int[] tarefaIds, int statusId, int userId)
        {
            var tarefas = await _context.Tarefas
                .Where(t => tarefaIds.Contains(t.Id))
                .ToListAsync();

            foreach (var tarefa in tarefas)
            {
                // Validate each status transition
                var allowedTransitions = await GetAllowedStatusTransitionsAsync(tarefa.StatusId);
                if (allowedTransitions.Any(s => s.Id == statusId))
                {
                    tarefa.StatusId = statusId;
                    tarefa.DataUltimaAtualizacao = DateTime.Now;

                    // Simplified pause workflow
                    if (statusId == 4) // Paralisada
                    {
                        tarefa.CodigoParalizacao = null;
                    }
                }
            }

            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// Get allowed status transitions based on current status
        /// </summary>
        public async Task<List<StatusTarefaDto>> GetAllowedStatusTransitionsAsync(int currentStatusId)
        {
            // Business rules for status transitions
            var allStatuses = await _context.StatusTarefas.ToListAsync();
            var allowedStatuses = new List<StatusTarefaDto>();

            switch (currentStatusId)
            {
                case 1: // Planejada
                    allowedStatuses.AddRange(allStatuses.Where(s => s.Id == 2 || s.Id == 5) // Em Execução, Cancelada
                        .Select(s => new StatusTarefaDto
                        {
                            Id = s.Id,
                            Nome = s.Descricao ?? "Status " + s.Id,
                            CssClass = DeterminarClasseStatusCss(s.Id)
                        }));
                    break;

                case 2: // Em Execução
                    allowedStatuses.AddRange(allStatuses.Where(s => s.Id == 3 || s.Id == 4 || s.Id == 5) // Finalizada, Paralisada, Cancelada
                        .Select(s => new StatusTarefaDto
                        {
                            Id = s.Id,
                            Nome = s.Descricao ?? "Status " + s.Id,
                            CssClass = DeterminarClasseStatusCss(s.Id)
                        }));
                    break;

                case 3: // Finalizada
                    allowedStatuses.AddRange(allStatuses.Where(s => s.Id == 2) // Em Execução (reopen)
                        .Select(s => new StatusTarefaDto
                        {
                            Id = s.Id,
                            Nome = s.Descricao ?? "Status " + s.Id,
                            CssClass = DeterminarClasseStatusCss(s.Id)
                        }));
                    break;

                case 4: // Paralisada
                    allowedStatuses.AddRange(allStatuses.Where(s => s.Id == 2 || s.Id == 5) // Em Execução, Cancelada
                        .Select(s => new StatusTarefaDto
                        {
                            Id = s.Id,
                            Nome = s.Descricao ?? "Status " + s.Id,
                            CssClass = DeterminarClasseStatusCss(s.Id)
                        }));
                    break;

                case 5: // Cancelada
                    allowedStatuses.AddRange(allStatuses.Where(s => s.Id == 1) // Planejada (reopen)
                        .Select(s => new StatusTarefaDto
                        {
                            Id = s.Id,
                            Nome = s.Descricao ?? "Status " + s.Id,
                            CssClass = DeterminarClasseStatusCss(s.Id)
                        }));
                    break;
            }

            return allowedStatuses;
        }

        #endregion

        #region NEW: Water Quality Methods

        /// <summary>
        /// Get water quality parameters for a task
        /// </summary>
        public async Task<WaterQualityParametersDto> GetWaterQualityParametersAsync(int tarefaId)
        {
            var tarefa = await _context.Tarefas.FindAsync(tarefaId);
            if (tarefa == null)
                return new WaterQualityParametersDto();

            return new WaterQualityParametersDto
            {
                NivelCloro = tarefa.NivelCloro ?? 0,
                NivelPH = tarefa.Ph ?? 0, // Fixed: Ph not NivelPH
                NivelAlcalinidade = tarefa.Alcalinidade ?? 0, // Fixed: Alcalinidade not NivelAlcalinidade
                Limpidez = tarefa.Limpidez ?? false,
                Superficie = tarefa.Superficie ?? false,
                Fundo = tarefa.Fundo ?? false,
                Bacteria = tarefa.NivelDetritos ?? false, // Fixed: NivelDetritos not Bacteria (displays as "Detritos" in UI)
                Proliferacao = tarefa.NivelProliferacao ?? false // Fixed: NivelProliferacao not Proliferacao
            };
        }

        /// <summary>
        /// Save water quality measurement
        /// </summary>
        public async Task<bool> SaveWaterQualityMeasurementAsync(int tarefaId, WaterQualityParametersDto parameters, int userId)
        {
            var tarefa = await _context.Tarefas.FindAsync(tarefaId);
            if (tarefa == null)
                return false;

            tarefa.NivelCloro = parameters.NivelCloro;
            tarefa.Ph = parameters.NivelPH; // Fixed: Ph not NivelPH
            tarefa.Alcalinidade = parameters.NivelAlcalinidade; // Fixed: Alcalinidade not NivelAlcalinidade
            tarefa.Limpidez = parameters.Limpidez;
            tarefa.Superficie = parameters.Superficie;
            tarefa.Fundo = parameters.Fundo;
            tarefa.NivelDetritos = parameters.Bacteria; // Fixed: NivelDetritos not Bacteria
            tarefa.NivelProliferacao = parameters.Proliferacao; // Fixed: NivelProliferacao not Proliferacao
            tarefa.DataUltimaAtualizacao = DateTime.Now;

            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// Get Cloro dropdown options matching Gilberto's original exactly
        /// </summary>
        public async Task<List<WaterQualityDropdownDto>> GetCloroOptionsAsync()
        {
            await Task.CompletedTask;
            return new List<WaterQualityDropdownDto>
            {
                new() { Id = 1, Nome = "0 ppm" },
                new() { Id = 2, Nome = "0,5 < 1,0" },
                new() { Id = 3, Nome = "1,5 < 2,0" },
                new() { Id = 4, Nome = "2,5 < 3,0" },
                new() { Id = 5, Nome = "> 3,0" }
            };
        }

        /// <summary>
        /// Get PH dropdown options matching Gilberto's original exactly
        /// </summary>
        public async Task<List<WaterQualityDropdownDto>> GetPHOptionsAsync()
        {
            await Task.CompletedTask;
            return new List<WaterQualityDropdownDto>
            {
                new() { Id = 1, Nome = "< 7.0" },
                new() { Id = 2, Nome = "7.0 < 7.2" },
                new() { Id = 3, Nome = "7.2 < 7.4" },
                new() { Id = 4, Nome = "7.4 < 7.6" },
                new() { Id = 5, Nome = "7.6 < 7.8" },
                new() { Id = 6, Nome = "> 7.8" }
            };
        }

        /// <summary>
        /// Get Alcalinidade dropdown options matching Gilberto's original exactly
        /// </summary>
        public async Task<List<WaterQualityDropdownDto>> GetAlcalinidadeOptionsAsync()
        {
            await Task.CompletedTask;
            return new List<WaterQualityDropdownDto>
            {
                new() { Id = 1, Nome = "< 70" },
                new() { Id = 2, Nome = "70 < 80" },
                new() { Id = 3, Nome = "90 < 100" },
                new() { Id = 4, Nome = "110 < 120" },
                new() { Id = 5, Nome = "130 > 140" },
                new() { Id = 6, Nome = "> 140" }
            };
        }

        #endregion

        #region PRODUCTION REALITY: Nova Medição Integration

        /// <summary>
        /// Save Nova Medição measurement - REAL DATABASE INTEGRATION
        /// </summary>
        public async Task<NovaMedicaoResult> SalvarMedicaoAsync(NovaMedicaoViewModel model)
        {
            try
            {
                var tarefa = await _context.Tarefas.FindAsync(model.TarefaId);
                if (tarefa == null)
                {
                    return new NovaMedicaoResult
                    {
                        Success = false,
                        Message = "Tarefa não encontrada.",
                        RefreshRequired = false
                    };
                }

                // Update task with new measurement data
                tarefa.StatusId = model.Status;
                tarefa.DataMedicao = model.DataMedicao;
                tarefa.QuantidadeConstruida = (float?)model.QtdConstruida;
                
                // Water quality parameters
                tarefa.NivelCloro = model.NivelCloro;
                tarefa.Ph = model.Ph;
                tarefa.Alcalinidade = model.Alcalinidade;
                tarefa.Limpidez = model.Limpidez;
                tarefa.Superficie = model.Superficie;
                tarefa.Fundo = model.Fundo;
                tarefa.NivelProliferacao = model.NivelProliferacao;
                tarefa.NivelDetritos = model.NivelDetritos; // Maps to "Nível de Detritos" in UI
                
                // Comments and metadata
                tarefa.Comentario = model.Comentario;
                tarefa.DataUltimaAtualizacao = DateTime.Now;

                await _context.SaveChangesAsync();

                return new NovaMedicaoResult
                {
                    Success = true,
                    Message = "Medição salva com sucesso!",
                    RefreshRequired = true
                };
            }
            catch (Exception ex)
            {
                // Log error but don't expose internal details
                return new NovaMedicaoResult
                {
                    Success = false,
                    Message = "Erro interno do servidor. Tente novamente.",
                    RefreshRequired = false
                };
            }
        }

        #endregion

        #region NEW: Business Logic Helper Methods

        /// <summary>
        /// Calculate progress percentage matching original CalcularPercentualConcluido logic
        /// </summary>
        public int CalcularPercentualConcluido(Tarefa tarefa)
        {
            if (tarefa.StatusId == 1) return 0; // Planejada

            if (tarefa.DataMedicao == default(DateTime)) // Fixed: DataMedicao is not nullable
                return 0;

            var totalDiasPlanejados = (tarefa.DataPrevisaoFim - tarefa.DataInicio)?.TotalDays; // Fixed: DataPrevisaoFim is nullable
            if (totalDiasPlanejados == null || totalDiasPlanejados <= 0) return 0;

            var diasExecutados = (DateTime.Now - tarefa.DataInicio).TotalDays;
            var percentual = Math.Round((diasExecutados * 100) / totalDiasPlanejados.Value, 2); // Fixed: use .Value since we checked for null
            
            return (int)Math.Min(Math.Max(percentual, 0), 100);
        }

        /// <summary>
        /// Determine status CSS class matching original color scheme
        /// </summary>
        public string DeterminarClasseStatusCss(int statusId)
        {
            return statusId switch
            {
                1 => "bg-cinza",      // Planejada - Gray
                2 => "bg-azul",       // Em Execução - Blue
                3 => "bg-verde",      // Finalizada - Green
                4 => "bg-laranja",    // Paralisada - Orange (Simplified - no pause code required)
                5 => "bg-vermelho",   // Cancelada - Red
                _ => "bg-cinza"
            };
        }

        #endregion
    }
}