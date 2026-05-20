namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Equipamento (Equipment) entity - Equipment/machinery information
/// Maps to legacy 'equipamento' table
/// </summary>
public class Equipamento
{
    public Equipamento()
    {
        // Navigation properties will be added when ObraEquipamento is fully implemented
        // ObraEquipamentos = new HashSet<ObraEquipamento>();
    }

    /// <summary>
    /// Primary key - Equipment ID
    /// Maps to: equ_id_equipamento
    /// </summary>
    public int EquIdEquipamento { get; set; }

    /// <summary>
    /// Equipment description/name
    /// Maps to: equ_ds_equipamento
    /// </summary>
    public string EquDsEquipamento { get; set; } = null!;

    /// <summary>
    /// Equipment brand
    /// Maps to: equ_ds_marca
    /// </summary>
    public string EquDsMarca { get; set; } = null!;

    /// <summary>
    /// Equipment model
    /// Maps to: equ_ds_modelo
    /// </summary>
    public string EquDsModelo { get; set; } = null!;

    /// <summary>
    /// Foreign key - Equipment Type ID
    /// Maps to: equ_id_tipo_equipamento
    /// </summary>
    public int EquIdTipoEquipamento { get; set; }

    /// <summary>
    /// Equipment image filename/path
    /// Maps to: equ_ds_imagem
    /// </summary>
    public string EquDsImagem { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual TipoEquipamento TipoEquipamento { get; set; }
    // public virtual ICollection<ObraEquipamento> ObraEquipamentos { get; set; }
}
