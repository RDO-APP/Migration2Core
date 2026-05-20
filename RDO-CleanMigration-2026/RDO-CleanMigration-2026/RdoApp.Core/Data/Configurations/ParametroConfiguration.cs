using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class ParametroConfiguration : IEntityTypeConfiguration<Parametro>
{
    public void Configure(EntityTypeBuilder<Parametro> builder)
    {
        builder.ToTable("parametro");

        builder.HasKey(e => e.ParIdParametro);

        builder.Property(e => e.ParDsParametro)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.ParVlParametro)
            .IsRequired()
            .HasMaxLength(500);

        // Indexes
        builder.HasIndex(e => e.ParDsParametro)
            .IsUnique()
            .HasDatabaseName("idx_parametro_descricao");

        // Navigation properties - commented until all entities are implemented
        // No foreign keys - Parametro is a standalone configuration table
    }
}
