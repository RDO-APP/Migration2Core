namespace RdoApp.Core.Models.Dtos;

public sealed class EfetivoLookupDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
    public string? Cor { get; init; }
}

public sealed class EfetivoItemDto
{
    public int IdEfetivo { get; init; }
    public int IdObraColaborador { get; init; }
    public string Data { get; init; } = "";
    public string NomeColaborador { get; init; } = "";
    public string Cargo { get; init; } = "";
    public int IdStatus { get; init; }
    public string NomeStatus { get; init; } = "";
    public string? Cor { get; init; }
}

public sealed class EfetivoBootstrapDto
{
    public string DataPadrao { get; init; } = "";
    public string ObraNome { get; init; } = "";
    public IReadOnlyList<EfetivoLookupDto> Cargos { get; init; } = Array.Empty<EfetivoLookupDto>();
    public IReadOnlyList<EfetivoLookupDto> Statuses { get; init; } = Array.Empty<EfetivoLookupDto>();
}

public sealed class EfetivoListDto
{
    public IReadOnlyList<EfetivoItemDto> Items { get; init; } = Array.Empty<EfetivoItemDto>();
}

public sealed class EfetivoStatusUpdateRequestDto
{
    public int IdEfetivo { get; init; }
    public int IdObraColaborador { get; init; }
    public int IdStatus { get; init; }
    public string? Data { get; init; }
}

public sealed class EfetivoStatusUpdateResultDto
{
    public bool Ok { get; init; }
    public int? IdEfetivo { get; init; }
    public string? ErrorMessage { get; init; }
}
