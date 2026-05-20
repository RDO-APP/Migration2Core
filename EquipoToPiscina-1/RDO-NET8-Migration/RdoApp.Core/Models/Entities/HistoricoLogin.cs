using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("historico_login")]
    public class HistoricoLogin
    {
        [Key]
        [Column("col_id_colaborador")]
        public int ColaboradorId { get; set; }

        [Column("col_nr_cpf")]
        public string Cpf { get; set; } = string.Empty;

        [Column("col_nm_colaborador")]
        public string NomeColaborador { get; set; } = string.Empty;

        [Column("col_ds_email")]
        public string Email { get; set; } = string.Empty;

        [Column("obr_id_obra")]
        public int? ObraId { get; set; }

        [Column("obr_ds_obra")]
        public string ObraDescricao { get; set; } = string.Empty;

        [Column("data_login")]
        public DateTime DataLogin { get; set; }

        // Note: This appears to be a view or complex query result
        // Navigation properties may not be appropriate for this entity
    }
}