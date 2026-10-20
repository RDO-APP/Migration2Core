namespace RdoApp.Core.Models.Dtos;

public sealed class ObraListItemDto
{
    public int IdObra { get; init; }
    public int IdColaborador { get; init; }
    public string Descricao { get; init; } = "";
    public string? CidadeEstado { get; init; }
    public string? ContratanteContratada { get; init; }
    public string? StatusBasicaGratuita { get; init; }
    public int ProgressoPorcentagem { get; init; }
    public string ClasseStatusCss { get; init; } = "bg-cinza";
    public bool ObraFinalizada { get; init; }
}

public sealed class EscolherContextDto
{
    public int ColaboradorId { get; init; }
    public string UsuarioNome { get; set; } = "";
    public IReadOnlyList<ObraListItemDto> Obras { get; init; } = Array.Empty<ObraListItemDto>();
}

public sealed class SelecionarObraRequest
{
    public int IdObra { get; init; }
}

public sealed class SelecionarObraResponse
{
    public bool Success { get; init; }
    public string? ErrorMessage { get; init; }
    public string? RedirectUrl { get; init; }
}
