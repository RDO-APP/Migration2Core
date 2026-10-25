namespace RdoApp.Core.Models.ViewModels;

public sealed class EmMigracaoViewModel
{
    public string Titulo { get; init; } = "Em migração";
    public string? Descricao { get; init; }
    public string VoltarUrl { get; init; } = "/Obra/Escolher";
    public string VoltarRotulo { get; init; } = "Voltar";
}
