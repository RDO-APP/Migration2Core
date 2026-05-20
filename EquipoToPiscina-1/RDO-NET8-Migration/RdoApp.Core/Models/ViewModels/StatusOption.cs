namespace RdoApp.Core.Models.ViewModels
{
    /// <summary>
    /// Status option for dropdown filtering
    /// </summary>
    public class StatusOption
    {
        public int Id { get; set; }
        public string Nome { get; set; } = string.Empty;
        public string CssClass { get; set; } = string.Empty;
    }
}