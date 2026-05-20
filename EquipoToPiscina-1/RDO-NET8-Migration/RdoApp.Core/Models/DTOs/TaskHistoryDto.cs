using System;

namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Task History DTO - For measurement history display
    /// Used in history modal and task card details
    /// </summary>
    public class TaskHistoryDto
    {
        public int Id { get; set; }
        public DateTime Data { get; set; }
        public TimeSpan? HoraInicial { get; set; }
        public TimeSpan? HoraFinal { get; set; }
        public string Status { get; set; } = string.Empty;
        public string Cloro { get; set; } = string.Empty;
        public string PH { get; set; } = string.Empty;
        public string Alcalinidade { get; set; } = string.Empty;
        public string Limpidez { get; set; } = string.Empty;
        public string Flutuantes { get; set; } = string.Empty;
        public string Areia { get; set; } = string.Empty;
        public string Detritos { get; set; } = string.Empty; // Display label for Bacteria field
        public string Algas { get; set; } = string.Empty;
        public bool CanEdit { get; set; }
        public bool CanPrint { get; set; }
    }
}