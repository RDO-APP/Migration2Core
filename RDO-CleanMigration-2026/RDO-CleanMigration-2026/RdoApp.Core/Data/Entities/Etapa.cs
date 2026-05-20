namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Etapa (Stage/Phase) entity - Project stages/phases
/// Maps to legacy 'etapa' table
/// </summary>
public class Etapa
{
    public Etapa()
    {
        // Navigation properties will be added when Tarefa is fully implemented
        // Tarefas = new HashSet<Tarefa>();
    }

    /// <summary>
    /// Primary key - Stage ID
    /// Maps to: eta_id_etapa
    /// </summary>
    public int EtaIdEtapa { get; set; }

    /// <summary>
    /// Stage name/description
    /// Maps to: eta_ds_etapa
    /// </summary>
    public string EtaDsEtapa { get; set; } = null!;

    /// <summary>
    /// Order/sequence number
    /// Maps to: eta_nr_orderm
    /// </summary>
    public int EtaNrOrderm { get; set; }

    /// <summary>
    /// Foreign key - Project ID
    /// Maps to: eta_id_obra
    /// </summary>
    public int EtaIdObra { get; set; }

    // Navigation properties (will be added when related entities are implemented)
    // public virtual Obra Obra { get; set; }
    // public virtual ICollection<Tarefa> Tarefas { get; set; }
}
