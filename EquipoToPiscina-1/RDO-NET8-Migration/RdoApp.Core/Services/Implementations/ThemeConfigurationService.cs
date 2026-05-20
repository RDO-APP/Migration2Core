using RdoApp.Core.Services.Interfaces;

namespace RdoApp.Core.Services.Implementations
{
    /// <summary>
    /// Service implementation for managing RDO theme configuration
    /// </summary>
    public class ThemeConfigurationService : IThemeConfigurationService
    {
        private readonly ILogger<ThemeConfigurationService> _logger;
        private ThemeConfiguration? _currentTheme;

        /// <summary>
        /// RDO Color Palette Constants
        /// </summary>
        public static class RdoColorPalette
        {
            // Professional Dark Theme (Primary)
            public const string HeaderPrimary = "#27496F";
            public const string HeaderSecondary = "#1C334D";
            public const string HeaderDeep = "#244264";
            public const string HeaderAccent = "#0088DD";
            public const string HeaderText = "#ffffff";
            public const string HeaderTextMuted = "rgba(255, 255, 255, 0.75)";
            
            // Button Specifications
            public const int ButtonWidth = 48;
            public const int ButtonHeight = 49;
            public const int ButtonRadius = 200; // Perfect circles
            public const string ButtonSpacing = "0.25rem";
            
            // Light Theme Colors
            public const string LightPrimary = "#ffffff";
            public const string LightSecondary = "#f8f9fa";
            public const string LightText = "#2d3748";
            public const string LightBorder = "#e2e8f0";
            
            // High Contrast Theme Colors
            public const string HighContrastPrimary = "#000000";
            public const string HighContrastSecondary = "#ffffff";
            public const string HighContrastText = "#ffffff";
            public const string HighContrastBorder = "#ffffff";
        }

        /// <summary>
        /// CSS Variable Mappings for each theme
        /// </summary>
        public static class CssVariableMapping
        {
            public static readonly Dictionary<string, string> ProfessionalTheme = new()
            {
                ["--rdo-header-primary"] = RdoColorPalette.HeaderPrimary,
                ["--rdo-header-secondary"] = RdoColorPalette.HeaderSecondary,
                ["--rdo-header-deep"] = RdoColorPalette.HeaderDeep,
                ["--rdo-header-accent"] = RdoColorPalette.HeaderAccent,
                ["--rdo-header-text"] = RdoColorPalette.HeaderText,
                ["--rdo-header-text-muted"] = RdoColorPalette.HeaderTextMuted,
                ["--rdo-button-size"] = $"{RdoColorPalette.ButtonWidth}px",
                ["--rdo-button-height"] = $"{RdoColorPalette.ButtonHeight}px",
                ["--rdo-button-radius"] = $"{RdoColorPalette.ButtonRadius}px",
                ["--rdo-button-spacing"] = RdoColorPalette.ButtonSpacing
            };

            public static readonly Dictionary<string, string> LightTheme = new()
            {
                ["--rdo-header-primary"] = RdoColorPalette.LightPrimary,
                ["--rdo-header-secondary"] = RdoColorPalette.LightSecondary,
                ["--rdo-header-deep"] = RdoColorPalette.LightSecondary,
                ["--rdo-header-accent"] = "#3b82f6",
                ["--rdo-header-text"] = RdoColorPalette.LightText,
                ["--rdo-header-text-muted"] = "rgba(45, 55, 72, 0.75)",
                ["--rdo-button-size"] = $"{RdoColorPalette.ButtonWidth}px",
                ["--rdo-button-height"] = $"{RdoColorPalette.ButtonHeight}px",
                ["--rdo-button-radius"] = $"{RdoColorPalette.ButtonRadius}px",
                ["--rdo-button-spacing"] = RdoColorPalette.ButtonSpacing
            };

