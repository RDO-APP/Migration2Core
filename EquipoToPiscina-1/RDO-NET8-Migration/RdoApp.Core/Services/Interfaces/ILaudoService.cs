using RdoApp.Core.Models.DTOs;

namespace RdoApp.Core.Services.Interfaces
{
    public interface ILaudoService
    {
        Task<IEnumerable<LaudoDto>> GetAllAsync();
        Task<LaudoDto?> GetByIdAsync(int id);
        Task<IEnumerable<LaudoDto>> GetByObraIdAsync(int obraId);
        Task<IEnumerable<LaudoDto>> GetByStatusIdAsync(int statusId);
        Task<IEnumerable<LaudoDto>> GetByDateRangeAsync(DateTime dataInicial, DateTime dataFinal);
        Task<LaudoDto> CreateAsync(CreateLaudoDto createDto);
        Task<LaudoDto?> UpdateAsync(int id, UpdateLaudoDto updateDto);
        Task<bool> DeleteAsync(int id);
        Task<bool> ExistsAsync(int obraId, DateTime dataLaudo);
    }
}