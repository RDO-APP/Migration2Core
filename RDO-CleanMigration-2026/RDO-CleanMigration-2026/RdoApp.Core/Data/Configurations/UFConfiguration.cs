using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for UF (State) entity
/// Preserves legacy table and column names exactly
/// </summary>
public class UFConfiguration : IEntityTypeConfiguration<UF>
{
    public void Configure(EntityTypeBuilder<UF> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("uf");

        // Primary key
        builder.HasKey(u => u.UfeIdUf);
        builder.Property(u => u.UfeIdUf)
            .HasColumnName("ufe_id_uf")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(u => u.UfeDsUf)
            .HasColumnName("ufe_ds_uf")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(u => u.UfeDsSigla)
            .HasColumnName("ufe_ds_sigla")
            .HasMaxLength(2)
            .IsRequired();

        // Indexes
        builder.HasIndex(u => u.UfeDsSigla)
            .IsUnique();

        // Relationships configured in Municipio
    }
}
