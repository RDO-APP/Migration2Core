namespace RdoApp.Core.Models.Dtos;

public sealed class TarefaLookupDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
}

public sealed class TarefaParalizacaoDto
{
    public string Codigo { get; init; } = "";
    public string Descricao { get; init; } = "";
}

public sealed class TarefaCadastroColaboradorDto
{
    public int Id { get; init; }
    public int IdObraColaborador { get; init; }
    public string Nome { get; init; } = "";
    public string DescricaoCargo { get; init; } = "";
    public string TelefonePrincipal { get; init; } = "";
    public string Email { get; init; } = "";
    public string DescricaoGrupo { get; init; } = "";
}

public sealed class TarefaCadastroHistoricoDto
{
    public int IdTarefa { get; init; }
    public string Data { get; init; } = "";
    public string HoraInicial { get; init; } = "";
    public string HoraFinal { get; init; } = "";
    public string DescricaoStatusTarefa { get; init; } = "";
    public float? HorimetroInicial { get; init; }
    public float? HorimetroFinal { get; init; }
    public float? HorimetroTotal { get; init; }
    public float QtdConstruida { get; init; }
    public string UnidadeMedida { get; init; } = "";
    public string NomeColaborador { get; init; } = "";
    public bool RdoAssinado { get; init; }
}

public sealed class TarefaCadastroImagemDto
{
    public int Id { get; init; }
    public string Href { get; init; } = "";
}

public sealed class TarefaCadastroEquipamentoDto
{
    public int Id { get; init; }
    public int IdObraEquipamento { get; init; }
    public string TipoEquipamento { get; init; } = "";
    public string Descricao { get; init; } = "";
    public string TipoAquisicao { get; init; } = "";
    public string FabricanteFornecedor { get; init; } = "";
    public string Contato { get; init; } = "";
    public string Telefone { get; init; } = "";
}

public sealed class TarefaCadastroAcidenteDto
{
    public int Id { get; init; }
    public string Descricao { get; init; } = "";
    public string DataHora { get; init; } = "";
    public bool HouveAfastamento { get; init; }
}

public sealed class TarefaCadastroDto
{
    public int Id { get; init; }
    public string Descricao { get; init; } = "";
    public int IdEtapa { get; init; }
    public int Status { get; init; }
    public string NomeStatus { get; init; } = "";
    public int IdUnidade { get; init; }
    public string DataInicio { get; init; } = "";
    public string DataPrevisaoFim { get; init; } = "";
    public decimal QtdPlanejada { get; init; }
    public decimal Valor { get; init; }
    public float QtdConstruida { get; init; }
    public string DataMedicao { get; init; } = "";
    public string HoraInicial { get; init; } = "";
    public string HoraFinal { get; init; } = "";
    public float HorimetroInicial { get; init; }
    public float HorimetroFinal { get; init; }
    public float HorimetroTotal { get; init; }
    public string Comentario { get; init; } = "";
    public string? CodigoParalizacao { get; init; }
    public bool RdoAssinado { get; init; }
    public float? UltimoHorimetroFinal { get; init; }
    public IReadOnlyList<TarefaCadastroColaboradorDto> ListaColaboradores { get; init; } =
        Array.Empty<TarefaCadastroColaboradorDto>();
    public IReadOnlyList<TarefaCadastroEquipamentoDto> ListaEquipamentos { get; init; } =
        Array.Empty<TarefaCadastroEquipamentoDto>();
    public IReadOnlyList<TarefaLookupDto> Etapas { get; init; } = Array.Empty<TarefaLookupDto>();
    public IReadOnlyList<TarefaLookupDto> StatusTarefa { get; init; } = Array.Empty<TarefaLookupDto>();
    public IReadOnlyList<TarefaLookupDto> Unidades { get; init; } = Array.Empty<TarefaLookupDto>();
    public IReadOnlyList<TarefaParalizacaoDto> CodigosParalizacao { get; init; } =
        Array.Empty<TarefaParalizacaoDto>();
    public IReadOnlyList<TarefaCadastroHistoricoDto> ListaHistoricoTarefa { get; init; } =
        Array.Empty<TarefaCadastroHistoricoDto>();
    public IReadOnlyList<TarefaCadastroImagemDto> ListaImagens { get; init; } =
        Array.Empty<TarefaCadastroImagemDto>();
    public IReadOnlyList<TarefaCadastroAcidenteDto> ListaAcidentes { get; init; } =
        Array.Empty<TarefaCadastroAcidenteDto>();
    public IReadOnlyList<TarefaCadastroColaboradorDto> ColaboradoresObra { get; init; } =
        Array.Empty<TarefaCadastroColaboradorDto>();
    public IReadOnlyList<TarefaCadastroEquipamentoDto> EquipamentosObra { get; init; } =
        Array.Empty<TarefaCadastroEquipamentoDto>();
}

public sealed class TarefaCadastroSaveRequestDto
{
    public int Id { get; set; }
    public bool NovaMedicao { get; set; }
    public string Descricao { get; set; } = "";
    public int IdEtapa { get; set; }
    public int Status { get; set; }
    public int IdUnidade { get; set; }
    public string DataInicio { get; set; } = "";
    public string DataPrevisaoFim { get; set; } = "";
    public decimal? QtdPlanejada { get; set; }
    public decimal? Valor { get; set; }
    public float? QtdConstruida { get; set; }
    public string? DataMedicao { get; set; }
    public string? HoraInicial { get; set; }
    public string? HoraFinal { get; set; }
    public float? HorimetroInicial { get; set; }
    public float? HorimetroFinal { get; set; }
    public float? HorimetroTotal { get; set; }
    public string? Comentario { get; set; }
    public string? CodigoParalizacao { get; set; }
    public List<int>? ListaIdsObraColaborador { get; set; }
    public List<int>? ListaIdsObraEquipamento { get; set; }
}

public sealed class TarefaCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public int Id { get; init; }
    public string? ErrorMessage { get; init; }
}

public sealed class HorasEquipamentoReportRequestDto
{
    public string DataInicial { get; set; } = "";
    public string DataFinal { get; set; } = "";
    public string TipoRelatorio { get; set; } = "PDF";
    public string? DescricaoTarefa { get; set; }
}
