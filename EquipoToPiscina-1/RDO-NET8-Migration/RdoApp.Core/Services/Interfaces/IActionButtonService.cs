using RdoApp.Core.Models.DTOs;

namespace RdoApp.Core.Services.Interfaces
{
    /// <summary>
    /// Service for managing RDO header action buttons
    /// </summary>
    public interface IActionButtonService
    {
        /// <summary>
        /// Gets all action buttons for the current user
        /// </summary>
        /// <returns>List of action buttons</returns>
        Task<List<ActionButtonDto>> GetActionButtonsAsync();
        
        /// <summary>
        /// Gets a specific action button by type
        /// </summary>
        /// <param name="type">The action button type</param>
        /// <returns>The action button or null if not found</returns>
        Task<ActionButtonDto?> GetActionButtonByTypeAsync(ActionButtonType type);
        
        /// <summary>
        /// Checks if an action button is visible for the current user
        /// </summary>
        /// <param name="type">The action button type</param>
        /// <param name="userRole">The user's role</param>
        /// <returns>True if visible, false otherwise</returns>
        Task<bool> IsActionButtonVisibleAsync(ActionButtonType type, string? userRole);
        
        /// <summary>
        /// Gets the navigation URL for an action button
        /// </summary>
        /// <param name="type">The action button type</param>
        /// <returns>The navigation URL</returns>
        Task<string> GetNavigationUrlAsync(ActionButtonType type);
        
        /// <summary>
        /// Gets all visible action buttons for a specific user role
        /// </summary>
        /// <param name="userRole">The user's role</param>
        /// <returns>List of visible action buttons</returns>
        Task<List<ActionButtonDto>> GetVisibleActionButtonsAsync(string? userRole);
        
        /// <summary>
        /// Gets the 2 selection buttons for obra selection mode (World A)
        /// Based on legacy nav.html forensic analysis
        /// </summary>
        /// <returns>List of selection buttons (Dashboard + Add New)</returns>
        Task<List<ActionButtonDto>> GetSelectionButtonsAsync();
    }
}