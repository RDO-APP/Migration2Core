using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for RdoTarefa entity
/// Maps to legacy 'rdo_tarefa' table
/// Junction table connecting Rdo to Tarefa
/// </summary>
public class RdoTarefaConfiguration : IEntityTypeConfiguration<RdoTarefa>
{
    public void Configure(EntityTypeBuilder<RdoTarefa> builder)
    {
        // Table mapping
        builder.ToTable("rdo_tarefa");

        // Primary key
        builder.HasKey(e => e.RtaIdRta);
        builder.Property(e => e.RtaIdRta)
            .HasColumnName("rta_id_rta")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.RtaIdRdo)
            .HasColumnName("rta_id_rdo")
            .IsRequired();

        builder.Property(e => e.RtaIdTarefa)
            .HasColumnName("rta_id_tarefa")
            .IsRequired();

        // Indexes for foreign keys
        builder.HasIndex(e => e.RtaIdRdo)
            .HasDatabaseName("IX_rdo_tarefa_rdo");

        builder.HasIndex(e => e.RtaIdTarefa)
            .HasDatabaseName("IX_rdo_tarefa_tarefa");

        // Composite index for unique constraint
        builder.HasIndex(e => new { e.RtaIdRdo, e.RtaIdTarefa })
            .HasDatabaseName("IX_rdo_tarefa_unique")
            .IsUnique();

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Rdo)
        //     .WithMany(p => p.RdoTarefas)
        //     .HasForeignKey(d => d.RtaIdRdo)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Tarefa)
        //     .WithMany(p => p.RdoTarefas)
        //     .HasForeignKey(d => d.RtaIdTarefa)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
