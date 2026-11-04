namespace RdoApp.Core.Models.Dtos;

public sealed class StatusPermitidoDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
    public string CssClass { get; init; } = "bg-cinza";
}

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
    public int QuantidadeColaboradores { get; init; }
    public int QuantidadeEquipamentos { get; init; }
    public string? PrimeiraExecucao { get; init; }
    public string? UltimaExecucao { get; init; }
    public bool ExisteExecucao { get; init; }
    public IReadOnlyList<StatusPermitidoDto> ListaStatusPermitidos { get; init; } = Array.Empty<StatusPermitidoDto>();
}

public sealed class TarefaStatusUpdateRequestDto
{
    public int IdStatus { get; init; }
}

public sealed class TarefaStatusUpdateResultDto
{
    public bool Ok { get; init; }
    public int? Id { get; init; }
    public string? ErrorMessage { get; init; }
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

public sealed class TarefaStatusMassaRequestDto
{
    public IReadOnlyList<int> Ids { get; init; } = Array.Empty<int>();
    public int IdStatus { get; init; }
}

public sealed class TarefaStatusMassaResultDto
{
    public bool Ok { get; init; }
    public int Updated { get; init; }
    public int Failed { get; init; }
    public string? ErrorMessage { get; init; }
}
