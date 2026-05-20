using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for ObraTarefaColaborador entity
/// Maps to legacy 'obra_tarefa_colaborador' table
/// Junction table connecting ObraColaborador to Tarefa
/// </summary>
public class ObraTarefaColaboradorConfiguration : IEntityTypeConfiguration<ObraTarefaColaborador>
{
    public void Configure(EntityTypeBuilder<ObraTarefaColaborador> builder)
    {
        // Table mapping
        builder.ToTable("obra_tarefa_colaborador");

        // Primary key
        builder.HasKey(e => e.OtcIdObraTarefaColaborador);
        builder.Property(e => e.OtcIdObraTarefaColaborador)
            .HasColumnName("otc_id_obra_tarefa_colaborador")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.OtcIdObraColaborador)
            .HasColumnName("otc_id_obra_colaborador")
            .IsRequired();

        builder.Property(e => e.OtcIdTarefa)
            .HasColumnName("otc_id_tarefa")
            .IsRequired();

        // Indexes for foreign keys
        builder.HasIndex(e => e.OtcIdObraColaborador)
            .HasDatabaseName("IX_obra_tarefa_colaborador_obra_colaborador");

        builder.HasIndex(e => e.OtcIdTarefa)
            .HasDatabaseName("IX_obra_tarefa_colaborador_tarefa");

        // Composite index for unique constraint
        builder.HasIndex(e => new { e.OtcIdObraColaborador, e.OtcIdTarefa })
            .HasDatabaseName("IX_obra_tarefa_colaborador_unique")
            .IsUnique();

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.ObraColaborador)
        //     .WithMany(p => p.ObraTarefaColaboradores)
        //     .HasForeignKey(d => d.OtcIdObraColaborador)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Tarefa)
        //     .WithMany(p => p.ObraTarefaColaboradores)
        //     .HasForeignKey(d => d.OtcIdTarefa)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
