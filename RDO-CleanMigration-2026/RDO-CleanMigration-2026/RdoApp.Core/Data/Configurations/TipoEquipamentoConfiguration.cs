using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for TipoEquipamento (Equipment Type) entity
/// </summary>
public class TipoEquipamentoConfiguration : IEntityTypeConfiguration<TipoEquipamento>
{
    public void Configure(EntityTypeBuilder<TipoEquipamento> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("tipo_equipamento");

        // Primary key
        builder.HasKey(t => t.TeqIdTipoEquipamento);
        builder.Property(t => t.TeqIdTipoEquipamento)
            .HasColumnName("teq_id_tipo_equipamento")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(t => t.TeqNmTipoEquipamento)
            .HasColumnName("teq_nm_tipo_equipamento")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(t => t.TeqDsTipoEquipamento)
            .HasColumnName("teq_ds_tipo_equipamento")
            .HasMaxLength(255)
            .IsRequired();

        // Indexes
        builder.HasIndex(t => t.TeqNmTipoEquipamento);
    }
}
