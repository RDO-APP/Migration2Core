using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using RdoApp.Core.Data.Entities;

namespace RdoApp.Core.Data.Configurations;

public class MenuConfiguration : IEntityTypeConfiguration<Menu>
{
    public void Configure(EntityTypeBuilder<Menu> builder)
    {
        builder.ToTable("menu");

        builder.HasKey(e => e.MenIdMenu);

        builder.Property(e => e.MenNmTitulo)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.MenDsAlias)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(e => e.MenStStatus)
            .IsRequired();

        // Indexes
        builder.HasIndex(e => e.MenDsAlias)
            .HasDatabaseName("idx_menu_alias");

        builder.HasIndex(e => e.MenStStatus)
            .HasDatabaseName("idx_menu_status");

        // Navigation properties - commented until all entities are implemented
        // No foreign keys - Menu is a parent table
    }
}
