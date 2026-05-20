using RdoApp.Core.Models.DTOs;

namespace RdoApp.Core.Services.Interfaces
{
    public interface IRdoService
    {
        Task<IEnumerable<RdoDto>> GetAllAsync();
        Task<RdoDto?> GetByIdAsync(int id);
        Task<IEnumerable<RdoDto>> GetByObraIdAsync(int obraId);
        Task<IEnumerable<RdoDto>> GetByDateRangeAsync(DateTime startDate, DateTime endDate);
        Task<RdoDto> CreateAsync(CreateRdoDto createDto);
        Task<RdoDto?> UpdateAsync(int id, UpdateRdoDto updateDto);
        Task<bool> DeleteAsync(int id);
        Task<bool> ExistsAsync(int obraId, DateTime data);
    }
}