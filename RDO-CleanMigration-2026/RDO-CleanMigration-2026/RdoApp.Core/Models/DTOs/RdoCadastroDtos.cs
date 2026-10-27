namespace RdoApp.Core.Models.Dtos;

public sealed class RdoCadastroBootstrapDto
{
    public string DataRdoHoje { get; init; } = "";
    public string ClimaManha { get; init; } = "b";
    public string ClimaTarde { get; init; } = "b";
    public string ClimaNoite { get; init; } = "b";
    public string ChuvaManha { get; init; } = "s";
    public string ChuvaTarde { get; init; } = "s";
    public string ChuvaNoite { get; init; } = "s";
    public bool ObraFinalizada { get; init; }
    public string ObraNome { get; init; } = "";
}

public sealed class RdoCadastroTarefaDto
{
    public int Id { get; init; }
    public string Descricao { get; init; } = "";
    public int Status { get; init; }
    public int IdEtapa { get; init; }
    public bool ExisteRegistroMedicaoDataRequerida { get; init; }
    public bool ExisteRegistroMedicaoDiaAnterior { get; init; }
}

public sealed class RdoCadastroEtapaDto
{
    public int Id { get; init; }
    public string Titulo { get; init; } = "";
    public int Ordem { get; init; }
    public IReadOnlyList<RdoCadastroTarefaDto> Tarefas { get; init; } = Array.Empty<RdoCadastroTarefaDto>();
}

public sealed class RdoCadastroEtapasDto
{
    public IReadOnlyList<RdoCadastroEtapaDto> Etapas { get; init; } = Array.Empty<RdoCadastroEtapaDto>();
}

public sealed class RdoCadastroSaveRequestDto
{
    public string DataRdo { get; set; } = "";
    public string ClimaManha { get; set; } = "b";
    public string ClimaTarde { get; set; } = "b";
    public string ClimaNoite { get; set; } = "b";
    public string ChuvaManha { get; set; } = "s";
    public string ChuvaTarde { get; set; } = "s";
    public string ChuvaNoite { get; set; } = "s";
    public string? Comentario { get; set; }
    public int TipoComentarioGeracao { get; set; }
    public bool ConfirmSubstituir { get; set; }
    public bool ConfirmCopiarDiaAnterior { get; set; }
    public List<RdoCadastroTarefaIdDto> ListaTarefas { get; set; } = new();
}

public sealed class RdoCadastroTarefaIdDto
{
    public int Id { get; set; }
}

public sealed class RdoCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public int IdRdo { get; init; }
    public string? ErrorMessage { get; init; }
    /// <summary>substituir | copiarDiaAnterior</summary>
    public string? NeedsConfirm { get; init; }
    public string? ConfirmDetail { get; init; }
}
