using Microsoft.AspNetCore.Identity;

namespace RdoApp.Core.Data.Entities;

/// <summary>
/// Application user extending ASP.NET Core Identity
/// Links to legacy USUARIO and GRUPO tables
/// </summary>
public class ApplicationUser : IdentityUser
{
    /// <summary>
    /// Link to legacy USUARIO table
    /// </summary>
    public int? UsuIdUsuario { get; set; }

    /// <summary>
    /// Link to GRUPO (security group) for RBAC
    /// </summary>
    public int? GrupoId { get; set; }

    /// <summary>
    /// Active status (1 = active, 0 = inactive)
    /// </summary>
    public int? StatusAtivo { get; set; }

    /// <summary>
    /// Flag indicating if user must change password on next login
    /// </summary>
    public int? AlterarSenha { get; set; }

    // Navigation properties will be added when Usuario and Grupo entities are fully implemented
    // public virtual Usuario? Usuario { get; set; }
    // public virtual Grupo? Grupo { get; set; }
}
