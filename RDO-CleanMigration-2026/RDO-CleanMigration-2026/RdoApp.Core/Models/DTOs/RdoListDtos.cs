namespace RdoApp.Core.Models.Dtos;

public sealed class RdoListItemDto
{
    public int IdRdo { get; init; }
    public string DataRdo { get; init; } = "";
    public string DiaDaSemana { get; init; } = "";
    public int StatusRdo { get; init; }
    public string DescricaoStatus { get; init; } = "";
    public int QtdTarefas { get; init; }
    public int QtdColaboradores { get; init; }
    public int QtdMaquinas { get; init; }
}

public sealed class RdoStatusOptionDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
}

public sealed class RdoListPageDto
{
    public int CurrentPage { get; init; }
    public int PageSize { get; init; }
    public int TotalPages { get; init; }
    public int TotalCount { get; init; }
    public IReadOnlyList<RdoListItemDto> Items { get; init; } = Array.Empty<RdoListItemDto>();
    public string ObraNome { get; init; } = "";
}
