using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Efetivo entity
/// Maps to legacy 'efetivo' table
/// </summary>
public class EfetivoConfiguration : IEntityTypeConfiguration<Efetivo>
{
    public void Configure(EntityTypeBuilder<Efetivo> builder)
    {
        // Table mapping
        builder.ToTable("efetivo");

        // Primary key
        builder.HasKey(e => e.EfeIdEfetivo);
        builder.Property(e => e.EfeIdEfetivo)
            .HasColumnName("efe_id_efetivo")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.EfeIdObra)
            .HasColumnName("efe_id_obra")
            .IsRequired();

        builder.Property(e => e.EfeIdObraColaborador)
            .HasColumnName("efe_id_obra_colaborador")
            .IsRequired();

        builder.Property(e => e.EfeIdEfetivoStatus)
            .HasColumnName("efe_id_efetivo_status")
            .IsRequired();

        // Properties
        builder.Property(e => e.EfeData)
            .HasColumnName("efe_data")
            .HasColumnType("datetime")
            .IsRequired();

        // Indexes for foreign keys
        builder.HasIndex(e => e.EfeIdObra)
            .HasDatabaseName("IX_efetivo_obra");

        builder.HasIndex(e => e.EfeIdObraColaborador)
            .HasDatabaseName("IX_efetivo_obra_colaborador");

        builder.HasIndex(e => e.EfeIdEfetivoStatus)
            .HasDatabaseName("IX_efetivo_status");

        // Index for date queries
        builder.HasIndex(e => e.EfeData)
            .HasDatabaseName("IX_efetivo_data");

        // Composite index for unique constraint (one record per worker per day)
        builder.HasIndex(e => new { e.EfeIdObraColaborador, e.EfeData })
            .HasDatabaseName("IX_efetivo_colaborador_data")
            .IsUnique();

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Obra)
        //     .WithMany(p => p.Efetivos)
        //     .HasForeignKey(d => d.EfeIdObra)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.ObraColaborador)
        //     .WithMany(p => p.Efetivos)
        //     .HasForeignKey(d => d.EfeIdObraColaborador)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.EfetivoStatus)
        //     .WithMany(p => p.Efetivos)
        //     .HasForeignKey(d => d.EfeIdEfetivoStatus)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
