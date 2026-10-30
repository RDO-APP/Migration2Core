namespace RdoApp.Core.Models.Dtos;

public sealed class RdoCadastroBootstrapDto
{
    public string DataRdoHoje { get; init; } = "";
    public bool ObraFinalizada { get; init; }
    public string ObraNome { get; init; } = "";
}

public sealed class RdoCadastroImagemDto
{
    public int IdImagem { get; init; }
    public string DsCaminho { get; init; } = "";
}

public sealed class RdoCadastroTarefaDto
{
    public int Id { get; init; }
    public string Descricao { get; init; } = "";
    public int Status { get; init; }
    public string NomeStatus { get; init; } = "";
    public int IdEtapa { get; init; }
    public int QuantidadeColaboradores { get; init; }
    public int QuantidadeEquipamentos { get; init; }
    public bool ExisteRegistroMedicaoDataRequerida { get; init; }
    public bool ExisteRegistroMedicaoDiaAnterior { get; init; }
    public IReadOnlyList<RdoCadastroImagemDto> ListaImagem { get; init; } = Array.Empty<RdoCadastroImagemDto>();
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
    public string ClimaManha { get; set; } = "";
    public string ClimaTarde { get; set; } = "";
    public string ClimaNoite { get; set; } = "";
    public string ChuvaManha { get; set; } = "";
    public string ChuvaTarde { get; set; } = "";
    public string ChuvaNoite { get; set; } = "";
    public string? Comentario { get; set; }
    public int TipoComentarioGeracao { get; set; }
    public bool ImprodutividadeCondicoesClimaticas { get; set; }
    public bool ImprodutividadeMateriais { get; set; }
    public bool ImprodutividadeParalizacoes { get; set; }
    public bool ImprodutividadeEquipamentos { get; set; }
    public bool ImprodutividadeContratante { get; set; }
    public bool ImprodutividadeFornecedores { get; set; }
    public bool ImprodutividadeMaodeObra { get; set; }
    public bool ImprodutividadeProjeto { get; set; }
    public bool ImprodutividadePlanejamento { get; set; }
    public bool ImprodutividadeAcidente { get; set; }
    public bool ConfirmSubstituir { get; set; }
    public bool ConfirmCopiarDiaAnterior { get; set; }
    public List<RdoCadastroTarefaIdDto> ListaTarefas { get; set; } = new();
    /// <summary>Paridade prod <c>cadastroParam.listaImagems</c>; null = não alterar vínculos.</summary>
    public List<RdoCadastroImagemIdDto>? ListaImagems { get; set; }
    /// <summary>Paridade prod <c>mostrarFotos</c> / PDF fotográfico.</summary>
    public bool GerarRelatorioFotografico { get; set; }
}

public sealed class RdoCadastroTarefaIdDto
{
    public int Id { get; set; }
}

public sealed class RdoCadastroImagemIdDto
{
    public int IdImagem { get; set; }
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
