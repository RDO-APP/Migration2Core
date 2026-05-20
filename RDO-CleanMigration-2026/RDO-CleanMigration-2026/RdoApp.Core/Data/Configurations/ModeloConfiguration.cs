using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Modelo (Model) entity
/// </summary>
public class ModeloConfiguration : IEntityTypeConfiguration<Modelo>
{
    public void Configure(EntityTypeBuilder<Modelo> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("modelo");

        // Primary key
        builder.HasKey(m => m.ModIdModelo);
        builder.Property(m => m.ModIdModelo)
            .HasColumnName("mod_id_modelo")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(m => m.ModDsModelo)
            .HasColumnName("mod_ds_modelo")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(m => m.ModDsObservacao)
            .HasColumnName("mod_ds_observacao")
            .HasMaxLength(500)
            .IsRequired();

        // Indexes
        builder.HasIndex(m => m.ModDsModelo);
    }
}
