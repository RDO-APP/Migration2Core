using System;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Etapa DTO - For stage/phase management
    /// Used in dropdown selections and stage operations
    /// </summary>
    public class EtapaDto
    {
        public int Id { get; set; }
        public string Titulo { get; set; } = string.Empty;
        public string Descricao { get; set; } = string.Empty;
        public int ObraId { get; set; }
        public DateTime DataInicio { get; set; }
        public DateTime DataPrevisaoFim { get; set; }
        public DateTime? DataFim { get; set; }
        public int StatusId { get; set; }
        public int ColaboradorInsercaoId { get; set; }
        public DateTime DataInsercao { get; set; }
        public DateTime? DataUltimaAtualizacao { get; set; }
    }
}