            public static readonly Dictionary<string, string> HighContrastTheme = new()
            {
                ["--rdo-header-primary"] = RdoColorPalette.HighContrastPrimary,
                ["--rdo-header-secondary"] = RdoColorPalette.HighContrastSecondary,
                ["--rdo-header-deep"] = RdoColorPalette.HighContrastPrimary,
                ["--rdo-header-accent"] = RdoColorPalette.HighContrastSecondary,
                ["--rdo-header-text"] = RdoColorPalette.HighContrastText,
                ["--rdo-header-text-muted"] = RdoColorPalette.HighContrastText,
                ["--rdo-button-size"] = $"{RdoColorPalette.ButtonWidth}px",
                ["--rdo-button-height"] = $"{RdoColorPalette.ButtonHeight}px",
                ["--rdo-button-radius"] = $"{RdoColorPalette.ButtonRadius}px",
                ["--rdo-button-spacing"] = RdoColorPalette.ButtonSpacing
            };
        }

        public ThemeConfigurationService(ILogger<ThemeConfigurationService> logger)
        {
            _logger = logger;
        }

        public async Task<ThemeConfiguration> GetCurrentThemeAsync()
        {
            try
            {
                if (_currentTheme == null)
                {
                    _logger.LogDebug("Loading default theme configuration");
                    _currentTheme = await GetThemeByTypeAsync(ThemeType.Professional);
                }

                await ValidateThemeIntegrityAsync();
                return _currentTheme;
            }
            catch (ThemeLoadException ex)
            {
                _logger.LogWarning(ex, "Failed to load theme configuration, using fallback");
                return GetFallbackTheme();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected error loading theme configuration");
                return GetFallbackTheme();
            }
        }

        public async Task SetThemeAsync(ThemeType themeType)
        {
            try
            {
                _logger.LogDebug("Setting theme to: {ThemeType}", themeType);

                if (!IsThemeSupported(themeType))
                {
                    throw new ArgumentException($"Theme type {themeType} is not supported");
                }

                _currentTheme = await GetThemeByTypeAsync(themeType);
                _currentTheme.UpdatedAt = DateTime.UtcNow;

                _logger.LogInformation("Theme successfully set to: {ThemeType}", themeType);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error setting theme to: {ThemeType}", themeType);
                throw;
            }
        }

        public async Task<Dictionary<string, string>> GetCssVariablesAsync()
        {
            try
            {
                var theme = await GetCurrentThemeAsync();
                return new Dictionary<string, string>(theme.CssVariables);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting CSS variables");
                return CssVariableMapping.ProfessionalTheme;
            }
        }

        public async Task ValidateThemeIntegrityAsync()
        {
            try
            {
                var theme = _currentTheme ?? await GetCurrentThemeAsync();
                
                // Validate required CSS variables exist
                var requiredVariables = new[]
                {
                    "--rdo-header-primary",
                    "--rdo-header-secondary",
                    "--rdo-header-text",
                    "--rdo-button-size",
                    "--rdo-button-height"
                };

                var missingVariables = requiredVariables
                    .Where(variable => !theme.CssVariables.ContainsKey(variable))
                    .ToList();

                if (missingVariables.Any())
                {
                    _logger.LogWarning("Theme integrity check failed. Missing variables: {MissingVariables}", 
                        string.Join(", ", missingVariables));
                    
                    throw new ThemeIntegrityException($"Missing required CSS variables: {string.Join(", ", missingVariables)}");
                }

                // Validate color values are valid hex colors or CSS functions
                foreach (var colorVariable in theme.CssVariables.Where(kv => kv.Key.Contains("color") || kv.Key.Contains("primary") || kv.Key.Contains("secondary")))
                {
                    if (!IsValidColorValue(colorVariable.Value))
                    {
                        _logger.LogWarning("Invalid color value for variable {Variable}: {Value}", 
                            colorVariable.Key, colorVariable.Value);
                    }
                }

                _logger.LogDebug("Theme integrity validation passed");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during theme integrity validation");
                throw;
            }
        }

