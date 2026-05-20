using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for EfetivoStatus (Workforce Status) entity
/// </summary>
public class EfetivoStatusConfiguration : IEntityTypeConfiguration<EfetivoStatus>
{
    public void Configure(EntityTypeBuilder<EfetivoStatus> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("efetivo_status");

        // Primary key
        builder.HasKey(e => e.EstIdEfetivoStatus);
        builder.Property(e => e.EstIdEfetivoStatus)
            .HasColumnName("est_id_efetivo_status")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(e => e.EstDsEfetivoStatus)
            .HasColumnName("est_ds_efetivo_status")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(e => e.EstDsColor)
            .HasColumnName("est_ds_color")
            .HasMaxLength(20)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.EstDsEfetivoStatus);
    }
}
