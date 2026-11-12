namespace RdoApp.Core.Models.Dtos;

public sealed class ColaboradorIndexLookupDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
}

public sealed class ColaboradorIndexPermissionsDto
{
    public bool ShowVisualizar { get; init; }
    public bool ShowEditar { get; init; }
    public bool ShowDeletar { get; init; }
    /// <summary>Prod: botão NOVO usa permission="editar".</summary>
    public bool ShowNovo { get; init; }
}

public sealed class ColaboradorIndexBootstrapDto
{
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<ColaboradorIndexLookupDto> Ufs { get; init; } = [];
    public IReadOnlyList<ColaboradorIndexLookupDto> Cargos { get; init; } = [];
    public IReadOnlyList<ColaboradorIndexLookupDto> Grupos { get; init; } = [];
    public ColaboradorIndexPermissionsDto Permissions { get; init; } = new();
}

public sealed class ColaboradorIndexFilterDto
{
    public string? Nome { get; init; }
    public string? Cpf { get; init; }
    public string? Sexo { get; init; }
    public string? Email { get; init; }
    public string? Crea { get; init; }
    public int IdUf { get; init; }
    public int IdMunicipio { get; init; }
    public int IdCargo { get; init; }
    public int IdGrupo { get; init; }
    public string? DataContratacao { get; init; }
}

public sealed class ColaboradorIndexItemDto
{
    public int IdColaborador { get; init; }
    public string Nome { get; init; } = "";
    public string DescricaoCargo { get; init; } = "";
    public string TelefonePrincipal { get; init; } = "";
    public string Email { get; init; } = "";
    public string DescricaoGrupo { get; init; } = "";
    public bool Editavel { get; init; }
    public bool Excluivel { get; init; }
}

public sealed class ColaboradorIndexListResponseDto
{
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<ColaboradorIndexItemDto> Items { get; init; } = [];
}

public sealed class ColaboradorIndexActionResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
}
