using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Acidente entity
/// Maps to legacy 'acidente' table
/// </summary>
public class AcidenteConfiguration : IEntityTypeConfiguration<Acidente>
{
    public void Configure(EntityTypeBuilder<Acidente> builder)
    {
        // Table mapping
        builder.ToTable("acidente");

        // Primary key
        builder.HasKey(e => e.AciIdAcidente);
        builder.Property(e => e.AciIdAcidente)
            .HasColumnName("aci_id_acidente")
            .ValueGeneratedOnAdd();

        // Foreign keys
        builder.Property(e => e.AciIdTarefa)
            .HasColumnName("aci_id_tarefa")
            .IsRequired();

        // Properties
        builder.Property(e => e.AciDsAcidente)
            .HasColumnName("aci_ds_acidente")
            .HasMaxLength(500)
            .IsUnicode(false);

        builder.Property(e => e.AciDtDataHora)
            .HasColumnName("aci_dt_data_hora")
            .HasColumnType("datetime");

        builder.Property(e => e.AciStAfastamento)
            .HasColumnName("aci_st_afastamento")
            .HasMaxLength(1)
            .IsUnicode(false);

        // Indexes for foreign keys
        builder.HasIndex(e => e.AciIdTarefa)
            .HasDatabaseName("IX_acidente_tarefa");

        // Index for date queries
        builder.HasIndex(e => e.AciDtDataHora)
            .HasDatabaseName("IX_acidente_data");

        // Relationships will be configured when related entities are fully implemented
        // builder.HasOne(d => d.Tarefa)
        //     .WithMany(p => p.Acidentes)
        //     .HasForeignKey(d => d.AciIdTarefa)
        //     .OnDelete(DeleteBehavior.ClientSetNull);
    }
}
