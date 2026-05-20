using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for UnidadeDeMedida (Unit of Measurement) entity
/// </summary>
public class UnidadeDeMedidaConfiguration : IEntityTypeConfiguration<UnidadeDeMedida>
{
    public void Configure(EntityTypeBuilder<UnidadeDeMedida> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("unidade_de_medida");

        // Primary key
        builder.HasKey(u => u.UnmIdUnidade);
        builder.Property(u => u.UnmIdUnidade)
            .HasColumnName("unm_id_unidade")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(u => u.UnmDsUnidade)
            .HasColumnName("unm_ds_unidade")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(u => u.UnmDsSimbolo)
            .HasColumnName("unm_ds_simbolo")
            .HasMaxLength(20)
            .IsRequired();

        // Indexes
        builder.HasIndex(u => u.UnmDsUnidade);
        builder.HasIndex(u => u.UnmDsSimbolo);
    }
}
