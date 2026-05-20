using RdoApp.Core.Models.ViewModels;

namespace RdoApp.Core.Services.Interfaces
{
    public interface IObraService
    {
        Task<List<ObraViewModel>> ObterObrasAsync(int colaboradorId);
        Task<List<object>> ObterEtapasAsync(int obraId);
        Task<ObraViewModel?> ObterObraPorIdAsync(int obraId);
    }
}