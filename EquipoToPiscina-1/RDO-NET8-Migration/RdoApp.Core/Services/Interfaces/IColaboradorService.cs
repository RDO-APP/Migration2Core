using RdoApp.Core.Models.DTOs;

namespace RdoApp.Core.Services.Interfaces
{
    public interface IColaboradorService
    {
        Task<IEnumerable<ColaboradorDto>> GetAllAsync();
        Task<ColaboradorDto?> GetByIdAsync(int id);
        Task<IEnumerable<ColaboradorDto>> GetByObraIdAsync(int obraId);
        Task<PagedResult<ColaboradorDto>> GetPagedAsync(ColaboradorFilterDto filter);
        Task<ColaboradorDto> CreateAsync(CreateColaboradorDto createDto);
        Task<ColaboradorDto> UpdateAsync(int id, UpdateColaboradorDto updateDto);
        Task<bool> DeleteAsync(int id);
        Task<bool> ValidateCpfAsync(string cpf, int? excludeId = null);
    }
}