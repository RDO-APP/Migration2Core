using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Marca (Brand) entity
/// </summary>
public class MarcaConfiguration : IEntityTypeConfiguration<Marca>
{
    public void Configure(EntityTypeBuilder<Marca> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("marca");

        // Primary key
        builder.HasKey(m => m.MarIdMarca);
        builder.Property(m => m.MarIdMarca)
            .HasColumnName("mar_id_marca")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(m => m.MarDsMarca)
            .HasColumnName("mar_ds_marca")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(m => m.MarDsObservacao)
            .HasColumnName("mar_ds_observacao")
            .HasMaxLength(500)
            .IsRequired();

        // Indexes
        builder.HasIndex(m => m.MarDsMarca);
    }
}
