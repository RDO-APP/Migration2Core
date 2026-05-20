using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("improdutividade")]
    public class Improdutividade
    {
        [Key]
        [Column("imp_id_improdutividade")]
        public int Id { get; set; }

        [Column("imp_st_clima")]
        public bool Clima { get; set; }

        [Column("imp_st_material")]
        public bool Material { get; set; }

        [Column("imp_st_paralizacao")]
        public bool Paralizacao { get; set; }

        [Column("imp_st_equipamento")]
        public bool Equipamento { get; set; }

        [Column("imp_st_contratante")]
        public bool Contratante { get; set; }

        [Column("imp_st_fornecedores")]
        public bool Fornecedores { get; set; }

        [Column("imp_st_maodeobra")]
        public bool MaoDeObra { get; set; }

        [Column("imp_st_projeto")]
        public bool Projeto { get; set; }

        [Column("imp_st_planejamento")]
        public bool Planejamento { get; set; }

        [Column("imp_st_acidentes")]
        public bool Acidentes { get; set; }

        // Navigation Properties
        public virtual ICollection<Rdo> Rdos { get; set; } = new List<Rdo>();
    }
}