using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class MenuPaginaConfiguration : IEntityTypeConfiguration<MenuPagina>
{
    public void Configure(EntityTypeBuilder<MenuPagina> builder)
    {
        builder.ToTable("menu_pagina");

        builder.HasKey(e => e.MpaIdMenuPagina);

        builder.Property(e => e.MpaIdMenu)
            .IsRequired();

        builder.Property(e => e.MpaIdPagina)
            .IsRequired();

        builder.Property(e => e.MpaIdPaginaPai);

        builder.Property(e => e.MpaVlNivel)
            .IsRequired();

        builder.Property(e => e.MpaVlOrdem)
            .IsRequired();

        builder.Property(e => e.MpaDsClass)
            .IsRequired()
            .HasMaxLength(255);

        // Indexes
        builder.HasIndex(e => e.MpaIdMenu)
            .HasDatabaseName("idx_menu_pagina_menu");

        builder.HasIndex(e => e.MpaIdPagina)
            .HasDatabaseName("idx_menu_pagina_pagina");

        builder.HasIndex(e => e.MpaIdPaginaPai)
            .HasDatabaseName("idx_menu_pagina_pai");

        builder.HasIndex(e => new { e.MpaIdMenu, e.MpaVlOrdem })
            .HasDatabaseName("idx_menu_pagina_menu_ordem");

        // Navigation properties - commented until all entities are implemented
        // builder.HasOne(e => e.Menu)
        //     .WithMany(m => m.MenuPaginas)
        //     .HasForeignKey(e => e.MpaIdMenu)
        //     .OnDelete(DeleteBehavior.Restrict);

        // builder.HasOne(e => e.Pagina)
        //     .WithMany(p => p.MenuPaginas)
        //     .HasForeignKey(e => e.MpaIdPagina)
        //     .OnDelete(DeleteBehavior.Restrict);

        // Self-referencing relationship for hierarchy
        // builder.HasOne(e => e.MenuPaginaPai)
        //     .WithMany(mp => mp.MenuPaginasFilhas)
        //     .HasForeignKey(e => e.MpaIdPaginaPai)
        //     .OnDelete(DeleteBehavior.Restrict);
    }
}
