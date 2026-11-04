namespace RdoApp.Core.Models.Dtos;

public sealed class EtapaCadastroBlankDto
{
    public int OrdemSugerida { get; init; }
}

public sealed class EtapaCadastroSaveRequestDto
{
    public string? Titulo { get; init; }
    public int Ordem { get; init; }
}

public sealed class EtapaCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public int? Id { get; init; }
    public string? ErrorMessage { get; init; }
}
