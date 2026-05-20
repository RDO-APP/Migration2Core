using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for ObraEquipamento entity
/// Maps to legacy 'obra_equipamento' table
/// </summary>
public class ObraEquipamentoConfiguration : IEntityTypeConfiguration<ObraEquipamento>
{
    public void Configure(EntityTypeBuilder<ObraEquipamento> builder)
    {
        // Table mapping
        builder.ToTable("obra_equipamento");

        // Primary key
        builder.HasKey(e => e.OeqIdObraEquipamento);
        builder.Property(e => e.OeqIdObraEquipamento)
            .HasColumnName("oeq_id_obra_equipamento")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.OeqIdObra)
            .HasColumnName("oeq_id_obra")
            .IsRequired();

        builder.Property(e => e.OeqIdEquipamento)
            .HasColumnName("oeq_id_equipamento")
            .IsRequired();

        // Properties
        builder.Property(e => e.OeqTpAquisicao)
            .HasColumnName("oeq_tp_aquisicao")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.OeqDsFabricanteFornecedor)
            .HasColumnName("oeq_ds_fabricante_fornecedor")
            .HasMaxLength(100)
            .IsUnicode(false);

        builder.Property(e => e.OeqDtAquisicao)
            .HasColumnName("oeq_dt_aquisicao")
            .HasColumnType("datetime");

        builder.Property(e => e.OeqDsContato)
            .HasColumnName("oeq_ds_contato")
            .HasMaxLength(100)
            .IsUnicode(false);

        builder.Property(e => e.OeqDsTelefone)
            .HasColumnName("oeq_ds_telefone")
            .HasMaxLength(20)
            .IsUnicode(false);

        // Indexes for foreign keys
        builder.HasIndex(e => e.OeqIdObra)
            .HasDatabaseName("IX_obra_equipamento_obra");

        builder.HasIndex(e => e.OeqIdEquipamento)
            .HasDatabaseName("IX_obra_equipamento_equipamento");

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Equipamento)
        //     .WithMany(p => p.ObraEquipamentos)
        //     .HasForeignKey(d => d.OeqIdEquipamento)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Obra)
        //     .WithMany(p => p.ObraEquipamentos)
        //     .HasForeignKey(d => d.OeqIdObra)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
