using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Models.Entities
{
    [Table("usuario")]
    public class Usuario
    {
        [Key]
        [Column("usu_id_usuario")]
        public int Id { get; set; }

        [Column("usu_ds_email")]
        public string Email { get; set; } = string.Empty;

        [Column("usu_ds_senha")]
        public string Senha { get; set; } = string.Empty;

        [Column("usu_id_grupo")]
        public int GrupoId { get; set; }

        [Column("usu_st_status")]
        public int? Status { get; set; }

        [Column("usu_st_alterar_senha")]
        public int? AlterarSenha { get; set; }

        [Column("col_password_hash")]
        [StringLength(255)]
        public string? PasswordHash { get; set; }

        // Navigation Properties
        public virtual Grupo Grupo { get; set; } = null!;
    }
}