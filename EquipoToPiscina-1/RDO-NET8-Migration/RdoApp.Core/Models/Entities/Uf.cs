using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("uf")]
    public class Uf
    {
        [Key]
        [Column("ufe_id_uf")]
        public int Id { get; set; }

        [Column("ufe_ds_uf")]
        public string Descricao { get; set; } = string.Empty;

        [Column("ufe_ds_sigla")]
        public string Sigla { get; set; } = string.Empty;

        // Navigation Properties
        public virtual ICollection<Municipio> Municipios { get; set; } = new List<Municipio>();
    }
}