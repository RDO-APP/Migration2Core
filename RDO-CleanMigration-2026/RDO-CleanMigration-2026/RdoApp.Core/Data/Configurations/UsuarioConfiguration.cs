using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class UsuarioConfiguration : IEntityTypeConfiguration<Usuario>
{
    public void Configure(EntityTypeBuilder<Usuario> builder)
    {
        builder.ToTable("usuario");

        builder.HasKey(e => e.UsuIdUsuario);

        builder.Property(e => e.UsuDsEmail)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.UsuDsSenha)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.UsuIdGrupo)
            .IsRequired();

        builder.Property(e => e.UsuStStatus);

        builder.Property(e => e.UsuStAlterarSenha);

        // Indexes
        builder.HasIndex(e => e.UsuDsEmail)
            .HasDatabaseName("idx_usuario_email");

        builder.HasIndex(e => e.UsuIdGrupo)
            .HasDatabaseName("idx_usuario_grupo");

        // Navigation properties - commented until all entities are implemented
        // builder.HasOne(e => e.Grupo)
        //     .WithMany(g => g.Usuarios)
        //     .HasForeignKey(e => e.UsuIdGrupo)
        //     .OnDelete(DeleteBehavior.Restrict);
    }
}
