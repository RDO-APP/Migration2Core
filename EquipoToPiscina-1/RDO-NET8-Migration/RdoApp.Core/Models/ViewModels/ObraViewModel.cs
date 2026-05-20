namespace RdoApp.Core.Models.ViewModels
{
    public class ObraViewModel
    {
        public int Id { get; set; }
        public string Descricao { get; set; } = string.Empty;
        public string CidadeEstado { get; set; } = string.Empty;
        public string StatusBasicaGratuita { get; set; } = string.Empty;
        public string ContratanteContratada { get; set; } = string.Empty;
        public int ProgressoPorcentagem { get; set; }
        public string ClasseStatusCss { get; set; } = string.Empty;
        public string DataInicio { get; set; } = string.Empty;
        public string DataConclusao { get; set; } = string.Empty;
        public bool ObraFinalizada { get; set; }
        
        /// <summary>
        /// Path to company logo image (if available in database)
        /// Used for Two Figures logic - displays company logo instead of icon font
        /// </summary>
        public string? LogoPath { get; set; }
    }
}