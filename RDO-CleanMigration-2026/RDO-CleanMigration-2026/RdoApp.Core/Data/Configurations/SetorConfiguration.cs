using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Setor (Department/Sector) entity
/// </summary>
public class SetorConfiguration : IEntityTypeConfiguration<Setor>
{
    public void Configure(EntityTypeBuilder<Setor> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("setor");

        // Primary key
        builder.HasKey(s => s.SetIdSetor);
        builder.Property(s => s.SetIdSetor)
            .HasColumnName("set_id_setor")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(s => s.SetDsSetor)
            .HasColumnName("set_ds_setor")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(s => s.SetIdSetorLoja)
            .HasColumnName("set_id_setor_loja")
            .HasMaxLength(50);

        // Indexes
        builder.HasIndex(s => s.SetDsSetor);
    }
}
