using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Laudo entity
/// Maps to legacy 'laudo' table
/// </summary>
public class LaudoConfiguration : IEntityTypeConfiguration<Laudo>
{
    public void Configure(EntityTypeBuilder<Laudo> builder)
    {
        // Table mapping
        builder.ToTable("laudo");

        // Primary key
        builder.HasKey(e => e.LauIdLaudo);
        builder.Property(e => e.LauIdLaudo)
            .HasColumnName("lau_id_laudo")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.LauIdStatus)
            .HasColumnName("lau_id_status")
            .IsRequired();

        builder.Property(e => e.LauIdObra)
            .HasColumnName("lau_id_obra")
            .IsRequired();

        builder.Property(e => e.LauIdColaborador)
            .HasColumnName("lau_id_colaborador");

        // Properties
        builder.Property(e => e.LauDtLaudo)
            .HasColumnName("lau_dt_laudo")
            .HasColumnType("datetime")
            .IsRequired();

        builder.Property(e => e.LauDsComentarioAssinatura)
            .HasColumnName("lau_ds_comentario_assinatura")
            .HasMaxLength(500)
            .IsUnicode(false);

        builder.Property(e => e.LauDtGeracao)
            .HasColumnName("lau_dt_geracao")
            .HasColumnType("datetime");

        builder.Property(e => e.LauTpComentarioAssinatura)
            .HasColumnName("lau_tp_comentario_assinatura")
            .HasMaxLength(1)
            .IsUnicode(false);

        builder.Property(e => e.LauDsComentarioGeracao)
            .HasColumnName("lau_ds_comentario_geracao")
            .HasMaxLength(500)
            .IsUnicode(false);

        builder.Property(e => e.LauTpComentarioGeracao)
            .HasColumnName("lau_tp_comentario_geracao")
            .HasMaxLength(1)
            .IsUnicode(false);

        // Water quality check boolean fields
        builder.Property(e => e.LauTpNivelCloro)
            .HasColumnName("lau_tp_nivel_cloro");

        builder.Property(e => e.LauTpPh)
            .HasColumnName("lau_tp_ph");

        builder.Property(e => e.LauTpLimpidez)
            .HasColumnName("lau_tp_limpidez");

        builder.Property(e => e.LauTpSuperficie)
            .HasColumnName("lau_tp_superficie");

        builder.Property(e => e.LauTpFundo)
            .HasColumnName("lau_tp_fundo");

        builder.Property(e => e.LauTpNivelCloro2)
            .HasColumnName("lau_tp_nivel_cloro_2");

        builder.Property(e => e.LauTpNivelBacterias)
            .HasColumnName("lau_tp_nivel_bacterias");

        builder.Property(e => e.LauTpNivelProliferacao)
            .HasColumnName("lau_tp_nivel_proliferacao");

        // Indexes for foreign keys
        builder.HasIndex(e => e.LauIdStatus)
            .HasDatabaseName("IX_laudo_status");

        builder.HasIndex(e => e.LauIdObra)
            .HasDatabaseName("IX_laudo_obra");

        builder.HasIndex(e => e.LauIdColaborador)
            .HasDatabaseName("IX_laudo_colaborador");

        // Index for date queries
        builder.HasIndex(e => e.LauDtLaudo)
            .HasDatabaseName("IX_laudo_data");

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Colaborador)
        //     .WithMany(p => p.Laudos)
        //     .HasForeignKey(d => d.LauIdColaborador)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Obra)
        //     .WithMany(p => p.Laudos)
        //     .HasForeignKey(d => d.LauIdObra)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Status)
        //     .WithMany(p => p.Laudos)
        //     .HasForeignKey(d => d.LauIdStatus)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
