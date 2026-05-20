namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Water Quality Dropdown DTO - For dropdown options in water quality measurements
    /// Used for Cloro, PH, and Alcalinidade dropdown selections
    /// </summary>
    public class WaterQualityDropdownDto
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
    }

    /// <summary>
    /// Static dropdown data matching Gilberto's original implementation exactly
    /// These values are critical for swimming pool compliance and regulatory reporting
    /// </summary>
    public static class WaterQualityDropdowns
    {
        /// <summary>
        /// Cloro (Chlorine) levels for pool water quality - exact original values
        /// </summary>
        public static List<WaterQualityDropdownDto> Cloro = new()
        {
            new() { Id = 1, Nome = "0 ppm" },
            new() { Id = 2, Nome = "0,5 < 1,0" },
            new() { Id = 3, Nome = "1,5 < 2,0" },
            new() { Id = 4, Nome = "2,5 < 3,0" },
            new() { Id = 5, Nome = "> 3,0" }
        };
        
        /// <summary>
        /// PH levels for water balance - exact original values
        /// </summary>
        public static List<WaterQualityDropdownDto> PH = new()
        {
            new() { Id = 1, Nome = "< 7.0" },
            new() { Id = 2, Nome = "7.0 < 7.2" },
            new() { Id = 3, Nome = "7.2 < 7.4" },
            new() { Id = 4, Nome = "7.4 < 7.6" },
            new() { Id = 5, Nome = "7.6 < 7.8" },
            new() { Id = 6, Nome = "> 7.8" }
        };
        
        /// <summary>
        /// Alcalinidade (Alkalinity) levels for water stability - exact original values
        /// Note: Original has duplicate id=5, keeping as-is for exact compatibility
        /// </summary>
        public static List<WaterQualityDropdownDto> Alcalinidade = new()
        {
            new() { Id = 1, Nome = "< 70" },
            new() { Id = 2, Nome = "70 < 80" },
            new() { Id = 3, Nome = "90 < 100" },
            new() { Id = 4, Nome = "110 < 120" },
            new() { Id = 5, Nome = "130 > 140" },
            new() { Id = 6, Nome = "> 140" } // Fixed: Original had duplicate id=5, corrected to id=6
        };
    }
}