namespace RdoApp.Core.Models.Dtos;

public sealed class ObraCadastroLookupDto
{
    public int Id { get; init; }
    public string Nome { get; init; } = "";
}

public sealed class ObraCadastroDto
{
    public int Id { get; init; }
    public bool Nova { get; init; }
    public string Descricao { get; init; } = "";
    public string DataInicio { get; init; } = "";
    public string DataPrevisaoFim { get; init; } = "";
    public string Logradouro { get; init; } = "";
    public string Numero { get; init; } = "";
    public string Complemento { get; init; } = "";
    public string Bairro { get; init; } = "";
    public string Cep { get; init; } = "";
    public int IdUf { get; init; }
    public int IdMunicipio { get; init; }
    public int IdContratante { get; init; }
    public int IdContratada { get; init; }
    public int? AreaTotal { get; init; }
    public int? AreaConstruida { get; init; }
    public string CidadeEstado { get; init; } = "";
    public bool Finalizada { get; init; }
    /// <summary>URL relativa do logo (obr_ds_foto), ex. /Uploads/123/logocontratada/....jpeg</summary>
    public string DescricaoFoto { get; init; } = "";
    /// <summary>Empresas do colaborador (+ FKs da obra) para os dropdowns.</summary>
    public IReadOnlyList<ObraCadastroLookupDto> Empresas { get; init; } = [];
    /// <summary>IDs em que o usuário é dono (emp_id_colaborador) — usados para derivar papel t/d.</summary>
    public IReadOnlyList<int> IdsEmpresasDoUsuario { get; init; } = [];
}

public sealed class ObraCadastroSaveRequestDto
{
    public bool Nova { get; init; }
    public string? Descricao { get; init; }
    public string? DataInicio { get; init; }
    public string? DataPrevisaoFim { get; init; }
    public string? Logradouro { get; init; }
    public string? Numero { get; init; }
    public string? Complemento { get; init; }
    public string? Bairro { get; init; }
    public string? Cep { get; init; }
    public int IdMunicipio { get; init; }
    public int IdContratante { get; init; }
    public int IdContratada { get; init; }
    public int? AreaTotal { get; init; }
    public int? AreaConstruida { get; init; }
    /// <summary>data:image/...;base64,... (nova) ou /Uploads/... (manter) ou vazio.</summary>
    public string? Foto { get; init; }
    public bool RemoverFoto { get; init; }
}

public sealed class ObraCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
    public string? ObraNome { get; init; }
    public int? ObraId { get; init; }
}
