using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class PaginaAcaoConfiguration : IEntityTypeConfiguration<PaginaAcao>
{
    public void Configure(EntityTypeBuilder<PaginaAcao> builder)
    {
        builder.ToTable("pagina_acao");

        builder.HasKey(e => e.PaaIdPaginaAcao);

        builder.Property(e => e.PaaIdPagina)
            .IsRequired();

        builder.Property(e => e.PaaIdAcao)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.PaaIdPagina)
            .HasDatabaseName("idx_pagina_acao_pagina");

        builder.HasIndex(e => e.PaaIdAcao)
            .HasDatabaseName("idx_pagina_acao_acao");

        builder.HasIndex(e => new { e.PaaIdPagina, e.PaaIdAcao })
            .IsUnique()
            .HasDatabaseName("idx_pagina_acao_unique");

        // Navigation properties - commented until all entities are implemented
        // builder.HasOne(e => e.Acao)
        //     .WithMany(a => a.PaginaAcoes)
        //     .HasForeignKey(e => e.PaaIdAcao)
        //     .OnDelete(DeleteBehavior.Restrict);

        // builder.HasOne(e => e.Pagina)
        //     .WithMany(p => p.PaginaAcoes)
        //     .HasForeignKey(e => e.PaaIdPagina)
        //     .OnDelete(DeleteBehavior.Restrict);
    }
}
