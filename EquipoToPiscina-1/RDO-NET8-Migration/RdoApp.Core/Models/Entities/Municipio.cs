using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("municipio")]
    public class Municipio
    {
        [Key]
        [Column("mun_id_municipio")]
        public int Id { get; set; }

        [Column("mun_id_uf")]
        public int UfId { get; set; }

        [Column("mun_ds_municipio")]
        public string Descricao { get; set; } = string.Empty;

        // Navigation Properties
        public virtual Uf Uf { get; set; } = null!;
        public virtual ICollection<Colaborador> Colaboradores { get; set; } = new List<Colaborador>();
        public virtual ICollection<Empresa> Empresas { get; set; } = new List<Empresa>();
        public virtual ICollection<Obra> Obras { get; set; } = new List<Obra>();
    }
}