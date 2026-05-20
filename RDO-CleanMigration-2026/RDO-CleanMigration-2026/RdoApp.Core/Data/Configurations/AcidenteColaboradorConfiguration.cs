using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for AcidenteColaborador entity
/// Maps to legacy 'acidente_colaborador' table
/// Note: Legacy table has typo in column name (atastamento instead of afastamento)
/// </summary>
public class AcidenteColaboradorConfiguration : IEntityTypeConfiguration<AcidenteColaborador>
{
    public void Configure(EntityTypeBuilder<AcidenteColaborador> builder)
    {
        // Table mapping
        builder.ToTable("acidente_colaborador");

        // Primary key
        builder.HasKey(e => e.AccIdAcidenteColaborador);
        builder.Property(e => e.AccIdAcidenteColaborador)
            .HasColumnName("acc_id_acidente_colaborador")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.AccIdAcidente)
            .HasColumnName("acc_id_acidente")
            .IsRequired();

        builder.Property(e => e.AccIdObraColaborador)
            .HasColumnName("acc_id_obra_colaborador")
            .IsRequired();

        // Properties - Note: typo in legacy column name (atastamento instead of afastamento)
        builder.Property(e => e.AccStAtastamento)
            .HasColumnName("acc_st_atastamento")
            .HasMaxLength(1)
            .IsUnicode(false);

        // Indexes for foreign keys
        builder.HasIndex(e => e.AccIdAcidente)
            .HasDatabaseName("IX_acidente_colaborador_acidente");

        builder.HasIndex(e => e.AccIdObraColaborador)
            .HasDatabaseName("IX_acidente_colaborador_obra_colaborador");

        // Composite index for unique constraint
        builder.HasIndex(e => new { e.AccIdAcidente, e.AccIdObraColaborador })
            .HasDatabaseName("IX_acidente_colaborador_unique")
            .IsUnique();

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Acidente)
        //     .WithMany(p => p.AcidenteColaboradores)
        //     .HasForeignKey(d => d.AccIdAcidente)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.ObraColaborador)
        //     .WithMany(p => p.AcidenteColaboradores)
        //     .HasForeignKey(d => d.AccIdObraColaborador)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
