using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class AcaoConfiguration : IEntityTypeConfiguration<Acao>
{
    public void Configure(EntityTypeBuilder<Acao> builder)
    {
        builder.ToTable("acao");

        builder.HasKey(e => e.AcaIdAcao);

        builder.Property(e => e.AcaDsAcao)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.AcaDsAlias)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.AcaVlOrdem)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.AcaDsAlias)
            .HasDatabaseName("idx_acao_alias");

        builder.HasIndex(e => e.AcaVlOrdem)
            .HasDatabaseName("idx_acao_ordem");

        // Navigation properties - commented until all entities are implemented
        // No foreign keys - Acao is a parent table
    }
}
