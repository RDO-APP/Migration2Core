using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs
{
    public class LoginDto
    {
        [Required(ErrorMessage = "CPF é obrigatório")]
        [Display(Name = "CPF")]
        public string Cpf { get; set; } = string.Empty;

        [Required(ErrorMessage = "Senha é obrigatória")]
        [DataType(DataType.Password)]
        [Display(Name = "Senha")]
        public string Senha { get; set; } = string.Empty;

        [Display(Name = "Lembrar-me")]
        public bool LembrarMe { get; set; } = false;
    }
}