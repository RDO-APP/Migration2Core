using RdoApp.Core.Models.DTOs;
using RdoApp.Core.Models.Entities;
using RdoApp.Core.Models.ViewModels;
using RdoApp.Core.Models.Requests;

namespace RdoApp.Core.Services.Interfaces
{
    public interface ITarefaService
    {
        // Existing methods
        Task<IEnumerable<TarefaDto>> GetAllAsync();
        Task<TarefaDto?> GetByIdAsync(int id);
        Task<IEnumerable<TarefaDto>> GetByObraIdAsync(int obraId);
        Task<IEnumerable<TarefaDto>> GetByStatusAsync(int statusId);
        Task<PagedResult<TarefaDto>> GetPagedAsync(TarefaFilterDto filter);
        Task<TarefaDto> CreateAsync(CreateTarefaDto createDto);
        Task<TarefaDto> UpdateAsync(int id, UpdateTarefaDto updateDto);
        Task<bool> DeleteAsync(int id);
        Task<IEnumerable<TarefaHistoricoDto>> GetHistoricoAsync(int tarefaId);

        // NEW: Task Card functionality methods
        Task<TaskCardResponseDto> GetTaskCardsAsync(int obraId, TaskCardFilterDto filter);
        Task<bool> UpdateTaskStatusAsync(int tarefaId, int statusId, int userId);
        Task<List<TaskHistoryDto>> GetTaskHistoryAsync(int tarefaId);
        Task<bool> BulkUpdateStatusAsync(int[] tarefaIds, int statusId, int userId);
        Task<List<StatusTarefaDto>> GetAllowedStatusTransitionsAsync(int currentStatusId);
        
        // NEW: Water quality methods
        Task<WaterQualityParametersDto> GetWaterQualityParametersAsync(int tarefaId);
        Task<bool> SaveWaterQualityMeasurementAsync(int tarefaId, WaterQualityParametersDto parameters, int userId);
        Task<List<WaterQualityDropdownDto>> GetCloroOptionsAsync();
        Task<List<WaterQualityDropdownDto>> GetPHOptionsAsync();
        Task<List<WaterQualityDropdownDto>> GetAlcalinidadeOptionsAsync();

        // NEW: Business logic helper methods
        int CalcularPercentualConcluido(Tarefa tarefa);
        string DeterminarClasseStatusCss(int statusId);
        
        // PRODUCTION REALITY: Nova Medição Integration
        Task<NovaMedicaoResult> SalvarMedicaoAsync(NovaMedicaoViewModel model);
    }
}