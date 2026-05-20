namespace RdoApp.Core.Data.Entities;

/// <summary>
/// UnidadeDeMedida (Unit of Measurement) entity - Units for task measurements
/// Maps to legacy 'unidade_de_medida' table
/// </summary>
public class UnidadeDeMedida
{
    public UnidadeDeMedida()
    {
        // Navigation properties will be added when Tarefa is fully implemented
        // Tarefas = new HashSet<Tarefa>();
    }

    /// <summary>
    /// Primary key - Unit ID
    /// Maps to: unm_id_unidade
    /// </summary>
    public int UnmIdUnidade { get; set; }

    /// <summary>
    /// Unit description (e.g., "Metro", "Quilograma", "Litro")
    /// Maps to: unm_ds_unidade
    /// </summary>
    public string UnmDsUnidade { get; set; } = null!;

    /// <summary>
    /// Unit symbol (e.g., "m", "kg", "L")
    /// Maps to: unm_ds_simbolo
    /// </summary>
    public string UnmDsSimbolo { get; set; } = null!;

    // Navigation properties (will be added when Tarefa is implemented)
    // public virtual ICollection<Tarefa> Tarefas { get; set; }
}
