using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for Municipio (City) entity
/// Preserves legacy table and column names exactly
/// </summary>
public class MunicipioConfiguration : IEntityTypeConfiguration<Municipio>
{
    public void Configure(EntityTypeBuilder<Municipio> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("municipio");

        // Primary key
        builder.HasKey(m => m.MunIdMunicipio);
        builder.Property(m => m.MunIdMunicipio)
            .HasColumnName("mun_id_municipio")
            .ValueGeneratedOnAdd();

        // Properties
        builder.Property(m => m.MunIdUf)
            .HasColumnName("mun_id_uf")
            .IsRequired();

        builder.Property(m => m.MunDsMunicipio)
            .HasColumnName("mun_ds_municipio")
            .HasMaxLength(200)
            .IsRequired();

        // Relationships
        builder.HasOne(m => m.UF)
            .WithMany(u => u.Municipios)
            .HasForeignKey(m => m.MunIdUf)
            .OnDelete(DeleteBehavior.Restrict);

        // Indexes
        builder.HasIndex(m => m.MunIdUf);
        builder.HasIndex(m => m.MunDsMunicipio);
    }
}
