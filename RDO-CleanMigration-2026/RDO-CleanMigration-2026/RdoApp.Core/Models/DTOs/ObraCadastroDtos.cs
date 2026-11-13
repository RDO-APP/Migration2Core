namespace RdoApp.Core.Models.Dtos;

public sealed class ObraCadastroDto
{
    public int Id { get; init; }
    public bool Nova { get; init; }
    public string Descricao { get; init; } = "";
    public string DataInicio { get; init; } = "";
    public string DataPrevisaoFim { get; init; } = "";
    public string Logradouro { get; init; } = "";
    public string Numero { get; init; } = "";
    public string Bairro { get; init; } = "";
    public string Cep { get; init; } = "";
    public int? AreaTotal { get; init; }
    public int? AreaConstruida { get; init; }
    public string CidadeEstado { get; init; } = "";
    public bool Finalizada { get; init; }
}

public sealed class ObraCadastroSaveRequestDto
{
    public bool Nova { get; init; }
    public string? Descricao { get; init; }
    public string? DataInicio { get; init; }
    public string? DataPrevisaoFim { get; init; }
    public string? Logradouro { get; init; }
    public string? Numero { get; init; }
    public string? Bairro { get; init; }
    public string? Cep { get; init; }
    public int? AreaTotal { get; init; }
    public int? AreaConstruida { get; init; }
}

public sealed class ObraCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
    public string? ObraNome { get; init; }
    public int? ObraId { get; init; }
}
