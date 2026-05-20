namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Modelo (Model) entity - Equipment/product models
/// Maps to legacy 'modelo' table
/// </summary>
public class Modelo
{
    /// <summary>
    /// Primary key - Model ID
    /// Maps to: mod_id_modelo
    /// </summary>
    public int ModIdModelo { get; set; }

    /// <summary>
    /// Model name
    /// Maps to: mod_ds_modelo
    /// </summary>
    public string ModDsModelo { get; set; } = null!;

    /// <summary>
    /// Model observation/notes
    /// Maps to: mod_ds_observacao
    /// </summary>
    public string ModDsObservacao { get; set; } = null!;
}
