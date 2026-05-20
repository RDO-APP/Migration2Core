using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// Clean State Result Model for Nova Medição Operations
    /// Modern .NET 8 implementation without legacy technical baggage
    /// </summary>
    public class NovaMedicaoResult
    {
        /// <summary>
        /// Indicates if the operation was successful
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// User-friendly message for UI feedback
        /// </summary>
        [MaxLength(500)]
        public string? Message { get; set; }

        /// <summary>
        /// Indicates if the UI should refresh data after this operation
        /// </summary>
        public bool RefreshRequired { get; set; }

        /// <summary>
        /// Optional: Updated task ID if a new task was created
        /// </summary>
        public int? UpdatedTaskId { get; set; }

        /// <summary>
        /// Optional: New status ID after the measurement update
        /// </summary>
        public int? NewStatusId { get; set; }

        /// <summary>
        /// Optional: Validation errors for form fields
        /// </summary>
        public Dictionary<string, string>? ValidationErrors { get; set; }

        /// <summary>
        /// Create a successful result
        /// </summary>
        public static NovaMedicaoResult CreateSuccess(string message = "Medição salva com sucesso!", bool refreshRequired = true)
        {
            return new NovaMedicaoResult
            {
                Success = true,
                Message = message,
                RefreshRequired = refreshRequired
            };
        }

        /// <summary>
        /// Create an error result
        /// </summary>
        public static NovaMedicaoResult CreateError(string message, Dictionary<string, string>? validationErrors = null)
        {
            return new NovaMedicaoResult
            {
                Success = false,
                Message = message,
                RefreshRequired = false,
                ValidationErrors = validationErrors
            };
        }

        /// <summary>
        /// Create a validation error result
        /// </summary>
        public static NovaMedicaoResult CreateValidationError(Dictionary<string, string> validationErrors)
        {
            return new NovaMedicaoResult
            {
                Success = false,
                Message = "Erro de validação. Verifique os campos destacados.",
                RefreshRequired = false,
                ValidationErrors = validationErrors
            };
        }
    }
}