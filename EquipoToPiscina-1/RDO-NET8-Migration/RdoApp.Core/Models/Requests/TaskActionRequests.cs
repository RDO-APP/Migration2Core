using System.ComponentModel.DataAnnotations;

namespace RdoApp.Core.Models.Requests
{
    /// <summary>
    /// Base class for all task action requests in Pure Blazor communication
    /// </summary>
    public abstract class TaskActionRequest
    {
        [Required]
        public int TaskId { get; set; }
        
        public string TaskDescription { get; set; } = "";
    }

    /// <summary>
    /// Request for viewing task details - Pure Blazor EventCallback
    /// </summary>
    public class ViewTaskRequest : TaskActionRequest
    {
    }

    /// <summary>
    /// Request for showing task history - Pure Blazor EventCallback
    /// </summary>
    public class HistoryTaskRequest : TaskActionRequest
    {
    }

    /// <summary>
    /// Request for deleting a task - Pure Blazor EventCallback
    /// </summary>
    public class DeleteTaskRequest : TaskActionRequest
    {
        public bool ConfirmDelete { get; set; } = false;
    }

    /// <summary>
    /// Request for editing a task - Pure Blazor EventCallback
    /// </summary>
    public class EditTaskRequest : TaskActionRequest
    {
    }

    /// <summary>
    /// Request for adding new measurement - Pure Blazor EventCallback
    /// Replaces all JavaScript modal triggers with type-safe C# communication
    /// </summary>
    public class NovaMedicaoRequest : TaskActionRequest
    {
        [Required]
        public int CurrentStatus { get; set; }
        
        public DateTime DefaultDate { get; set; } = DateTime.Today;
        
        public bool IsUrgent { get; set; } = false;
    }
}