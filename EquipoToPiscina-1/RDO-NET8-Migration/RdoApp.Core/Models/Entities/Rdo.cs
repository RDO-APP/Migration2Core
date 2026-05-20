using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("rdo")]
    public class Rdo
    {
        // Primary Key
        [Key]
        [Column("rdo_id_rdo")]
        public int Id { get; set; }
        
        // Foreign Keys
        [Column("rdo_id_obra")]
        public int ObraId { get; set; }
        
        [Column("rdo_id_colaborador")]
        public int? ColaboradorId { get; set; }
        
        // Core Fields
        [Column("rdo_dt_data")]
        public DateTime Data { get; set; }
        
        [Column("rdo_ds_observacao")]
        public string? Observacao { get; set; }
        
        [Column("rdo_nr_temperatura")]
        public decimal? Temperatura { get; set; }
        
        [Column("rdo_ds_condicoes_tempo")]
        public string? CondicoesTempo { get; set; }
        
        // Status and Control
        [Column("rdo_st_status")]
        public string? Status { get; set; }
        
        [Column("rdo_dt_criacao")]
        public DateTime DataCriacao { get; set; }
        
        [Column("rdo_dt_atualizacao")]
        public DateTime? DataAtualizacao { get; set; }
        
        // Navigation Properties
        public virtual Obra? Obra { get; set; }
        public virtual Colaborador? Colaborador { get; set; }
        public virtual ICollection<RdoTarefa>? RdoTarefas { get; set; }
    }
}