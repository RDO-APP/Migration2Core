using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.DTOs
{
    public class UsuarioDto
    {
        public int Id { get; set; }
        
        [Required]
        [StringLength(255)]
        public string Nome { get; set; } = string.Empty;
        
        [Required]
        [StringLength(14)]
        public string Cpf { get; set; } = string.Empty;
        
        [StringLength(255)]
        public string? Email { get; set; }
        
        [StringLength(20)]
        public string? Telefone { get; set; }
        
        public bool Ativo { get; set; } = true;
    }
}