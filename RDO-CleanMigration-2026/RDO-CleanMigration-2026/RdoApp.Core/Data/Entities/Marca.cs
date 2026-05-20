namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Marca (Brand) entity - Equipment/product brands
/// Maps to legacy 'marca' table
/// </summary>
public class Marca
{
    /// <summary>
    /// Primary key - Brand ID
    /// Maps to: mar_id_marca
    /// </summary>
    public int MarIdMarca { get; set; }

    /// <summary>
    /// Brand name
    /// Maps to: mar_ds_marca
    /// </summary>
    public string MarDsMarca { get; set; } = null!;

    /// <summary>
    /// Brand observation/notes
    /// Maps to: mar_ds_observacao
    /// </summary>
    public string MarDsObservacao { get; set; } = null!;
}
