using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for ObraTarefaEquipamento entity
/// Maps to legacy 'obra_tarefa_equipamento' table
/// Junction table connecting ObraEquipamento to Tarefa
/// Note: Legacy table has typo in column name (euipamento instead of equipamento)
/// </summary>
public class ObraTarefaEquipamentoConfiguration : IEntityTypeConfiguration<ObraTarefaEquipamento>
{
    public void Configure(EntityTypeBuilder<ObraTarefaEquipamento> builder)
    {
        // Table mapping
        builder.ToTable("obra_tarefa_equipamento");

        // Primary key - Note: typo in legacy column name (euipamento instead of equipamento)
        builder.HasKey(e => e.OteIdObraTarefaEuipamento);
        builder.Property(e => e.OteIdObraTarefaEuipamento)
            .HasColumnName("ote_id_obra_tarefa_euipamento")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.OteIdObraEquipamento)
            .HasColumnName("ote_id_obra_equipamento")
            .IsRequired();

        builder.Property(e => e.OteIdTarefa)
            .HasColumnName("ote_id_tarefa")
            .IsRequired();

        // Indexes for foreign keys
        builder.HasIndex(e => e.OteIdObraEquipamento)
            .HasDatabaseName("IX_obra_tarefa_equipamento_obra_equipamento");

        builder.HasIndex(e => e.OteIdTarefa)
            .HasDatabaseName("IX_obra_tarefa_equipamento_tarefa");

        // Composite index for unique constraint
        builder.HasIndex(e => new { e.OteIdObraEquipamento, e.OteIdTarefa })
            .HasDatabaseName("IX_obra_tarefa_equipamento_unique")
            .IsUnique();

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.ObraEquipamento)
        //     .WithMany(p => p.ObraTarefaEquipamentos)
        //     .HasForeignKey(d => d.OteIdObraEquipamento)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Tarefa)
        //     .WithMany(p => p.ObraTarefaEquipamentos)
        //     .HasForeignKey(d => d.OteIdTarefa)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
