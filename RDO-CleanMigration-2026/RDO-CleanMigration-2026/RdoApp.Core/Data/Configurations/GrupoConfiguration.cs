using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class GrupoConfiguration : IEntityTypeConfiguration<Grupo>
{
    public void Configure(EntityTypeBuilder<Grupo> builder)
    {
        builder.ToTable("grupo");

        builder.HasKey(e => e.GruIdGrupo);

        builder.Property(e => e.GruNmNome)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.GruIdMenu)
            .IsRequired();

        builder.Property(e => e.GruIdLicenca);

        builder.Property(e => e.GruStDiretor);

        builder.Property(e => e.GruStContratante);

        // Indexes
        builder.HasIndex(e => e.GruIdMenu)
            .HasDatabaseName("idx_grupo_menu");

        builder.HasIndex(e => e.GruIdLicenca)
            .HasDatabaseName("idx_grupo_licenca");

        // Navigation properties - commented until all entities are implemented
        // builder.HasOne(e => e.Licenca)
        //     .WithMany()
        //     .HasForeignKey(e => e.GruIdLicenca)
        //     .OnDelete(DeleteBehavior.Restrict);

        // builder.HasOne(e => e.Menu)
        //     .WithMany(m => m.Grupos)
        //     .HasForeignKey(e => e.GruIdMenu)
        //     .OnDelete(DeleteBehavior.Restrict);
    }
}
