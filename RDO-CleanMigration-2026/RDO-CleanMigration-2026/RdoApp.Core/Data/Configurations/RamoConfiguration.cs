using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Ramo (Business Branch/Sector) entity
/// </summary>
public class RamoConfiguration : IEntityTypeConfiguration<Ramo>
{
    public void Configure(EntityTypeBuilder<Ramo> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("ramo");

        // Primary key
        builder.HasKey(r => r.RamIdRamo);
        builder.Property(r => r.RamIdRamo)
            .HasColumnName("ram_id_ramo")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(r => r.RamDsRamo)
            .HasColumnName("ram_ds_ramo")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(r => r.RamIdRamoLoja)
            .HasColumnName("ram_id_ramo_loja")
            .HasMaxLength(50);

        // Indexes
        builder.HasIndex(r => r.RamDsRamo);
    }
}
