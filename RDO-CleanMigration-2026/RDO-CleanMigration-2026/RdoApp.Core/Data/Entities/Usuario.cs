using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Usuario (User) - System users with authentication credentials
/// Table: usuario
/// </summary>
[Table("usuario")]
public class Usuario
{
    [Key]
    [Column("usu_id_usuario")]
    public int UsuIdUsuario { get; set; }

    [Column("usu_ds_email")]
    [StringLength(255)]
    public string UsuDsEmail { get; set; } = string.Empty;

    [Column("usu_ds_senha")]
    [StringLength(255)]
    public string UsuDsSenha { get; set; } = string.Empty;

    [Column("usu_id_grupo")]
    public int UsuIdGrupo { get; set; }

    [Column("usu_st_status")]
    public int? UsuStStatus { get; set; }

    [Column("usu_st_alterar_senha")]
    public int? UsuStAlterarSenha { get; set; }

    // Navigation properties - commented until all entities are implemented
    // public virtual Grupo? Grupo { get; set; }
}
