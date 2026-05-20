namespace RdoApp.Core.Data.Entities;

/// <summary>
/// HistoricoLogin (Login History) entity - Historical record of user logins
/// Maps to legacy 'historico_login' table
/// Note: Legacy table has NO primary key - using composite key (worker, project, login date)
/// </summary>
public class HistoricoLogin
{
    /// <summary>
    /// Worker ID (part of composite key)
    /// Maps to: col_id_colaborador
    /// </summary>
    public int ColIdColaborador { get; set; }

    /// <summary>
    /// Worker CPF (Brazilian tax ID)
    /// Maps to: col_nr_cpf
    /// </summary>
    public string ColNrCpf { get; set; } = null!;

    /// <summary>
    /// Worker name
    /// Maps to: col_nm_colaborador
    /// </summary>
    public string ColNmColaborador { get; set; } = null!;

    /// <summary>
    /// Worker email
    /// Maps to: col_ds_email
    /// </summary>
    public string ColDsEmail { get; set; } = null!;

    /// <summary>
    /// Project ID (part of composite key)
    /// Maps to: obr_id_obra
    /// </summary>
    public int? ObrIdObra { get; set; }

    /// <summary>
    /// Project name/description
    /// Maps to: obr_ds_obra
    /// </summary>
    public string ObrDsObra { get; set; } = null!;

    /// <summary>
    /// Login date/time (part of composite key)
    /// Maps to: data_login
    /// </summary>
    public DateTime DataLogin { get; set; }

    // No navigation properties - this is a denormalized history table
}
