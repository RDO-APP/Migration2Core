namespace RdoApp.Core.Models.DTOs
{
    public class ColaboradorDto
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string? Cpf { get; set; }
        public DateTime? DataNascimento { get; set; }
        public DateTime DataInsercao { get; set; }
        public DateTime? DataUltimaAtualizacao { get; set; }
    }

    public class CreateColaboradorDto
    {
        public string Nome { get; set; } = string.Empty;
        public string? Cpf { get; set; }
        public DateTime? DataNascimento { get; set; }
    }

    public class UpdateColaboradorDto
    {
        public string Nome { get; set; } = string.Empty;
        public string? Cpf { get; set; }
        public DateTime? DataNascimento { get; set; }
    }

    public class ColaboradorFilterDto
    {
        public string? Nome { get; set; }
        public string? Cpf { get; set; }
        public int? ObraId { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}