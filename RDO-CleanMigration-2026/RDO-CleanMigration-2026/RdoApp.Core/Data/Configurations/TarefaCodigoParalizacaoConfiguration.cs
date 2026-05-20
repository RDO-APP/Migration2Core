using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

/// <summary>
/// Fluent API configuration for TarefaCodigoParalizacao (Task Stoppage Code) entity
/// </summary>
public class TarefaCodigoParalizacaoConfiguration : IEntityTypeConfiguration<TarefaCodigoParalizacao>
{
    public void Configure(EntityTypeBuilder<TarefaCodigoParalizacao> builder)
    {
        // Table name (preserve legacy name)
        builder.ToTable("tarefa_codigo_paralizacao");

        // Primary key (string)
        builder.HasKey(t => t.TarcpCodigoParalizacao);
        builder.Property(t => t.TarcpCodigoParalizacao)
            .HasColumnName("tarcp_codigo_paralizacao")
            .HasMaxLength(50)
            .IsRequired();

        // Properties
        builder.Property(t => t.TarcpDsParalizacao)
            .HasColumnName("tarcp_ds_paralizacao")
            .HasMaxLength(255)
            .IsRequired();

        // Indexes
        builder.HasIndex(t => t.TarcpDsParalizacao);
    }
}
