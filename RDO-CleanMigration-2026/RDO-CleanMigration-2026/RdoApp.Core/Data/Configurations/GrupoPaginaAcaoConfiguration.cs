using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class GrupoPaginaAcaoConfiguration : IEntityTypeConfiguration<GrupoPaginaAcao>
{
    public void Configure(EntityTypeBuilder<GrupoPaginaAcao> builder)
    {
        builder.ToTable("grupo_pagina_acao");

        builder.HasKey(e => e.GpaIdGrupoPaginaAcao);

        builder.Property(e => e.GpaIdGrupo)
            .IsRequired();

        builder.Property(e => e.GpaIdPaginaAcao)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.GpaIdGrupo)
            .HasDatabaseName("idx_grupo_pagina_acao_grupo");

        builder.HasIndex(e => e.GpaIdPaginaAcao)
            .HasDatabaseName("idx_grupo_pagina_acao_pagina_acao");

        builder.HasIndex(e => new { e.GpaIdGrupo, e.GpaIdPaginaAcao })
            .IsUnique()
            .HasDatabaseName("idx_grupo_pagina_acao_unique");

        // Navigation properties - commented until all entities are implemented
        // builder.HasOne(e => e.Grupo)
        //     .WithMany(g => g.GrupoPaginaAcoes)
        //     .HasForeignKey(e => e.GpaIdGrupo)
        //     .OnDelete(DeleteBehavior.Restrict);

        // builder.HasOne(e => e.PaginaAcao)
        //     .WithMany(pa => pa.GrupoPaginaAcoes)
        //     .HasForeignKey(e => e.GpaIdPaginaAcao)
        //     .OnDelete(DeleteBehavior.Restrict);
    }
}
