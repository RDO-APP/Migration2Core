using Microsoft.EntityFrameworkCore;
using RdoApp.Core.Data.Context;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Services.Interfaces;
using System.Linq;

namespace RdoApp.Core.Services.Implementations
{
    /// <summary>
    /// Service implementation for Etapa operations
    /// Uses Entity Framework to access AWS MySQL database
    /// </summary>
    public class EtapaService : IEtapaService
    {
        private readonly RdoContext _context;
        private readonly ILogger<EtapaService> _logger;
        
        public EtapaService(RdoContext context, ILogger<EtapaService> logger)
        {
            _context = context;
            _logger = logger;
        }
        
        public async Task<List<EtapaViewModel>> GetEtapasWithTarefasAsync(EtapaFilterViewModel filter)
        {
            try
            {
                _logger.LogInformation("Loading etapas with tarefas for obra {ObraId}", filter.IdObra);
                
                // Build query for etapas with tarefas
                IQueryable<Etapa> query = _context.Etapas
                    .Include(e => e.Tarefas)
                        .ThenInclude(t => t.Status)
                    .Where(e => e.ObraId == filter.IdObra);
                
                // Apply etapa filter if specified
                if (filter.IdEtapa.HasValue)
                {
                    query = query.Where(e => e.Id == filter.IdEtapa.Value);
                }
                
                // Apply ordering at the end
                query = query.OrderBy(e => e.Id);
                
                var etapas = await query.ToListAsync();
                
                var result = new List<EtapaViewModel>();
                
                foreach (var etapa in etapas)
                {
                    // Filter tarefas based on filter criteria
                    var filteredTarefas = etapa.Tarefas.AsQueryable();
                    
                    // Apply description filter
                    if (!string.IsNullOrWhiteSpace(filter.Descricao))
                    {
                        filteredTarefas = filteredTarefas.Where(t => 
                            t.Descricao != null && t.Descricao.Contains(filter.Descricao, StringComparison.OrdinalIgnoreCase));
                    }
                    
                    // Apply status filter
                    if (filter.StatusTarefa.HasValue && filter.StatusTarefa.Value > 0)
                    {
                        filteredTarefas = filteredTarefas.Where(t => t.StatusId == filter.StatusTarefa.Value);
                    }
                    
                    // Apply date filters
                    if (filter.DataInicial.HasValue)
                    {
                        filteredTarefas = filteredTarefas.Where(t => t.DataInicio >= filter.DataInicial.Value);
                    }
                    
                    if (filter.DataFinalPlanejada.HasValue)
                    {
                        filteredTarefas = filteredTarefas.Where(t => 
                            t.DataPrevisaoFim.HasValue && t.DataPrevisaoFim.Value <= filter.DataFinalPlanejada.Value);
                    }
                    
                    if (filter.DataInicialExecutada.HasValue)
                    {
                        filteredTarefas = filteredTarefas.Where(t => t.DataMedicao >= filter.DataInicialExecutada.Value);
                    }
                    
                    if (filter.DataFinalExecutada.HasValue)
                    {
                        filteredTarefas = filteredTarefas.Where(t => 
                            t.DataFim.HasValue && t.DataFim.Value <= filter.DataFinalExecutada.Value);
                    }
                    
                    var tarefasList = filteredTarefas.ToList();
                    
                    // CRITICAL FIX: Group by tar_nr_agrupador to eliminate duplicate cards
                    // Each unique agrupador represents one logical task, not individual measurements
                    var groupedTarefas = tarefasList
                        .GroupBy(t => t.Agrupador)
                        .Select(group => {
                            // Take the most recent tarefa from each group (latest measurement)
                            var latestTarefa = group.OrderByDescending(t => t.DataMedicao).First();
                            
                            // Aggregate data from all measurements in the group
                            var totalQuantidadeConstruida = group.Sum(t => t.QuantidadeConstruida ?? 0);
                            var avgQuantidadePrevisao = group.Average(t => t.QuantidadePrevisao ?? 0);
                            
                            // Create a consolidated tarefa representing the group
                            return new Tarefa
                            {
                                Id = latestTarefa.Id,
                                Agrupador = latestTarefa.Agrupador,
                                Descricao = latestTarefa.Descricao,
                                StatusId = latestTarefa.StatusId,
                                EtapaId = latestTarefa.EtapaId,
                                DataInicio = group.Min(t => t.DataInicio),
                                DataPrevisaoFim = latestTarefa.DataPrevisaoFim,
                                DataMedicao = latestTarefa.DataMedicao,
                                DataFim = latestTarefa.DataFim,
                                QuantidadeConstruida = (float)totalQuantidadeConstruida,
                                QuantidadePrevisao = (decimal)avgQuantidadePrevisao,
                                Status = latestTarefa.Status,
                                Etapa = latestTarefa.Etapa,
                                ColaboradorInsercaoId = latestTarefa.ColaboradorInsercaoId,
                                DataInsercao = latestTarefa.DataInsercao,
                                DataUltimaAtualizacao = latestTarefa.DataUltimaAtualizacao,
                                Comentario = latestTarefa.Comentario,
                                Foto = latestTarefa.Foto,
                                HorasTrabalhadas = group.Sum(t => t.HorasTrabalhadas ?? 0),
                                HoraMedicaoInicial = group.Min(t => t.HoraMedicaoInicial),
                                HoraMedicaoFinal = group.Max(t => t.HoraMedicaoFinal),
                                ValorUnitario = latestTarefa.ValorUnitario,
                                UnidadeId = latestTarefa.UnidadeId,
                                CodigoParalizacao = latestTarefa.CodigoParalizacao,
                                
                                // Water quality fields - use latest values
                                NivelCloro = latestTarefa.NivelCloro,
                                Ph = latestTarefa.Ph,
                                Alcalinidade = latestTarefa.Alcalinidade,
                                Limpidez = latestTarefa.Limpidez,
                                Superficie = latestTarefa.Superficie,
                                Fundo = latestTarefa.Fundo,
                                NivelDetritos = latestTarefa.NivelDetritos,
                                NivelProliferacao = latestTarefa.NivelProliferacao
                            };
                        })
                        .ToList();
                    
                    _logger.LogInformation("Etapa {EtapaId}: Grouped {OriginalCount} measurements into {GroupedCount} unique tasks", 
                        etapa.Id, tarefasList.Count, groupedTarefas.Count);
                    
                    // Only include etapas that have tarefas after filtering and grouping
                    if (groupedTarefas.Any())
                    {
                        var etapaViewModel = new EtapaViewModel
                        {
                            Id = etapa.Id,
                            Descricao = etapa.Descricao ?? $"Etapa {etapa.Id}",
                            ObraId = etapa.ObraId,
                            TotalTarefas = groupedTarefas.Count,
                            TarefasConcluidas = groupedTarefas.Count(t => t.StatusId == 3), // Status 3 = Finalizada
                            TarefasEmAndamento = groupedTarefas.Count(t => t.StatusId == 2), // Status 2 = Em Execução
                            TarefasPlanejadas = groupedTarefas.Count(t => t.StatusId == 1), // Status 1 = Planejada
                            TarefasParalisadas = groupedTarefas.Count(t => t.StatusId == 4), // Status 4 = Pausada
                            PercentualConclusao = groupedTarefas.Count > 0 
                                ? (double)groupedTarefas.Count(t => t.StatusId == 3) / groupedTarefas.Count * 100 
                                : 0,
                            Tarefas = groupedTarefas.Select(MapTarefaToViewModel).ToList()
                        };
                        
                        result.Add(etapaViewModel);
                    }
                }
                
                _logger.LogInformation("Loaded {Count} etapas with {TotalTasks} total tasks", 
                    result.Count, result.Sum(e => e.TotalTarefas));
                
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading etapas with tarefas for obra {ObraId}", filter.IdObra);
                throw;
            }
        }
        
