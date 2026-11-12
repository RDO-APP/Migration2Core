namespace RdoApp.Core.Models.Dtos;

public sealed class EmpresaIndexLookupDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
}

public sealed class EmpresaIndexPermissionsDto
{
    public bool ShowVisualizar { get; init; }
}

public sealed class EmpresaIndexBootstrapDto
{
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<EmpresaIndexLookupDto> Ufs { get; init; } = [];
    public IReadOnlyList<EmpresaIndexLookupDto> Ramos { get; init; } = [];
    public IReadOnlyList<EmpresaIndexLookupDto> Setores { get; init; } = [];
    public EmpresaIndexPermissionsDto Permissions { get; init; } = new();
}

public sealed class EmpresaIndexFilterDto
{
    public string? RazaoSocial { get; init; }
    public string? Cnpj { get; init; }
    public int IdUf { get; init; }
    public int IdMunicipio { get; init; }
    public int IdRamo { get; init; }
    public int IdSetor { get; init; }
}

public sealed class EmpresaIndexItemDto
{
    public int IdEmpresa { get; init; }
    public string RazaoSocial { get; init; } = "";
    public string NomeFantasia { get; init; } = "";
    public string Local { get; init; } = "";
    public string Telefone { get; init; } = "";
    public bool Editavel { get; init; }
}

public sealed class EmpresaIndexListResponseDto
{
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<EmpresaIndexItemDto> Items { get; init; } = [];
}
