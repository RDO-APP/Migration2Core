namespace RdoApp.Core.Models.Dtos;

public sealed class TarefaCardDto
{
    public int Id { get; init; }
    public string Descricao { get; init; } = "";
    public int Status { get; init; }
    public string NomeStatus { get; init; } = "";
    public int IdEtapa { get; init; }
    public string DataInicio { get; init; } = "";
    public string DataPrevisaoFim { get; init; } = "";
    public double PercentualConcluido { get; init; }
    public string PercentualExtrapolado { get; init; } = "true";
    public string ClasseStatusCss { get; init; } = "bg-cinza";
}

public sealed class EtapaComTarefasDto
{
    public int Id { get; init; }
    public string Titulo { get; init; } = "";
    public int Ordem { get; init; }
    public int IdObra { get; init; }
    public string? TituloObra { get; init; }
    public IReadOnlyList<TarefaCardDto> Tarefas { get; init; } = Array.Empty<TarefaCardDto>();
}

public sealed class CardsContextDto
{
    public int ObraId { get; init; }
    public string ObraNome { get; init; } = "";
    public string UsuarioNome { get; set; } = "";
    public IReadOnlyList<EtapaComTarefasDto> Etapas { get; init; } = Array.Empty<EtapaComTarefasDto>();
}
