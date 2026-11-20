namespace RdoApp.Core.Models.DTOs;

public sealed class ConvidadaLookupDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
}

public sealed class ConvidadaBootstrapDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
    public string CodigoConvite { get; init; } = "";
    public int IdObra { get; init; }
    public string NomeObra { get; init; } = "";
    public string Papel { get; init; } = "";
    public int TipoConvite { get; init; }
    public IReadOnlyList<ConvidadaLookupDto> Ufs { get; init; } = Array.Empty<ConvidadaLookupDto>();
    public IReadOnlyList<ConvidadaLookupDto> Setores { get; init; } = Array.Empty<ConvidadaLookupDto>();
    public IReadOnlyList<ConvidadaLookupDto> Ramos { get; init; } = Array.Empty<ConvidadaLookupDto>();
    public IReadOnlyList<ConvidadaLookupDto> Cargos { get; init; } = Array.Empty<ConvidadaLookupDto>();
}

public sealed class ConvidadaMunicipiosRequestDto
{
    public int IdUf { get; init; }
}

public sealed class ConvidadaCnpjRequestDto
{
    public string? Cnpj { get; init; }
}

public sealed class ConvidadaEmpresaHintDto
{
    public bool Found { get; init; }
    public string? Cnpj { get; init; }
    public string? RazaoSocial { get; init; }
    public string? NomeFantasia { get; init; }
    public int? IdSetor { get; init; }
    public int? IdRamo { get; init; }
}

public sealed class ConvidadaCpfRequestDto
{
    public string? Cpf { get; init; }
}

public sealed class ConvidadaColaboradorHintDto
{
    public bool Found { get; init; }
    public string? Cpf { get; init; }
    public string? Nome { get; init; }
    public string? Email { get; init; }
    public string? Telefone { get; init; }
    public int? IdUf { get; init; }
    public int? IdMunicipio { get; init; }
}

public sealed class ConvidadaAcessarRequestDto
{
    public string? CodigoConvite { get; init; }
    public string? CnpjEmpresa { get; init; }
    public string? RazaoSocial { get; init; }
    public string? NomeFantasia { get; init; }
    public int IdSetor { get; init; }
    public int IdRamo { get; init; }
    public string? Cpf { get; init; }
    public string? NomeColaborador { get; init; }
    public string? EmailColaborador { get; init; }
    public string? TelefoneColaborador { get; init; }
    public int IdUf { get; init; }
    public int IdMunicipio { get; init; }
    public string? Senha { get; init; }
    public string? ConfirmacaoSenha { get; init; }
    public int Cargo { get; init; }
}

public sealed class ConvidadaAcessarResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
    public string? RedirectUrl { get; init; }
    public int ColaboradorId { get; init; }
}
