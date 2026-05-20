using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class PaginaConfiguration : IEntityTypeConfiguration<Pagina>
{
    public void Configure(EntityTypeBuilder<Pagina> builder)
    {
        builder.ToTable("pagina");

        builder.HasKey(e => e.PagIdPagina);

        builder.Property(e => e.PagDsUrl)
            .IsRequired()
            .HasMaxLength(500);

        builder.Property(e => e.PagNmTitulo)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.PagDsAlias)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.PagStStatus)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.PagDsAlias)
            .HasDatabaseName("idx_pagina_alias");

        builder.HasIndex(e => e.PagStStatus)
            .HasDatabaseName("idx_pagina_status");

        // Navigation properties - commented until all entities are implemented
        // No foreign keys - Pagina is a parent table
    }
}
