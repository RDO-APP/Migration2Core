namespace RdoApp.Core.Models.DTOs
{
    public class LoginResultDto
    {
        public bool Sucesso { get; set; }
        public string Mensagem { get; set; } = string.Empty;
        public UsuarioDto? Usuario { get; set; }
    }
}