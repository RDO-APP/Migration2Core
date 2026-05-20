namespace RdoApp.Core.Data.Entities;

/// <summary>
/// TipoEquipamento (Equipment Type) entity - Categories of equipment
/// Maps to legacy 'tipo_equipamento' table
/// </summary>
public class TipoEquipamento
{
    public TipoEquipamento()
    {
        // Navigation properties will be added when Equipamento is fully implemented
        // Equipamentos = new HashSet<Equipamento>();
    }

    /// <summary>
    /// Primary key - Equipment Type ID
    /// Maps to: teq_id_tipo_equipamento
    /// </summary>
    public int TeqIdTipoEquipamento { get; set; }

    /// <summary>
    /// Equipment type name (e.g., "Betoneira", "Escavadeira")
    /// Maps to: teq_nm_tipo_equipamento
    /// </summary>
    public string TeqNmTipoEquipamento { get; set; } = null!;

    /// <summary>
    /// Equipment type description
    /// Maps to: teq_ds_tipo_equipamento
    /// </summary>
    public string TeqDsTipoEquipamento { get; set; } = null!;

    // Navigation properties (will be added when Equipamento is implemented)
    // public virtual ICollection<Equipamento> Equipamentos { get; set; }
}
