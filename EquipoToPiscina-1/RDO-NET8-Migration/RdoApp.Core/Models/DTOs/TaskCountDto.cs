namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// DTO for fast task count queries (used in lazy loading pattern)
    /// Provides task statistics without loading full task objects
    /// </summary>
    public class TaskCountDto
    {
        public int Total { get; set; }
        public int Concluidas { get; set; }
        public int EmAndamento { get; set; }
        public int Planejadas { get; set; }
        public int Paralisadas { get; set; }
    }
}