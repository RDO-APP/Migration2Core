using RdoApp.Core.Models.DTOs;

namespace RdoApp.Core.Services.Interfaces
{
    /// <summary>
    /// Service for handling navigation in the RDO application
    /// </summary>
    public interface INavigationService
    {
        /// <summary>
        /// Navigates to the specified action button destination
        /// </summary>
        /// <param name="buttonType">The action button type</param>
        /// <returns>Navigation result</returns>
        Task<NavigationResult> NavigateToAsync(ActionButtonType buttonType);
        
        /// <summary>
        /// Checks if the user can navigate to the specified destination
        /// </summary>
        /// <param name="buttonType">The action button type</param>
        /// <param name="userRole">The user's role</param>
        /// <returns>True if navigation is allowed, false otherwise</returns>
        Task<bool> CanNavigateToAsync(ActionButtonType buttonType, string? userRole);
        
        /// <summary>
        /// Gets the navigation URL for the specified action button
        /// </summary>
        /// <param name="buttonType">The action button type</param>
        /// <returns>The navigation URL</returns>
        Task<string> GetNavigationUrlAsync(ActionButtonType buttonType);
        
        /// <summary>
        /// Registers a custom navigation handler for an action button type
        /// </summary>
        /// <param name="buttonType">The action button type</param>
        /// <param name="handler">The navigation handler</param>
        void RegisterNavigationHandler(ActionButtonType buttonType, Func<Task> handler);
        
        /// <summary>
        /// Validates that a route exists and is accessible
        /// </summary>
        /// <param name="route">The route to validate</param>
        /// <returns>True if route is valid, false otherwise</returns>
        Task<bool> ValidateRouteAsync(string route);
        
        /// <summary>
        /// Gets the display name for an action button type
        /// </summary>
        /// <param name="buttonType">The action button type</param>
        /// <returns>The display name</returns>
        string GetButtonDisplayName(ActionButtonType buttonType);
    }

    /// <summary>
    /// Result of a navigation operation
    /// </summary>
    public class NavigationResult
    {
        public bool Success { get; set; }
        public string? ErrorMessage { get; set; }
        public string? NavigationUrl { get; set; }
        public bool RequiresPermission { get; set; }
        public bool HasPermission { get; set; }
        
        public static NavigationResult Successful(string navigationUrl)
        {
            return new NavigationResult
            {
                Success = true,
                NavigationUrl = navigationUrl,
                HasPermission = true
            };
        }
        
        public static NavigationResult Failed(string errorMessage)
        {
            return new NavigationResult
            {
                Success = false,
                ErrorMessage = errorMessage
            };
        }
        
        public static NavigationResult Unauthorized(string buttonDisplayName)
        {
            return new NavigationResult
            {
                Success = false,
                ErrorMessage = $"Você não tem permissão para acessar {buttonDisplayName}",
                RequiresPermission = true,
                HasPermission = false
            };
        }
    }
}