        public async Task<List<StatusOption>> GetStatusOptionsAsync()
        {
            try
            {
                _logger.LogInformation("Loading status options from database");
                
                var statusList = await _context.StatusTarefas
                    .OrderBy(s => s.Id)
                    .ToListAsync();
                
                var result = new List<StatusOption>
                {
                    new StatusOption { Id = 0, Nome = "Todos", CssClass = "" }
                };
                
                foreach (var status in statusList)
                {
                    var cssClass = status.Id switch
                    {
                        1 => "bg-secondary",    // Planejada - Gray
                        2 => "bg-primary",      // Em Execução - Blue
                        3 => "bg-success",      // Finalizada - Green
                        4 => "bg-warning",      // Pausada - Yellow/Orange
                        5 => "bg-danger",       // Cancelada - Red
                        _ => "bg-secondary"
                    };
                    
                    result.Add(new StatusOption 
                    { 
                        Id = status.Id, 
                        Nome = status.Descricao ?? $"Status {status.Id}", 
                        CssClass = cssClass 
                    });
                }
                
                _logger.LogInformation("Loaded {Count} status options", result.Count);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading status options");
                throw;
            }
        }
        
        public async Task<List<EtapaOption>> GetEtapaOptionsAsync(int obraId)
        {
            try
            {
                _logger.LogInformation("Loading etapa options for obra {ObraId}", obraId);
                
                var etapas = await _context.Etapas
                    .Where(e => e.ObraId == obraId)
                    .OrderBy(e => e.Id)
                    .ToListAsync();
                
                var result = etapas.Select(e => new EtapaOption
                {
                    Id = e.Id,
                    Titulo = e.Descricao ?? $"Etapa {e.Id}"
                }).ToList();
                
                _logger.LogInformation("Loaded {Count} etapa options for obra {ObraId}", result.Count, obraId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading etapa options for obra {ObraId}", obraId);
                throw;
            }
        }
        
        public async Task<List<EtapaViewModel>> ObterEtapasViewModelAsync(int obraId, EtapaFilterViewModel? filter = null)
        {
            try
            {
                _logger.LogInformation("Loading etapas ViewModels for obra {ObraId}", obraId);
                
                IQueryable<Etapa> query = _context.Etapas
                    .Include(e => e.Tarefas)
                        .ThenInclude(t => t.Status)
                    .Where(e => e.ObraId == obraId);
                
                // Apply filter if provided
                if (filter?.IdEtapa.HasValue == true)
                {
                    query = query.Where(e => e.Id == filter.IdEtapa.Value);
                }
                
                // Apply ordering at the end
                query = query.OrderBy(e => e.Id);
                
                var etapas = await query.ToListAsync();
                
                var result = etapas.Select(etapa => {
                    // CRITICAL FIX: Group tarefas by tar_nr_agrupador to eliminate duplicates
                    var groupedTarefas = etapa.Tarefas
                        .GroupBy(t => t.Agrupador)
                        .Select(group => {
                            // Take the most recent tarefa from each group (latest measurement)
                            var latestTarefa = group.OrderByDescending(t => t.DataMedicao).First();
                            
                            // Aggregate data from all measurements in the group
                            var totalQuantidadeConstruida = group.Sum(t => t.QuantidadeConstruida ?? 0);
                            var avgQuantidadePrevisao = group.Average(t => t.QuantidadePrevisao ?? 0);
                            
                            // Create a consolidated tarefa representing the group
                            return new Tarefa
                            {
                                Id = latestTarefa.Id,
                                Agrupador = latestTarefa.Agrupador,
                                Descricao = latestTarefa.Descricao,
                                StatusId = latestTarefa.StatusId,
                                EtapaId = latestTarefa.EtapaId,
                                DataInicio = group.Min(t => t.DataInicio),
                                DataPrevisaoFim = latestTarefa.DataPrevisaoFim,
                                DataMedicao = latestTarefa.DataMedicao,
                                DataFim = latestTarefa.DataFim,
                                QuantidadeConstruida = (float)totalQuantidadeConstruida,
                                QuantidadePrevisao = (decimal)avgQuantidadePrevisao,
                                Status = latestTarefa.Status,
                                Etapa = latestTarefa.Etapa,
                                ColaboradorInsercaoId = latestTarefa.ColaboradorInsercaoId,
                                DataInsercao = latestTarefa.DataInsercao,
                                DataUltimaAtualizacao = latestTarefa.DataUltimaAtualizacao,
                                Comentario = latestTarefa.Comentario,
                                Foto = latestTarefa.Foto,
                                HorasTrabalhadas = group.Sum(t => t.HorasTrabalhadas ?? 0),
                                HoraMedicaoInicial = group.Min(t => t.HoraMedicaoInicial),
                                HoraMedicaoFinal = group.Max(t => t.HoraMedicaoFinal),
                                ValorUnitario = latestTarefa.ValorUnitario,
                                UnidadeId = latestTarefa.UnidadeId,
                                CodigoParalizacao = latestTarefa.CodigoParalizacao,
                                
                                // Water quality fields - use latest values
                                NivelCloro = latestTarefa.NivelCloro,
                                Ph = latestTarefa.Ph,
                                Alcalinidade = latestTarefa.Alcalinidade,
                                Limpidez = latestTarefa.Limpidez,
                                Superficie = latestTarefa.Superficie,
                                Fundo = latestTarefa.Fundo,
                                NivelDetritos = latestTarefa.NivelDetritos,
                                NivelProliferacao = latestTarefa.NivelProliferacao
                            };
                        })
                        .ToList();
                    
                    return new EtapaViewModel
                    {
                        Id = etapa.Id,
                        Descricao = etapa.Descricao ?? $"Etapa {etapa.Id}",
                        ObraId = etapa.ObraId,
                        TotalTarefas = groupedTarefas.Count,
                        TarefasConcluidas = groupedTarefas.Count(t => t.StatusId == 3),
                        TarefasEmAndamento = groupedTarefas.Count(t => t.StatusId == 2),
                        TarefasPlanejadas = groupedTarefas.Count(t => t.StatusId == 1),
                        TarefasParalisadas = groupedTarefas.Count(t => t.StatusId == 4),
                        PercentualConclusao = groupedTarefas.Count > 0 
                            ? (double)groupedTarefas.Count(t => t.StatusId == 3) / groupedTarefas.Count * 100 
                            : 0,
                        Tarefas = groupedTarefas.Select(MapTarefaToViewModel).ToList()
                    };
                }).ToList();
                
                _logger.LogInformation("Loaded {Count} etapas ViewModels for obra {ObraId}", result.Count, obraId);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading etapas ViewModels for obra {ObraId}", obraId);
                throw;
            }
        }
        
        public async Task<EtapaViewModel?> ObterEtapaPorIdAsync(int etapaId, int colaboradorId = 1)
        {
            try
            {
                _logger.LogInformation("Loading etapa {EtapaId}", etapaId);
                
                var etapa = await _context.Etapas
                    .Include(e => e.Tarefas)
                        .ThenInclude(t => t.Status)
                    .OrderBy(e => e.Id)
                    .FirstOrDefaultAsync(e => e.Id == etapaId);
                
                if (etapa == null)
                {
                    _logger.LogWarning("Etapa {EtapaId} not found", etapaId);
                    return null;
                }
                
                // CRITICAL FIX: Group tarefas by tar_nr_agrupador to eliminate duplicates
                var groupedTarefas = etapa.Tarefas
                    .GroupBy(t => t.Agrupador)
                    .Select(group => {
                        // Take the most recent tarefa from each group (latest measurement)
                        var latestTarefa = group.OrderByDescending(t => t.DataMedicao).First();
                        
                        // Aggregate data from all measurements in the group
                        var totalQuantidadeConstruida = group.Sum(t => t.QuantidadeConstruida ?? 0);
                        var avgQuantidadePrevisao = group.Average(t => t.QuantidadePrevisao ?? 0);
                        
                        // Create a consolidated tarefa representing the group
                        return new Tarefa
                        {
                            Id = latestTarefa.Id,
                            Agrupador = latestTarefa.Agrupador,
                            Descricao = latestTarefa.Descricao,
                            StatusId = latestTarefa.StatusId,
                            EtapaId = latestTarefa.EtapaId,
                            DataInicio = group.Min(t => t.DataInicio),
                            DataPrevisaoFim = latestTarefa.DataPrevisaoFim,
                            DataMedicao = latestTarefa.DataMedicao,
                            DataFim = latestTarefa.DataFim,
                            QuantidadeConstruida = (float)totalQuantidadeConstruida,
                            QuantidadePrevisao = (decimal)avgQuantidadePrevisao,
                            Status = latestTarefa.Status,
                            Etapa = latestTarefa.Etapa,
                            ColaboradorInsercaoId = latestTarefa.ColaboradorInsercaoId,
                            DataInsercao = latestTarefa.DataInsercao,
                            DataUltimaAtualizacao = latestTarefa.DataUltimaAtualizacao,
                            Comentario = latestTarefa.Comentario,
                            Foto = latestTarefa.Foto,
                            HorasTrabalhadas = group.Sum(t => t.HorasTrabalhadas ?? 0),
                            HoraMedicaoInicial = group.Min(t => t.HoraMedicaoInicial),
                            HoraMedicaoFinal = group.Max(t => t.HoraMedicaoFinal),
                            ValorUnitario = latestTarefa.ValorUnitario,
                            UnidadeId = latestTarefa.UnidadeId,
                            CodigoParalizacao = latestTarefa.CodigoParalizacao,
                            
                            // Water quality fields - use latest values
                            NivelCloro = latestTarefa.NivelCloro,
                            Ph = latestTarefa.Ph,
                            Alcalinidade = latestTarefa.Alcalinidade,
                            Limpidez = latestTarefa.Limpidez,
                            Superficie = latestTarefa.Superficie,
                            Fundo = latestTarefa.Fundo,
                            NivelDetritos = latestTarefa.NivelDetritos,
                            NivelProliferacao = latestTarefa.NivelProliferacao
                        };
                    })
                    .ToList();
                
                var result = new EtapaViewModel
                {
                    Id = etapa.Id,
                    Descricao = etapa.Descricao ?? $"Etapa {etapa.Id}",
                    ObraId = etapa.ObraId,
                    TotalTarefas = groupedTarefas.Count,
                    TarefasConcluidas = groupedTarefas.Count(t => t.StatusId == 3),
                    TarefasEmAndamento = groupedTarefas.Count(t => t.StatusId == 2),
                    TarefasPlanejadas = groupedTarefas.Count(t => t.StatusId == 1),
                    TarefasParalisadas = groupedTarefas.Count(t => t.StatusId == 4),
                    PercentualConclusao = groupedTarefas.Count > 0 
                        ? (double)groupedTarefas.Count(t => t.StatusId == 3) / groupedTarefas.Count * 100 
                        : 0,
                    Tarefas = groupedTarefas.Select(MapTarefaToViewModel).ToList()
                };
                
                _logger.LogInformation("Loaded etapa {EtapaId} with {TaskCount} grouped tasks", etapaId, result.TotalTarefas);
                return result;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error loading etapa {EtapaId}", etapaId);
                throw;
            }
        }
        
        /// <summary>
        /// Maps a Tarefa entity to TarefaViewModel
        /// </summary>
        private TarefaViewModel MapTarefaToViewModel(Models.Entities.Tarefa tarefa)
        {
            return new TarefaViewModel
            {
                Id = tarefa.Id,
                Agrupador = tarefa.Agrupador,
                Descricao = tarefa.Descricao ?? $"Tarefa {tarefa.Id}",
                DataInicio = tarefa.DataInicio,
                DataPrevisaoFim = tarefa.DataPrevisaoFim,
                DataMedicao = tarefa.DataMedicao,
                DataFim = tarefa.DataFim,
                StatusId = tarefa.StatusId,
                StatusDescricao = tarefa.Status?.Descricao ?? "Status Desconhecido",
                StatusCssClass = GetStatusCssClass(tarefa.StatusId),
                StatusIcon = GetStatusIcon(tarefa.StatusId),
                QuantidadeConstruida = tarefa.QuantidadeConstruida,
                QuantidadePrevisao = tarefa.QuantidadePrevisao,
                PercentualConclusao = CalculatePercentualConclusao(tarefa),
                QuantidadeColaboradores = GetQuantidadeColaboradores(tarefa.Id),
                QuantidadeEquipamentos = GetQuantidadeEquipamentos(tarefa.Id),
                HorasTrabalhadas = tarefa.HorasTrabalhadas,
                HoraMedicaoInicial = tarefa.HoraMedicaoInicial,
                HoraMedicaoFinal = tarefa.HoraMedicaoFinal,
                
                // Water quality fields
                NivelCloro = tarefa.NivelCloro,
                Ph = tarefa.Ph,
                Alcalinidade = tarefa.Alcalinidade,
                Limpidez = tarefa.Limpidez,
                Superficie = tarefa.Superficie,
                Fundo = tarefa.Fundo,
                NivelDetritos = tarefa.NivelDetritos,
                NivelProliferacao = tarefa.NivelProliferacao,
                
                // Permission flags - TODO: Implement based on user permissions
                PodeEditar = true,
                PodeExcluir = true,
                PodeIniciar = tarefa.StatusId == 1,
                PodeFinalizar = tarefa.StatusId == 2,
                PodePausar = tarefa.StatusId == 2,
                PodeAdicionarMedicao = tarefa.StatusId != 3,
                
                // Additional fields
                Comentario = tarefa.Comentario,
                Foto = tarefa.Foto,
                CodigoParalizacao = tarefa.CodigoParalizacao,
                ColaboradorInsercaoId = tarefa.ColaboradorInsercaoId,
                DataInsercao = tarefa.DataInsercao,
                DataUltimaAtualizacao = tarefa.DataUltimaAtualizacao
            };
        }
        
        /// <summary>
        /// Gets CSS class for status
        /// </summary>
        private string GetStatusCssClass(int statusId)
        {
            return statusId switch
            {
                1 => "bg-secondary",    // Planejada - Gray
                2 => "bg-primary",      // Em Execução - Blue  
                3 => "bg-success",      // Finalizada - Green
                4 => "bg-warning",      // Pausada - Yellow/Orange
                5 => "bg-danger",       // Cancelada - Red
                _ => "bg-secondary"
            };
        }
        
        /// <summary>
        /// Gets icon class for status
        /// </summary>
        private string GetStatusIcon(int statusId)
        {
            return statusId switch
            {
                1 => "fas fa-clock",        // Planejada - Clock icon
                2 => "fas fa-play",         // Em Execução - Play icon
                3 => "fas fa-check",        // Finalizada - Check/Victory icon
                4 => "fas fa-hand-paper",   // Pausada - Hand/Stop icon
                5 => "fas fa-times",        // Cancelada - X icon
                _ => "fas fa-question"      // Unknown - Question icon
            };
        }
        
        /// <summary>
        /// Calculates completion percentage for a task
        /// </summary>
        private double CalculatePercentualConclusao(Models.Entities.Tarefa tarefa)
        {
            if (tarefa.StatusId == 3) // Finalizada
                return 100.0;
                
            if (tarefa.QuantidadePrevisao.HasValue && tarefa.QuantidadePrevisao.Value > 0 && tarefa.QuantidadeConstruida.HasValue)
            {
                // Fix type mismatch: Convert float to decimal for division
                var construida = (decimal)tarefa.QuantidadeConstruida.Value;
                var previsao = tarefa.QuantidadePrevisao.Value;
                return Math.Min(100.0, (double)(construida / previsao * 100));
            }
            
            // Default percentage based on status
            return tarefa.StatusId switch
            {
                1 => 0.0,   // Planejada
                2 => 50.0,  // Em Execução
                4 => 25.0,  // Pausada
                _ => 0.0
            };
        }
        
        /// <summary>
        /// Gets quantity of colaboradores for a task
        /// TODO: Implement proper query to related tables
        /// </summary>
        private int GetQuantidadeColaboradores(int tarefaId)
        {
            try
            {
                // For now, return a default value
                // TODO: Query ObraTarefaColaborador table
                return 2; // Mock value
            }
            catch
            {
                return 0;
            }
        }
        
        /// <summary>
        /// Gets quantity of equipamentos for a task
        /// TODO: Implement proper query to related tables
        /// </summary>
        private int GetQuantidadeEquipamentos(int tarefaId)
        {
            try
            {
                // For now, return a default value
                // TODO: Query ObraTarefaEquipamento table
                return 1; // Mock value
            }
            catch
            {
                return 0;
            }
        }
    }
}