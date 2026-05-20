using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Etapa (Stage/Phase) entity
/// </summary>
public class EtapaConfiguration : IEntityTypeConfiguration<Etapa>
{
    public void Configure(EntityTypeBuilder<Etapa> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("etapa");

        // Primary key
        builder.HasKey(e => e.EtaIdEtapa);
        builder.Property(e => e.EtaIdEtapa)
            .HasColumnName("eta_id_etapa")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.EtaIdObra)
            .HasColumnName("eta_id_obra")
            .IsRequired();

        // Properties
        builder.Property(e => e.EtaDsEtapa)
            .HasColumnName("eta_ds_etapa")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(e => e.EtaNrOrderm)
            .HasColumnName("eta_nr_orderm")
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.EtaIdObra);
        builder.HasIndex(e => e.EtaNrOrderm);
        builder.HasIndex(e => new { e.EtaIdObra, e.EtaNrOrderm }); // Composite index for ordering within project
    }
}
