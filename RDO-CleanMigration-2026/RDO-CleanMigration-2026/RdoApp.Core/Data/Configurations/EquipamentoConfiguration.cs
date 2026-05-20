using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Equipamento (Equipment) entity
/// </summary>
public class EquipamentoConfiguration : IEntityTypeConfiguration<Equipamento>
{
    public void Configure(EntityTypeBuilder<Equipamento> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("equipamento");

        // Primary key
        builder.HasKey(e => e.EquIdEquipamento);
        builder.Property(e => e.EquIdEquipamento)
            .HasColumnName("equ_id_equipamento")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.EquIdTipoEquipamento)
            .HasColumnName("equ_id_tipo_equipamento")
            .IsRequired();

        // Properties
        builder.Property(e => e.EquDsEquipamento)
            .HasColumnName("equ_ds_equipamento")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.EquDsMarca)
            .HasColumnName("equ_ds_marca")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(e => e.EquDsModelo)
            .HasColumnName("equ_ds_modelo")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(e => e.EquDsImagem)
            .HasColumnName("equ_ds_imagem")
            .HasMaxLength(255)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.EquDsEquipamento);
        builder.HasIndex(e => e.EquIdTipoEquipamento);
        builder.HasIndex(e => e.EquDsMarca);
        builder.HasIndex(e => e.EquDsModelo);
    }
}
