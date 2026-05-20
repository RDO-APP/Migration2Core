namespace RdoApp.Core.Data.Entities;

/// <summary>
/// ObraEquipamento (Project-Equipment Assignment) entity - Assigns equipment to projects
/// Maps to legacy 'obra_equipamento' table
/// </summary>
public class ObraEquipamento
{
    public ObraEquipamento()
    {
        // Navigation properties will be added when related entities are fully implemented
        // HistoricoTarefaEquipamentos = new HashSet<HistoricoTarefaEquipamento>();
        // ObraTarefaEquipamentos = new HashSet<ObraTarefaEquipamento>();
    }

    /// <summary>
    /// Primary key - Project-Equipment assignment ID
    /// Maps to: oeq_id_obra_equipamento
    /// </summary>
    public int OeqIdObraEquipamento { get; set; }

    /// <summary>
    /// Foreign key - Project ID
    /// Maps to: oeq_id_obra
    /// </summary>
    public int OeqIdObra { get; set; }

    /// <summary>
    /// Foreign key - Equipment ID
    /// Maps to: oeq_id_equipamento
    /// </summary>
    public int OeqIdEquipamento { get; set; }

    /// <summary>
    /// Acquisition type (purchase, rental, etc.)
    /// Maps to: oeq_tp_aquisicao
    /// </summary>
    public string OeqTpAquisicao { get; set; } = null!;

    /// <summary>
    /// Manufacturer/Supplier description
    /// Maps to: oeq_ds_fabricante_fornecedor
    /// </summary>
    public string OeqDsFabricanteFornecedor { get; set; } = null!;

    /// <summary>
    /// Acquisition date
    /// Maps to: oeq_dt_aquisicao
    /// </summary>
    public DateTime? OeqDtAquisicao { get; set; }

    /// <summary>
    /// Contact person
    /// Maps to: oeq_ds_contato
    /// </summary>
    public string OeqDsContato { get; set; } = null!;

    /// <summary>
    /// Contact phone
    /// Maps to: oeq_ds_telefone
    /// </summary>
    public string OeqDsTelefone { get; set; } = null!;

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Equipamento Equipamento { get; set; }
    // public virtual Obra Obra { get; set; }
    // public virtual ICollection<HistoricoTarefaEquipamento> HistoricoTarefaEquipamentos { get; set; }
    // public virtual ICollection<ObraTarefaEquipamento> ObraTarefaEquipamentos { get; set; }
}
