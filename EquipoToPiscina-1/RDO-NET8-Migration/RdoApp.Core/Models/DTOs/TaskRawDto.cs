namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Raw DTO for hard-coded SQL queries to avoid ghost column issues
    /// Only contains columns we KNOW exist in the database
    /// </summary>
    public class TaskRawDto
    {
        public int Id { get; set; }
        public string? Descricao { get; set; }
        public int EtapaId { get; set; }
        public int StatusId { get; set; }
    }
}