namespace RdoApp.Core.Models.Dtos;

public sealed class EtapaCadastroBlankDto
{
    public int? Id { get; init; }
    public string? Titulo { get; init; }
    public int OrdemSugerida { get; init; }
}

public sealed class EtapaCadastroSaveRequestDto
{
    public int? Id { get; init; }
    public string? Titulo { get; init; }
    public int Ordem { get; init; }
}

public sealed class EtapaCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public int? Id { get; init; }
    public string? ErrorMessage { get; init; }
}

public sealed class EtapaListItemDto
{
    public int Id { get; init; }
    public string Titulo { get; init; } = "";
    public int Ordem { get; init; }
}

public sealed class EtapaListResponseDto
{
    public string ObraNome { get; init; } = "";
    public IReadOnlyList<EtapaListItemDto> Items { get; init; } = [];
}
