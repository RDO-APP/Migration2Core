namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Bulk Status Update DTO - For mass status change operations
    /// Used when user selects multiple tasks and changes their status at once
    /// </summary>
    public class BulkStatusUpdateDto
    {
        public int[] TarefaIds { get; set; } = Array.Empty<int>();
        public int StatusId { get; set; }
        public string? Comentario { get; set; }
        public DateTime? DataExecucao { get; set; }
    }

    /// <summary>
    /// Update Status DTO - For individual task status updates
    /// Used when changing status of a single task
    /// </summary>
    public class UpdateStatusDto
    {
        public int StatusId { get; set; }
        public string? Comentario { get; set; }
        public DateTime? DataExecucao { get; set; }
        
        // Simplified pause workflow - no pause code required
        // Original had CodigoParalisacao field, removed per business rule change
    }
}