        public async Task<ThemeConfiguration> GetThemeByTypeAsync(ThemeType themeType)
        {
            try
            {
                _logger.LogDebug("Getting theme configuration for type: {ThemeType}", themeType);

                var theme = themeType switch
                {
                    ThemeType.Professional => new ThemeConfiguration
                    {
                        Type = ThemeType.Professional,
                        Name = "RDO Professional",
                        Description = "Professional dark blue theme that defines RDO brand identity",
                        IsDarkTheme = true,
                        PrimaryColor = RdoColorPalette.HeaderPrimary,
                        SecondaryColor = RdoColorPalette.HeaderSecondary,
                        TextColor = RdoColorPalette.HeaderText,
                        CssVariables = CssVariableMapping.ProfessionalTheme,
                        IsDefault = true,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    },
                    ThemeType.Light => new ThemeConfiguration
                    {
                        Type = ThemeType.Light,
                        Name = "Light Theme",
                        Description = "Clean light theme for accessibility",
                        IsDarkTheme = false,
                        PrimaryColor = RdoColorPalette.LightPrimary,
                        SecondaryColor = RdoColorPalette.LightSecondary,
                        TextColor = RdoColorPalette.LightText,
                        CssVariables = CssVariableMapping.LightTheme,
                        IsDefault = false,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    },
                    ThemeType.HighContrast => new ThemeConfiguration
                    {
                        Type = ThemeType.HighContrast,
                        Name = "High Contrast",
                        Description = "High contrast theme for accessibility compliance",
                        IsDarkTheme = true,
                        PrimaryColor = RdoColorPalette.HighContrastPrimary,
                        SecondaryColor = RdoColorPalette.HighContrastSecondary,
                        TextColor = RdoColorPalette.HighContrastText,
                        CssVariables = CssVariableMapping.HighContrastTheme,
                        IsDefault = false,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow
                    },
                    _ => throw new ArgumentException($"Unsupported theme type: {themeType}")
                };

                _logger.LogDebug("Successfully created theme configuration for: {ThemeType}", themeType);
                return theme;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting theme by type: {ThemeType}", themeType);
                throw;
            }
        }

        public bool IsThemeSupported(ThemeType themeType)
        {
            return themeType switch
            {
                ThemeType.Professional => true,
                ThemeType.Light => true,
                ThemeType.HighContrast => true,
                _ => false
            };
        }

        /// <summary>
        /// Gets fallback theme when primary theme loading fails
        /// </summary>
        /// <returns>Fallback theme configuration</returns>
        private ThemeConfiguration GetFallbackTheme()
        {
            return new ThemeConfiguration
            {
                Type = ThemeType.Professional,
                Name = "RDO Professional (Fallback)",
                Description = "Fallback professional theme with hardcoded values",
                IsDarkTheme = true,
                PrimaryColor = "#27496F", // Hardcoded fallback
                SecondaryColor = "#1C334D",
                TextColor = "#ffffff",
                CssVariables = CssVariableMapping.ProfessionalTheme,
                IsDefault = true,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };
        }

        /// <summary>
        /// Validates if a color value is valid CSS color
        /// </summary>
        /// <param name="colorValue">The color value to validate</param>
        /// <returns>True if valid, false otherwise</returns>
        private bool IsValidColorValue(string colorValue)
        {
            if (string.IsNullOrEmpty(colorValue))
                return false;

            // Check for hex colors
            if (colorValue.StartsWith("#") && (colorValue.Length == 7 || colorValue.Length == 4))
            {
                return colorValue.Skip(1).All(c => char.IsDigit(c) || (c >= 'A' && c <= 'F') || (c >= 'a' && c <= 'f'));
            }

            // Check for CSS functions (rgb, rgba, hsl, etc.)
            if (colorValue.StartsWith("rgb") || colorValue.StartsWith("hsl") || colorValue.StartsWith("var("))
            {
                return true;
            }

            // Check for named colors (basic validation)
            var namedColors = new[] { "white", "black", "red", "green", "blue", "transparent" };
            return namedColors.Contains(colorValue.ToLower());
        }
    }

    /// <summary>
    /// Exception thrown when theme loading fails
    /// </summary>
    public class ThemeLoadException : Exception
    {
        public ThemeLoadException(string message) : base(message) { }
        public ThemeLoadException(string message, Exception innerException) : base(message, innerException) { }
    }

    /// <summary>
    /// Exception thrown when theme integrity validation fails
    /// </summary>
    public class ThemeIntegrityException : Exception
    {
        public ThemeIntegrityException(string message) : base(message) { }
        public ThemeIntegrityException(string message, Exception innerException) : base(message, innerException) { }
    }
}