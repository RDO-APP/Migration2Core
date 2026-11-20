using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs;

public sealed class MobileLoginRequestDto
{
    [Required]
    public string Cpf { get; set; } = "";

    [Required]
    public string Senha { get; set; } = "";
}

public sealed class MobileLoginResponseDto
{
    public string AccessToken { get; set; } = "";
    public int ExpiresIn { get; set; }
    public string TokenType { get; set; } = "Bearer";
    public MobileColaboradorDto Colaborador { get; set; } = new();
}

public sealed class MobileColaboradorDto
{
    public int Id { get; set; }
    public string Nome { get; set; } = "";
    public string Cpf { get; set; } = "";
    public string? Email { get; set; }
}

public sealed class MobileMeResponseDto
{
    public string? Id { get; set; }
    public string? Nome { get; set; }
    public string? Cpf { get; set; }
    public string? Email { get; set; }
    public string? IsAdmin { get; set; }
}
