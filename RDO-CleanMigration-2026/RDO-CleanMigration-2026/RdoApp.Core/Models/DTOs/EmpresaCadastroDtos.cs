namespace RdoApp.Core.Models.Dtos;

public sealed class EmpresaCadastroFormDto
{
    public int IdEmpresa { get; init; }
    public string RazaoSocial { get; init; } = "";
    public string NomeFantasia { get; init; } = "";
    public string Cnpj { get; init; } = "";
    public int IdRamo { get; init; }
    public int IdSetor { get; init; }
    public string Logradouro { get; init; } = "";
    public string NumeroEndereco { get; init; } = "";
    public string Complemento { get; init; } = "";
    public string Bairro { get; init; } = "";
    public int IdUf { get; init; }
    public int IdMunicipio { get; init; }
    public string Cep { get; init; } = "";
    public string Telefone { get; init; } = "";
    public bool Editavel { get; init; }
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<EmpresaIndexLookupDto> Ufs { get; init; } = [];
    public IReadOnlyList<EmpresaIndexLookupDto> Ramos { get; init; } = [];
    public IReadOnlyList<EmpresaIndexLookupDto> Setores { get; init; } = [];
    public IReadOnlyList<EmpresaIndexLookupDto> Municipios { get; init; } = [];
}

public sealed class EmpresaCadastroSaveRequestDto
{
    public int IdEmpresa { get; set; }
    public string? RazaoSocial { get; set; }
    public string? NomeFantasia { get; set; }
    public string? Cnpj { get; set; }
    public int IdRamo { get; set; }
    public int IdSetor { get; set; }
    public string? Logradouro { get; set; }
    public string? NumeroEndereco { get; set; }
    public string? Complemento { get; set; }
    public string? Bairro { get; set; }
    public int IdMunicipio { get; set; }
    public string? Cep { get; set; }
    public string? Telefone { get; set; }
}

public sealed class EmpresaCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
    public int IdEmpresa { get; init; }
}
