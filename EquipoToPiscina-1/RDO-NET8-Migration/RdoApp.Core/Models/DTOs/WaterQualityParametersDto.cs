namespace RdoApp.Core.Models.DTOs
{
    /// <summary>
    /// Water Quality Parameters DTO - Critical for Swimming Pool Compliance
    /// Used for water quality measurement entry and display
    /// Field naming strategy: Bacteria field in code, Detritos label in UI
    /// </summary>
    public class WaterQualityParametersDto
    {
        public int NivelCloro { get; set; }
        public int NivelPH { get; set; }
        public int NivelAlcalinidade { get; set; }
        public bool Limpidez { get; set; }
        public bool Superficie { get; set; }
        public bool Fundo { get; set; }
        public bool Bacteria { get; set; } // FIELD NAME: "Bacteria" in code, displays as "Detritos" label in UI
        public bool Proliferacao { get; set; }
    }
}