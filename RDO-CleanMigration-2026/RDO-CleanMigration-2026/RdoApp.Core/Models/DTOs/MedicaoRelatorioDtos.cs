namespace RdoApp.Core.Models.Dtos;

public sealed class MedicaoRelatorioRequestDto
{
    public string? DataInicial { get; init; }
    public string? DataFinal { get; init; }
    /// <summary>PDF | Excel</summary>
    public string? TipoRelatorio { get; init; }
}
