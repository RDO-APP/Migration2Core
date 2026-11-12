namespace RdoApp.Core.Models.Dtos;

public sealed class ColaboradorCadastroFormDto
{
    public int IdColaborador { get; init; }
    public string Cpf { get; init; } = "";
    public int IdGrupo { get; init; }
    public string Nome { get; init; } = "";
    public int IdCargo { get; init; }
    public string Sexo { get; init; } = "S";
    public string DataNascimento { get; init; } = "";
    public string TelefonePrincipal { get; init; } = "";
    public string TelefoneSecundario { get; init; } = "";
    public string Email { get; init; } = "";
    public string Crea { get; init; } = "";
    public string DataContratacao { get; init; } = "";
    public string Logradouro { get; init; } = "";
    public string NumeroEndereco { get; init; } = "";
    public string Complemento { get; init; } = "";
    public string Bairro { get; init; } = "";
    public int IdUf { get; init; }
    public int IdMunicipio { get; init; }
    public string Cep { get; init; } = "";
    public bool PodeSalvar { get; init; }
    public bool ExigeSenha { get; init; }
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<ColaboradorIndexLookupDto> Ufs { get; init; } = [];
    public IReadOnlyList<ColaboradorIndexLookupDto> Cargos { get; init; } = [];
    public IReadOnlyList<ColaboradorIndexLookupDto> Grupos { get; init; } = [];
    public IReadOnlyList<ColaboradorIndexLookupDto> Municipios { get; init; } = [];
}

public sealed class ColaboradorCadastroSaveRequestDto
{
    public int IdColaborador { get; set; }
    public string? Cpf { get; set; }
    public int IdGrupo { get; set; }
    public string? Nome { get; set; }
    public int IdCargo { get; set; }
    public string? Sexo { get; set; }
    public string? DataNascimento { get; set; }
    public string? TelefonePrincipal { get; set; }
    public string? TelefoneSecundario { get; set; }
    public string? Email { get; set; }
    public string? Crea { get; set; }
    public string? DataContratacao { get; set; }
    public string? Logradouro { get; set; }
    public string? NumeroEndereco { get; set; }
    public string? Complemento { get; set; }
    public string? Bairro { get; set; }
    public int IdMunicipio { get; set; }
    public string? Cep { get; set; }
    public string? Senha { get; set; }
    public string? ConfirmacaoSenha { get; set; }
}

public sealed class ColaboradorCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
    public int IdColaborador { get; init; }
}
