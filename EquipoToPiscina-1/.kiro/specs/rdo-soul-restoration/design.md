# Design Document - RDO Soul Restoration

## Overview

The RDO Soul Restoration project aims to restore the professional dark blue theme and intelligent action toolbar that defines the RDO brand identity. This implementation will transform the current sterile white header into the signature professional appearance users expect, while maintaining modern Blazor architecture without any legacy technical debt.

The solution leverages CSS custom properties, modern Blazor patterns, and intelligent component design to achieve 100% visual parity with the legacy system while ensuring maintainability, performance, and future-proof architecture.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    RDO Soul Restoration                     │
├─────────────────────────────────────────────────────────────┤
│  CSS Theme Layer (Modern Variables)                        │
│  ├── Dark Theme Variables (:root)                          │
│  ├── Component-Specific Styling                            │
│  └── Responsive Breakpoints                                │
├─────────────────────────────────────────────────────────────┤
│  Blazor Component Layer                                     │
│  ├── Header Layout (_LayoutBlazor.cshtml)                  │
│  ├── Action Toolbar Component                              │
│  └── Context Indicator Component                           │
├─────────────────────────────────────────────────────────────┤
│  Service Layer (C# Backend)                                │
│  ├── ActionButtonService                                   │
│  ├── NavigationService                                     │
│  └── ThemeConfigurationService                             │
├─────────────────────────────────────────────────────────────┤
│  Data Models                                               │
│  ├── ActionButton Model                                    │
│  ├── ThemeConfiguration Model                              │
│  └── NavigationTarget Model                                │
└─────────────────────────────────────────────────────────────┘
```

### Design Principles

1. **Zero Legacy Debt**: No legacy CSS files or JavaScript dependencies
2. **Modern CSS Variables**: Centralized theme management using CSS custom properties
3. **Component Isolation**: Each UI element is self-contained and testable
4. **Responsive Design**: Mobile-first approach with progressive enhancement
5. **Accessibility First**: WCAG 2.1 AA compliance from the ground up
6. **Performance Optimized**: Minimal CSS footprint and efficient rendering

## Components and Interfaces

### 1. CSS Theme System

#### Primary Theme Variables
```css
:root {
    /* RDO Professional Dark Theme */
    --rdo-header-primary: #27496F;     /* Main header background */
    --rdo-header-secondary: #1C334D;   /* Hover states */
    --rdo-header-deep: #244264;        /* Deep sections */
    --rdo-header-accent: #0088DD;      /* Interactive elements */
    --rdo-header-text: #ffffff;        /* Text on dark */
    --rdo-header-text-muted: rgba(255, 255, 255, 0.75);
    
    /* Button System */
    --rdo-button-size: 48px;           /* Button width */
    --rdo-button-height: 49px;         /* Button height */
    --rdo-button-radius: 200px;        /* Perfect circles */
    --rdo-button-spacing: 0.25rem;     /* Button gaps */
}
```

#### Component-Specific Classes
```css
/* Header Dark Theme */
.navbar-dark-theme {
    background: var(--rdo-header-primary) !important;
    border-bottom: 1px solid var(--rdo-header-secondary);
    box-shadow: 0 2px 4px rgba(0,0,0,0.3);
}

/* Action Toolbar */
.action-toolbar-dark {
    gap: var(--rdo-button-spacing);
}

.toolbar-btn-dark {
    width: var(--rdo-button-size);
    height: var(--rdo-button-height);
    border-radius: var(--rdo-button-radius);
    background: transparent;
    color: var(--rdo-header-text);
    border: none;
}

.toolbar-btn-dark:hover {
    background-color: var(--rdo-header-secondary);
    color: var(--rdo-header-text);
}
```

### 2. ActionButton Service

#### Interface Definition
```csharp
public interface IActionButtonService
{
    Task<List<ActionButton>> GetActionButtonsAsync();
    Task<ActionButton> GetActionButtonByTypeAsync(ActionButtonType type);
    Task<bool> IsActionButtonVisibleAsync(ActionButtonType type, string userRole);
    Task<string> GetNavigationUrlAsync(ActionButtonType type);
}
```

#### ActionButton Model
```csharp
public class ActionButton
{
    public ActionButtonType Type { get; set; }
    public string IconClass { get; set; }
    public string TooltipText { get; set; }
    public string NavigationUrl { get; set; }
    public string OnClickFunction { get; set; }
    public bool RequiresPermission { get; set; }
    public string PermissionRoute { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsVisible { get; set; } = true;
}

public enum ActionButtonType
{
    Laudos = 1,
    DashboardUnidade = 2,
    RelatoriosDiarios = 3,
    Tarefas = 4,
    DashboardGeral = 5,
    NovaUnidade = 6
}
```

### 3. Navigation Service

#### Interface Definition
```csharp
public interface INavigationService
{
    Task NavigateToAsync(ActionButtonType buttonType);
    Task<bool> CanNavigateToAsync(ActionButtonType buttonType, string userRole);
    Task<string> GetNavigationUrlAsync(ActionButtonType buttonType);
    void RegisterNavigationHandler(ActionButtonType buttonType, Func<Task> handler);
}
```

### 4. Theme Configuration Service

#### Interface Definition
```csharp
public interface IThemeConfigurationService
{
    Task<ThemeConfiguration> GetCurrentThemeAsync();
    Task SetThemeAsync(ThemeType themeType);
    Task<Dictionary<string, string>> GetCssVariablesAsync();
    Task ValidateThemeIntegrityAsync();
}

public class ThemeConfiguration
{
    public ThemeType Type { get; set; }
    public Dictionary<string, string> CssVariables { get; set; }
    public bool IsDarkTheme { get; set; }
    public string PrimaryColor { get; set; }
    public string SecondaryColor { get; set; }
    public string TextColor { get; set; }
}

public enum ThemeType
{
    Professional = 1,  // Dark blue theme
    Light = 2,         // White theme (fallback)
    HighContrast = 3   // Accessibility theme
}
```

## Data Models

### ActionButton Configuration Data

The system will use a predefined configuration for the 6 action buttons based on the legacy analysis:

```csharp
public static class ActionButtonConfiguration
{
    public static readonly List<ActionButton> DefaultButtons = new()
    {
        new ActionButton
        {
            Type = ActionButtonType.Laudos,
            IconClass = "fa fa-folder",
            TooltipText = "Laudos",
            NavigationUrl = "/Laudo",
            OnClickFunction = "navigateToLaudos()",
            DisplayOrder = 1,
            RequiresPermission = false
        },
        new ActionButton
        {
            Type = ActionButtonType.DashboardUnidade,
            IconClass = "icon-dashboard",
            TooltipText = "Dashboard da Unidade Escolar",
            NavigationUrl = "/Dashboard/Index",
            OnClickFunction = "navigateToDashboardUnidade()",
            DisplayOrder = 2,
            RequiresPermission = true,
            PermissionRoute = "/dashboard/index"
        },
        new ActionButton
        {
            Type = ActionButtonType.RelatoriosDiarios,
            IconClass = "icon-rdo-novo_2",
            TooltipText = "Relatórios Diários",
            NavigationUrl = "/Relatorio",
            OnClickFunction = "navigateToRelatoriosDiarios()",
            DisplayOrder = 3,
            RequiresPermission = false
        },
        new ActionButton
        {
            Type = ActionButtonType.Tarefas,
            IconClass = "fa fa-th",
            TooltipText = "Tarefas",
            NavigationUrl = "/Tarefa/Cards",
            OnClickFunction = "navigateToTarefas()",
            DisplayOrder = 4,
            RequiresPermission = false
        },
        new ActionButton
        {
            Type = ActionButtonType.DashboardGeral,
            IconClass = "fa fa-bar-chart",
            TooltipText = "Dashboard Geral",
            NavigationUrl = "/Chart",
            OnClickFunction = "navigateToDashboardGeral()",
            DisplayOrder = 5,
            RequiresPermission = true,
            PermissionRoute = "/chart"
        },
        new ActionButton
        {
            Type = ActionButtonType.NovaUnidade,
            IconClass = "fa fa-plus",
            TooltipText = "Nova Unidade Escolar",
            NavigationUrl = "/Obra/Cadastro",
            OnClickFunction = "navigateToNovaUnidade()",
            DisplayOrder = 6,
            RequiresPermission = true,
            PermissionRoute = "/obra/cadastro"
        }
    };
}
```

### Theme Color Palette Data

```csharp
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
    
    // Responsive Breakpoints
    public const int MobileBreakpoint = 768;
    public const int TabletBreakpoint = 992;
    public const int DesktopBreakpoint = 1200;
}
```

### CSS Variable Mapping

```csharp
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
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Dark Theme Color Consistency
*For any* page load, all header elements (background, text, context indicator, dropdown) should display the correct professional dark theme colors: header background `#27496F`, text `#ffffff`, and maintain proper contrast ratios
**Validates: Requirements 1.1, 1.2, 1.4, 1.5**

### Property 2: Hover State Consistency
*For any* interactive element in the header (buttons, dropdown triggers), hovering should change the background to secondary dark blue `#1C334D` while maintaining white text/icons
**Validates: Requirements 1.3, 3.4**

### Property 3: Action Toolbar Structure
*For any* page load, the action toolbar should display exactly 6 buttons in the correct order with proper spacing between each button
**Validates: Requirements 2.1, 3.5**

### Property 4: Button Configuration Accuracy
*For any* action button, it should display the correct icon class and tooltip text according to its position: button 1 (fa fa-folder, "Laudos"), button 2 (icon-dashboard, "Dashboard da Unidade Escolar"), etc.
**Validates: Requirements 2.2, 2.3, 2.4, 2.5, 2.6, 2.7**

### Property 5: Button Visual Specifications
*For any* action button, it should be rendered as a perfect circle with dimensions 48px × 49px, border-radius 200px, transparent background, and white icons in normal state
**Validates: Requirements 3.1, 3.2, 3.3**

### Property 6: Modern Implementation Architecture
*For any* theme implementation, it should use CSS custom properties for all colors, avoid legacy CSS imports, use type-safe ActionButton models, and employ Blazor navigation patterns
**Validates: Requirements 4.1, 4.2, 4.3, 4.4**

### Property 7: Navigation Intelligence
*For any* action button click, it should navigate to the correct destination: Laudos → `/Laudo`, Dashboard Unidade → `/Dashboard/Index`, Relatórios → `/Relatorio`, Tarefas → `/Tarefa/Cards`, Dashboard Geral → `/Chart`, Nova Unidade → `/Obra/Cadastro`
**Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5, 5.6**

### Property 8: Visual Parity Achievement
*For any* comparison with the legacy system, the visual appearance should achieve 100% parity in colors, sizing, and styling while maintaining consistency across different device sizes
**Validates: Requirements 6.2, 6.3**

### Property 9: Responsive Design Consistency
*For any* viewport size, the dark theme should maintain proper responsive behavior, with appropriate element visibility and layout adjustments at mobile (≤768px), tablet (≤992px), and desktop (≥1200px) breakpoints
**Validates: Requirements 4.5, 6.3**

### Property 10: System Quality Assurance
*For any* build or deployment, the theme implementation should not impact loading performance, allow easy maintenance through CSS variables, avoid conflicts with other components, compile without errors, and work consistently across all supported browsers
**Validates: Requirements 7.1, 7.2, 7.3, 7.4, 7.5**

## Error Handling

### CSS Fallback Strategy

The system implements a robust fallback strategy to handle potential CSS loading failures or browser compatibility issues:

```css
/* Fallback values for CSS custom properties */
.navbar-dark-theme {
    background: #27496F; /* Fallback if CSS variables fail */
    background: var(--rdo-header-primary, #27496F);
}

.toolbar-btn-dark {
    width: 48px; /* Fallback dimensions */
    height: 49px;
    width: var(--rdo-button-size, 48px);
    height: var(--rdo-button-height, 49px);
}
```

### Icon Loading Failures

The system handles missing or failed icon loads gracefully:

```csharp
public class ActionButtonService : IActionButtonService
{
    public async Task<ActionButton> GetActionButtonByTypeAsync(ActionButtonType type)
    {
        var button = await GetButtonConfigurationAsync(type);
        
        // Fallback icon if primary icon fails to load
        if (string.IsNullOrEmpty(button.IconClass))
        {
            button.IconClass = GetFallbackIcon(type);
        }
        
        return button;
    }
    
    private string GetFallbackIcon(ActionButtonType type)
    {
        return type switch
        {
            ActionButtonType.Laudos => "fa fa-file", // Fallback for fa fa-folder
            ActionButtonType.DashboardUnidade => "fa fa-tachometer", // Fallback for icon-dashboard
            ActionButtonType.RelatoriosDiarios => "fa fa-file-text", // Fallback for icon-rdo-novo_2
            ActionButtonType.Tarefas => "fa fa-list", // Fallback for fa fa-th
            ActionButtonType.DashboardGeral => "fa fa-chart", // Fallback for fa fa-bar-chart
            ActionButtonType.NovaUnidade => "fa fa-plus", // Same as primary
            _ => "fa fa-question-circle" // Generic fallback
        };
    }
}
```

### Navigation Failures

The system handles navigation failures and permission issues:

```csharp
public class NavigationService : INavigationService
{
    public async Task NavigateToAsync(ActionButtonType buttonType)
    {
        try
        {
            var canNavigate = await CanNavigateToAsync(buttonType, _currentUserRole);
            if (!canNavigate)
            {
                await HandleUnauthorizedAccessAsync(buttonType);
                return;
            }
            
            var url = await GetNavigationUrlAsync(buttonType);
            await _navigationManager.NavigateToAsync(url);
        }
        catch (NavigationException ex)
        {
            _logger.LogError(ex, "Navigation failed for button type {ButtonType}", buttonType);
            await ShowNavigationErrorAsync(buttonType, ex.Message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error during navigation for {ButtonType}", buttonType);
            await ShowGenericErrorAsync();
        }
    }
    
    private async Task HandleUnauthorizedAccessAsync(ActionButtonType buttonType)
    {
        var message = $"Você não tem permissão para acessar {GetButtonDisplayName(buttonType)}";
        await _notificationService.ShowWarningAsync(message);
    }
}
```

### Theme Loading Failures

The system provides graceful degradation when theme loading fails:

```csharp
public class ThemeConfigurationService : IThemeConfigurationService
{
    public async Task<ThemeConfiguration> GetCurrentThemeAsync()
    {
        try
        {
            var theme = await LoadThemeFromConfigurationAsync();
            await ValidateThemeIntegrityAsync(theme);
            return theme;
        }
        catch (ThemeLoadException ex)
        {
            _logger.LogWarning(ex, "Failed to load theme configuration, using fallback");
            return GetFallbackTheme();
        }
    }
    
    private ThemeConfiguration GetFallbackTheme()
    {
        return new ThemeConfiguration
        {
            Type = ThemeType.Professional,
            IsDarkTheme = true,
            PrimaryColor = "#27496F", // Hardcoded fallback
            SecondaryColor = "#1C334D",
            TextColor = "#ffffff",
            CssVariables = CssVariableMapping.ProfessionalTheme
        };
    }
}
```

## Testing Strategy

### Dual Testing Approach

The RDO Soul Restoration implementation requires both unit testing and property-based testing to ensure comprehensive coverage:

**Unit Tests**: Verify specific examples, edge cases, and error conditions
- Test individual button configurations
- Test specific color values and CSS properties
- Test navigation to specific routes
- Test error handling scenarios
- Test responsive breakpoint behavior

**Property Tests**: Verify universal properties across all inputs
- Test theme consistency across all components
- Test button behavior across all button types
- Test responsive behavior across all viewport sizes
- Test navigation patterns across all routes
- Test CSS variable propagation across all elements

### Property-Based Testing Configuration

All property tests will be implemented using **Playwright** for end-to-end testing with **C# bindings**, configured to run a minimum of **100 iterations** per property test. Each property test will reference its corresponding design document property using the following tag format:

**Feature: rdo-soul-restoration, Property {number}: {property_text}**

### Testing Framework Implementation

```csharp
[TestClass]
public class RdoSoulRestorationPropertyTests
{
    [TestMethod]
    [TestCategory("PropertyTest")]
    public async Task Property1_DarkThemeColorConsistency()
    {
        // Feature: rdo-soul-restoration, Property 1: Dark Theme Color Consistency
        
        for (int i = 0; i < 100; i++)
        {
            await using var browser = await Playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            
            await page.GotoAsync("/");
            await page.WaitForLoadStateAsync(LoadState.NetworkIdle);
            
            // Test header background color
            var headerBg = await page.EvaluateAsync<string>(
                "getComputedStyle(document.querySelector('.navbar-dark-theme')).backgroundColor");
            Assert.AreEqual("rgb(39, 73, 111)", headerBg); // #27496F
            
            // Test brand text color
            var textColor = await page.EvaluateAsync<string>(
                "getComputedStyle(document.querySelector('.brand-text')).color");
            Assert.AreEqual("rgb(255, 255, 255)", textColor); // #ffffff
            
            // Test context indicator styling
            var contextBg = await page.EvaluateAsync<string>(
                "getComputedStyle(document.querySelector('.context-indicator')).backgroundColor");
            Assert.IsTrue(contextBg.Contains("rgba(255, 255, 255")); // White with opacity
        }
    }
    
    [TestMethod]
    [TestCategory("PropertyTest")]
    public async Task Property3_ActionToolbarStructure()
    {
        // Feature: rdo-soul-restoration, Property 3: Action Toolbar Structure
        
        for (int i = 0; i < 100; i++)
        {
            await using var browser = await Playwright.Chromium.LaunchAsync();
            var page = await browser.NewPageAsync();
            
            await page.GotoAsync("/");
            await page.WaitForSelectorAsync(".action-toolbar");
            
            // Test exactly 6 buttons
            var buttonCount = await page.EvaluateAsync<int>(
                "document.querySelectorAll('.action-toolbar .toolbar-btn-dark').length");
            Assert.AreEqual(6, buttonCount);
            
            // Test button spacing
            var buttons = await page.QuerySelectorAllAsync(".toolbar-btn-dark");
            for (int j = 0; j < buttons.Count - 1; j++)
            {
                var currentButton = buttons[j];
                var nextButton = buttons[j + 1];
                
                var currentRect = await currentButton.BoundingBoxAsync();
                var nextRect = await nextButton.BoundingBoxAsync();
                
                var spacing = nextRect.X - (currentRect.X + currentRect.Width);
                Assert.IsTrue(spacing >= 4 && spacing <= 8); // 0.25rem spacing tolerance
            }
        }
    }
}
```

### Unit Testing Examples

```csharp
[TestClass]
public class ActionButtonServiceTests
{
    [TestMethod]
    public async Task GetActionButtonByType_ReturnsCorrectConfiguration()
    {
        // Arrange
        var service = new ActionButtonService();
        
        // Act
        var laudosButton = await service.GetActionButtonByTypeAsync(ActionButtonType.Laudos);
        
        // Assert
        Assert.AreEqual("fa fa-folder", laudosButton.IconClass);
        Assert.AreEqual("Laudos", laudosButton.TooltipText);
        Assert.AreEqual("/Laudo", laudosButton.NavigationUrl);
        Assert.AreEqual(1, laudosButton.DisplayOrder);
    }
    
    [TestMethod]
    public async Task GetActionButtons_ReturnsExactlySixButtons()
    {
        // Arrange
        var service = new ActionButtonService();
        
        // Act
        var buttons = await service.GetActionButtonsAsync();
        
        // Assert
        Assert.AreEqual(6, buttons.Count);
        Assert.IsTrue(buttons.All(b => b.DisplayOrder >= 1 && b.DisplayOrder <= 6));
        Assert.AreEqual(6, buttons.Select(b => b.DisplayOrder).Distinct().Count());
    }
}

[TestClass]
public class ThemeConfigurationServiceTests
{
    [TestMethod]
    public async Task GetCurrentTheme_ReturnsProfessionalDarkTheme()
    {
        // Arrange
        var service = new ThemeConfigurationService();
        
        // Act
        var theme = await service.GetCurrentThemeAsync();
        
        // Assert
        Assert.AreEqual(ThemeType.Professional, theme.Type);
        Assert.IsTrue(theme.IsDarkTheme);
        Assert.AreEqual("#27496F", theme.PrimaryColor);
        Assert.AreEqual("#1C334D", theme.SecondaryColor);
        Assert.AreEqual("#ffffff", theme.TextColor);
    }
    
    [TestMethod]
    public async Task GetCssVariables_ContainsAllRequiredVariables()
    {
        // Arrange
        var service = new ThemeConfigurationService();
        
        // Act
        var variables = await service.GetCssVariablesAsync();
        
        // Assert
        Assert.IsTrue(variables.ContainsKey("--rdo-header-primary"));
        Assert.IsTrue(variables.ContainsKey("--rdo-header-secondary"));
        Assert.IsTrue(variables.ContainsKey("--rdo-button-size"));
        Assert.IsTrue(variables.ContainsKey("--rdo-button-height"));
        Assert.AreEqual("#27496F", variables["--rdo-header-primary"]);
        Assert.AreEqual("48px", variables["--rdo-button-size"]);
    }
}
```

### Integration Testing

```csharp
[TestClass]
public class RdoSoulRestorationIntegrationTests
{
    [TestMethod]
    public async Task FullHeaderRendering_AchievesVisualParity()
    {
        // Test complete header rendering with all components
        await using var browser = await Playwright.Chromium.LaunchAsync();
        var page = await browser.NewPageAsync();
        
        await page.GotoAsync("/");
        await page.WaitForLoadStateAsync(LoadState.NetworkIdle);
        
        // Take screenshot for visual regression testing
        var screenshot = await page.ScreenshotAsync(new PageScreenshotOptions
        {
            Path = "header-visual-parity.png",
            Clip = new Clip { X = 0, Y = 0, Width = 1200, Height = 80 }
        });
        
        // Compare with baseline image (visual regression testing)
        var baseline = File.ReadAllBytes("baseline-header.png");
        var similarity = ImageComparison.CalculateSimilarity(screenshot, baseline);
        Assert.IsTrue(similarity >= 0.95, "Header visual parity should be >= 95%");
    }
}
```

This comprehensive testing strategy ensures that the RDO Soul Restoration maintains both functional correctness and visual fidelity while providing confidence in the implementation's reliability and maintainability.