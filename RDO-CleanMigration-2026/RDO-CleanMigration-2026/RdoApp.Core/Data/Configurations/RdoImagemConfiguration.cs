using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for RdoImagem entity
/// Maps to legacy 'rdo_imagem' table
/// Junction table connecting Rdo to Imagem
/// </summary>
public class RdoImagemConfiguration : IEntityTypeConfiguration<RdoImagem>
{
    public void Configure(EntityTypeBuilder<RdoImagem> builder)
    {
        // Table mapping
        builder.ToTable("rdo_imagem");

        // Primary key
        builder.HasKey(e => e.RimIdRdoImagem);
        builder.Property(e => e.RimIdRdoImagem)
            .HasColumnName("rim_id_rdo_imagem")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.RimIdRdo)
            .HasColumnName("rim_id_rdo")
            .IsRequired();

        builder.Property(e => e.RimIdImagem)
            .HasColumnName("rim_id_imagem")
            .IsRequired();

        // Indexes for foreign keys
        builder.HasIndex(e => e.RimIdRdo)
            .HasDatabaseName("IX_rdo_imagem_rdo");

        builder.HasIndex(e => e.RimIdImagem)
            .HasDatabaseName("IX_rdo_imagem_imagem");

        // Composite index for unique constraint
        builder.HasIndex(e => new { e.RimIdRdo, e.RimIdImagem })
            .HasDatabaseName("IX_rdo_imagem_unique")
            .IsUnique();

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Imagem)
        //     .WithMany(p => p.RdoImagens)
        //     .HasForeignKey(d => d.RimIdImagem)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
        //
        // builder.HasOne(d => d.Rdo)
        //     .WithMany(p => p.RdoImagens)
        //     .HasForeignKey(d => d.RimIdRdo)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
