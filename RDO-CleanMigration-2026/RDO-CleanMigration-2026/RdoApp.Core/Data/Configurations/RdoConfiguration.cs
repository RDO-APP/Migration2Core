using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Rdo entity
/// Maps to legacy 'rdo' table
/// </summary>
public class RdoConfiguration : IEntityTypeConfiguration<Rdo>
{
    public void Configure(EntityTypeBuilder<Rdo> builder)
    {
        // Table mapping
        builder.ToTable("rdo");

        // Primary key
        builder.HasKey(e => e.RdoIdRdo);
        builder.Property(e => e.RdoIdRdo)
            .HasColumnName("rdo_id_rdo")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.RdoIdStatus)
            .HasColumnName("rdo_id_status")
            .IsRequired();

        builder.Property(e => e.RdoIdObra)
            .HasColumnName("rdo_id_obra")
            .IsRequired();

        builder.Property(e => e.RdoIdColaborador)
            .HasColumnName("rdo_id_colaborador");

        builder.Property(e => e.RdoIdImprodutividade)
            .HasColumnName("rdo_id_improdutividade")
            .IsRequired();

        // Properties
        builder.Property(e => e.RdoDtRdo)
            .HasColumnName("rdo_dt_rdo")
            .HasColumnType("datetime")
            .IsRequired();

        builder.Property(e => e.RdoDsComentarioAssinatura)
            .HasColumnName("rdo_ds_comentario_assinatura")
            .HasMaxLength(500)
            .IsUnicode(false);

        builder.Property(e => e.RdoDsClimaManha)
            .HasColumnName("rdo_ds_clima_manha")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.RdoDsClimaTarde)
            .HasColumnName("rdo_ds_clima_tarde")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.RdoDsClimaNoite)
            .HasColumnName("rdo_ds_clima_noite")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.RdoDsChuvaManha)
            .HasColumnName("rdo_ds_chuva_manha")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.RdoDsChuvaTarde)
            .HasColumnName("rdo_ds_chuva_tarde")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.RdoDsChuvaNoite)
            .HasColumnName("rdo_ds_chuva_noite")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.RdoDtGeracao)
            .HasColumnName("rdo_dt_geracao")
            .HasColumnType("datetime");

        builder.Property(e => e.RdoTpComentarioAssinatura)
            .HasColumnName("rdo_tp_comentario_assinatura")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.RdoDsComentarioGeracao)
            .HasColumnName("rdo_ds_comentario_geracao")
            .HasMaxLength(500)
            .IsUnicode(false);

        builder.Property(e => e.RdoTpComentarioGeracao)
            .HasColumnName("rdo_tp_comentario_geracao")
            .HasMaxLength(1)
            .IsUnicode(false);

        // Indexes for foreign keys
        builder.HasIndex(e => e.RdoIdStatus)
            .HasDatabaseName("IX_rdo_status");

        builder.HasIndex(e => e.RdoIdObra)
            .HasDatabaseName("IX_rdo_obra");

        builder.HasIndex(e => e.RdoIdColaborador)
            .HasDatabaseName("IX_rdo_colaborador");

        builder.HasIndex(e => e.RdoIdImprodutividade)
            .HasDatabaseName("IX_rdo_improdutividade");

        // Index for date queries
        builder.HasIndex(e => e.RdoDtRdo)
            .HasDatabaseName("IX_rdo_data");

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Colaborador)
        //     .WithMany(p => p.Rdos)
        //     .HasForeignKey(d => d.RdoIdColaborador)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Improdutividade)
        //     .WithMany(p => p.Rdos)
        //     .HasForeignKey(d => d.RdoIdImprodutividade)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Obra)
        //     .WithMany(p => p.Rdos)
        //     .HasForeignKey(d => d.RdoIdObra)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.StatusRdo)
        //     .WithMany(p => p.Rdos)
        //     .HasForeignKey(d => d.RdoIdStatus)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
