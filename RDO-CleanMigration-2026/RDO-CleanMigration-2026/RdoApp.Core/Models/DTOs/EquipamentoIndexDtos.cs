namespace RdoApp.Core.Models.Dtos;

public sealed class EquipamentoIndexPermissionsDto
{
    public bool ShowVisualizar { get; init; }
    public bool ShowEditar { get; init; }
    public bool ShowDeletar { get; init; }
    /// <summary>Prod: botão NOVO usa permission="criarNovo".</summary>
    public bool ShowNovo { get; init; }
}

public sealed class EquipamentoIndexBootstrapDto
{
    public string ObraNomeSessao { get; init; } = "";
    public EquipamentoIndexPermissionsDto Permissions { get; init; } = new();
}

public sealed class EquipamentoIndexFilterDto
{
    public string? TipoEquipamento { get; init; }
    public string? Descricao { get; init; }
    public string? Marca { get; init; }
    public string? Modelo { get; init; }
    /// <summary>S = todos; A = Aluguel; C = Compra.</summary>
    public string? TipoAquisicao { get; init; }
    public string? FabricanteFornecedor { get; init; }
}

public sealed class EquipamentoIndexItemDto
{
    public int IdEquipamento { get; init; }
    public int IdObraEquipamento { get; init; }
    public string TipoEquipamento { get; init; } = "";
    public string Descricao { get; init; } = "";
    public string FabricanteFornecedor { get; init; } = "";
    public string Contato { get; init; } = "";
    public string Telefone { get; init; } = "";
}

public sealed class EquipamentoIndexListResponseDto
{
    public string ObraNomeSessao { get; init; } = "";
    public IReadOnlyList<EquipamentoIndexItemDto> Items { get; init; } = [];
}

public sealed class EquipamentoIndexActionResultDto
{
    public bool Ok { get; init; }
    public string? ErrorMessage { get; init; }
}
