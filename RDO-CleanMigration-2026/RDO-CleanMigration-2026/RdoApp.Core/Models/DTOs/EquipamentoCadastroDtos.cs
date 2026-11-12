namespace RdoApp.Core.Models.Dtos;

public sealed class EquipamentoCadastroFormDto
{
    public int IdEquipamento { get; init; }
    public int IdObraEquipamento { get; init; }
    public string TipoEquipamento { get; init; } = "";
    public string Descricao { get; init; } = "";
    public string Marca { get; init; } = "";
    public string Modelo { get; init; } = "";
    public string TipoAquisicao { get; init; } = "S";
    public string DataAquisicao { get; init; } = "";
    public string FabricanteFornecedor { get; init; } = "";
    public string Contato { get; init; } = "";
    public string Telefone { get; init; } = "";
    public bool PodeSalvar { get; init; }
    public string ObraNomeSessao { get; init; } = "";
}

public sealed class EquipamentoCadastroSaveRequestDto
{
    public int IdEquipamento { get; set; }
    public string? TipoEquipamento { get; set; }
    public string? Descricao { get; set; }
    public string? Marca { get; set; }
    public string? Modelo { get; set; }
    public string? TipoAquisicao { get; set; }
    public string? DataAquisicao { get; set; }
    public string? FabricanteFornecedor { get; set; }
    public string? Contato { get; set; }
    public string? Telefone { get; set; }
}

public sealed class EquipamentoCadastroSaveResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
    public int IdEquipamento { get; init; }
}
