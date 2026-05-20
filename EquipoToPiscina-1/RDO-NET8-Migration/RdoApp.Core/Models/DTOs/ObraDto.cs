namespace RdoApp.Core.Models.DTOs
{
    public class ObraDto
    {
        public int Id { get; set; }
        public string Descricao { get; set; } = string.Empty;
        public DateTime? DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
        public DateTime DataInsercao { get; set; }
        public DateTime? DataUltimaAtualizacao { get; set; }
    }

    public class CreateObraDto
    {
        public string Descricao { get; set; } = string.Empty;
        public DateTime? DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
    }

    public class UpdateObraDto
    {
        public string Descricao { get; set; } = string.Empty;
        public DateTime? DataInicio { get; set; }
        public DateTime? DataPrevisaoFim { get; set; }
    }

    public class ObraFilterDto
    {
        public string? Descricao { get; set; }
        public DateTime? DataInicioFrom { get; set; }
        public DateTime? DataInicioTo { get; set; }
        public DateTime? DataPrevisaoFimFrom { get; set; }
        public DateTime? DataPrevisaoFimTo { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
    }
}