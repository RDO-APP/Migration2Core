namespace RdoApp.Core.Services.Interfaces
{
    /// <summary>
    /// Service for managing RDO theme configuration
    /// </summary>
    public interface IThemeConfigurationService
    {
        /// <summary>
        /// Gets the current theme configuration
        /// </summary>
        /// <returns>Current theme configuration</returns>
        Task<ThemeConfiguration> GetCurrentThemeAsync();
        
        /// <summary>
        /// Sets the theme type
        /// </summary>
        /// <param name="themeType">The theme type to set</param>
        Task SetThemeAsync(ThemeType themeType);
        
        /// <summary>
        /// Gets CSS variables for the current theme
        /// </summary>
        /// <returns>Dictionary of CSS variable names and values</returns>
        Task<Dictionary<string, string>> GetCssVariablesAsync();
        
        /// <summary>
        /// Validates theme integrity
        /// </summary>
        Task ValidateThemeIntegrityAsync();
        
        /// <summary>
        /// Gets theme configuration by type
        /// </summary>
        /// <param name="themeType">The theme type</param>
        /// <returns>Theme configuration</returns>
        Task<ThemeConfiguration> GetThemeByTypeAsync(ThemeType themeType);
        
        /// <summary>
        /// Checks if a theme type is supported
        /// </summary>
        /// <param name="themeType">The theme type to check</param>
        /// <returns>True if supported, false otherwise</returns>
        bool IsThemeSupported(ThemeType themeType);
    }

    /// <summary>
    /// Theme configuration model
    /// </summary>
    public class ThemeConfiguration
    {
        public ThemeType Type { get; set; }
        public Dictionary<string, string> CssVariables { get; set; } = new();
        public bool IsDarkTheme { get; set; }
        public string PrimaryColor { get; set; } = string.Empty;
        public string SecondaryColor { get; set; } = string.Empty;
        public string TextColor { get; set; } = string.Empty;
        public string Name { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public bool IsDefault { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    /// <summary>
    /// Available theme types
    /// </summary>
    public enum ThemeType
    {
        Professional = 1,  // Dark blue theme (RDO Soul)
        Light = 2,         // White theme (fallback)
        HighContrast = 3   // Accessibility theme
    }
}