using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for AssinaturaRdo entity
/// Maps to legacy 'assinatura_rdo' table
/// </summary>
public class AssinaturaRdoConfiguration : IEntityTypeConfiguration<AssinaturaRdo>
{
    public void Configure(EntityTypeBuilder<AssinaturaRdo> builder)
    {
        // Table mapping
        builder.ToTable("assinatura_rdo");

        // Primary key
        builder.HasKey(e => e.AssIdAssinatura);
        builder.Property(e => e.AssIdAssinatura)
            .HasColumnName("ass_id_assinatura")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.AssIdObraColaboradorAssinante)
            .HasColumnName("ass_id_obra_colaborador_assinante")
            .IsRequired();

        builder.Property(e => e.AssIdRdo)
            .HasColumnName("ass_id_rdo")
            .IsRequired();

        // Properties
        builder.Property(e => e.AssDsIp)
            .HasColumnName("ass_ds_ip")
            .HasMaxLength(20)
            .IsUnicode(false);

        builder.Property(e => e.AssDtAssinatura)
            .HasColumnName("ass_dt_assinatura")
            .HasColumnType("datetime");

        // Indexes for foreign keys
        builder.HasIndex(e => e.AssIdObraColaboradorAssinante)
            .HasDatabaseName("IX_assinatura_rdo_obra_colaborador");

        builder.HasIndex(e => e.AssIdRdo)
            .HasDatabaseName("IX_assinatura_rdo_rdo");

        // Index for date queries
        builder.HasIndex(e => e.AssDtAssinatura)
            .HasDatabaseName("IX_assinatura_rdo_data");

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.ObraColaborador)
        //     .WithMany(p => p.AssinaturaRdos)
        //     .HasForeignKey(d => d.AssIdObraColaboradorAssinante)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Rdo)
        //     .WithMany(p => p.AssinaturaRdos)
        //     .HasForeignKey(d => d.AssIdRdo)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
