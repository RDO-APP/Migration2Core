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

public sealed class ObraIndexLookupDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
}

public sealed class ObraIndexPermissionsDto
{
    public bool ShowVisualizar { get; init; }
    public bool ShowEnviarConvite { get; init; }
    public bool ShowCopiar { get; init; }
    public bool ShowEditar { get; init; }
    public bool ShowDeletar { get; init; }
    public bool ShowCriarNovo { get; init; }
}

public sealed class ObraIndexBootstrapDto
{
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<ObraIndexLookupDto> Empresas { get; init; } = [];
    public IReadOnlyList<ObraIndexLookupDto> Ufs { get; init; } = [];
    public ObraIndexPermissionsDto Permissions { get; init; } = new();
}

public sealed class ObraIndexFilterDto
{
    public string? Descricao { get; init; }
    public int IdContratante { get; init; }
    public string? DataInicioDe { get; init; }
    public string? DataInicioAte { get; init; }
    public int IdUf { get; init; }
    public int IdMunicipio { get; init; }
    public int StatusObra { get; init; }
}

public sealed class ObraIndexItemDto
{
    public int IdObra { get; init; }
    public string Descricao { get; init; } = "";
    public string DescricaoContratante { get; init; } = "";
    public string DescricaoContratada { get; init; } = "";
    public string DataInicio { get; init; } = "";
    public string DataConclusao { get; init; } = "";
    public string CidadeEstado { get; init; } = "";
    public int DiasDecorridos { get; init; }
}

public sealed class ObraIndexListResponseDto
{
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<ObraIndexItemDto> Items { get; init; } = [];
}

public sealed class ObraIndexActionResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
}

public sealed class ObraConviteRequestDto
{
    public int IdObra { get; init; }
    public string? EmailConvidada { get; init; }
}
