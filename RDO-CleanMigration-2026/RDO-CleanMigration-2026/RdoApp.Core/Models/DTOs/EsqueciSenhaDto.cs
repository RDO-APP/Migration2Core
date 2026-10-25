using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs;

public class EsqueciSenhaDto
{
    [Required(ErrorMessage = "E-mail é obrigatório")]
    [EmailAddress(ErrorMessage = "E-mail inválido")]
    [Display(Name = "E-mail cadastrado")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "CPF é obrigatório")]
    [Display(Name = "CPF")]
    public string Cpf { get; set; } = string.Empty;
}
