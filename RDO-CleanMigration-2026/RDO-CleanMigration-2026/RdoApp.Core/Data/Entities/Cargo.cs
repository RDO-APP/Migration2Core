namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Cargo (Job Position) entity - Employee positions/roles
/// Maps to legacy 'cargo' table
/// </summary>
public class Cargo
{
    public Cargo()
    {
        // Navigation properties will be added when ObraColaborador is fully implemented
        // ObraColaboradores = new HashSet<ObraColaborador>();
    }

    /// <summary>
    /// Primary key - Position ID
    /// Maps to: car_id_cargo
    /// </summary>
    public int CarIdCargo { get; set; }

    /// <summary>
    /// Position name (e.g., "Engenheiro", "Pedreiro")
    /// Maps to: car_ds_cargo
    /// </summary>
    public string CarDsCargo { get; set; } = null!;

    // Navigation properties (will be added when ObraColaborador is implemented)
    // public virtual ICollection<ObraColaborador> ObraColaboradores { get; set; }
}
