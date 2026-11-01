namespace RdoApp.Core.Models.Dtos;

public sealed class RdoPdfRequestDto
{
    public int IdRdo { get; init; }
    public bool GerarRelatorioFotografico { get; init; }
}
