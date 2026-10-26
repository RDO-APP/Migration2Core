namespace RdoApp.Core.Models.Dtos;

public sealed class ShellNavItemDto
{
    public string Titulo { get; init; } = "";
    public string Href { get; init; } = "#";
    public string CssClass { get; init; } = "fa fa-circle";
}

public sealed class ShellContextDto
{
    public string UsuarioNome { get; set; } = "";
    public string? ObraNome { get; set; }
    public string? ObraCidadeEstado { get; set; }
    public bool ShowChart { get; init; }
    public bool ShowNovaObra { get; init; }
    public bool ShowDashboardObra { get; init; }
    /// <summary>P3 toolbar — paridade cards.html <c>permission="gerarRdo"</c> em /tarefa/cards.</summary>
    public bool ShowGerarRdo { get; init; }
    /// <summary>P3 toolbar — paridade cards.html <c>permission="editarObra"</c> em /tarefa/cards.</summary>
    public bool ShowEditarObra { get; init; }
    public bool ShowCriarNovoTarefa { get; init; }
    public bool ShowCriarNovaEtapa { get; init; }
    /// <summary>Typo legado <c>aterarStatusEmMassa</c> em cards.html.</summary>
    public bool ShowAlterarStatusEmMassa { get; init; }
    public IReadOnlyList<ShellNavItemDto> MenuPaginas { get; init; } = Array.Empty<ShellNavItemDto>();
    public string? AntiforgeryFieldName { get; init; }
    public string? AntiforgeryToken { get; init; }
}
