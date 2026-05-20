using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class PerfilAssinanteConfiguration : IEntityTypeConfiguration<PerfilAssinante>
{
    public void Configure(EntityTypeBuilder<PerfilAssinante> builder)
    {
        builder.ToTable("perfil_assinante");

        builder.HasKey(e => e.PerIdPerfil);

        builder.Property(e => e.PerDsPerfil)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.PerNrQtdObras);

        builder.Property(e => e.PerStAcessoDashboard);

        builder.Property(e => e.PerStAssinaRdo);

        // Indexes
        builder.HasIndex(e => e.PerDsPerfil)
            .HasDatabaseName("idx_perfil_assinante_perfil");

        // Navigation properties - commented until all entities are implemented
        // No foreign keys - PerfilAssinante is a standalone lookup table
    }
}
