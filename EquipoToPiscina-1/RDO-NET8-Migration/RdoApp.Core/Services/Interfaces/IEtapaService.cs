using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Services.Interfaces
{
    /// <summary>
    /// Service interface for Etapa operations
    /// Provides data access for the Razor Cards view
    /// </summary>
    public interface IEtapaService
    {
        /// <summary>
        /// Get etapas with tarefas for the cards view
        /// </summary>
        /// <param name="filter">Filter parameters</param>
        /// <returns>List of etapas with their tarefas</returns>
        Task<List<EtapaViewModel>> GetEtapasWithTarefasAsync(EtapaFilterViewModel filter);
        
        /// <summary>
        /// Get status options for filtering
        /// </summary>
        /// <returns>List of available status options</returns>
        Task<List<StatusOption>> GetStatusOptionsAsync();
        
        /// <summary>
        /// Get etapa options for filtering
        /// </summary>
        /// <param name="obraId">Obra ID</param>
        /// <returns>List of available etapa options</returns>
        Task<List<EtapaOption>> GetEtapaOptionsAsync(int obraId);
        
        /// <summary>
        /// Get etapas as ViewModels for obra selection
        /// </summary>
        /// <param name="obraId">Obra ID</param>
        /// <param name="filter">Optional filter parameters</param>
        /// <returns>List of etapa ViewModels</returns>
        Task<List<EtapaViewModel>> ObterEtapasViewModelAsync(int obraId, EtapaFilterViewModel? filter = null);
        
        /// <summary>
        /// Get etapa by ID
        /// </summary>
        /// <param name="etapaId">Etapa ID</param>
        /// <param name="colaboradorId">Colaborador ID for permissions (optional)</param>
        /// <returns>Etapa ViewModel</returns>
        Task<EtapaViewModel?> ObterEtapaPorIdAsync(int etapaId, int colaboradorId = 1);
    }
}