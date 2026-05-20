using RdoApp.Core.Models.DTOs;

namespace RdoApp.Core.Services.Interfaces
{
    public interface IAuthService
    {
        Task<LoginResultDto> LoginAsync(LoginDto loginDto);
        Task<UsuarioDto?> GetUsuarioByIdAsync(int id);
        Task<UsuarioDto?> GetUsuarioByCpfAsync(string cpf);
        bool ValidarCpf(string cpf);
        string FormatarCpf(string cpf);
    }
}